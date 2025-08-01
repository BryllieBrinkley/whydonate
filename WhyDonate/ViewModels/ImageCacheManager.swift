import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - Image Cache Manager
@MainActor
class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Set up cache configuration
        cache.countLimit = 100 // Maximum 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Create cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Clean up old cache files on init
        cleanupOldCacheFiles()
    }
    
    // MARK: - Public Methods
    func image(for url: String) -> UIImage? {
        let key = NSString(string: url)
        
        // Check memory cache first
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadImageFromDisk(for: url) {
            cache.setObject(diskImage, forKey: key)
            return diskImage
        }
        
        return nil
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        let key = NSString(string: url)
        
        // Cache in memory
        cache.setObject(image, forKey: key, cost: imageCost(image))
        
        // Cache on disk
        saveImageToDisk(image, for: url)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    private func loadImageFromDisk(for url: String) -> UIImage? {
        let fileName = cacheFileName(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveImageToDisk(_ image: UIImage, for url: String) {
        let fileName = cacheFileName(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: fileURL)
    }
    
    private func cacheFileName(for url: String) -> String {
        return url.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
    }
    
    private func imageCost(_ image: UIImage) -> Int {
        return Int(image.size.width * image.size.height * 4) // 4 bytes per pixel (RGBA)
    }
    
    private func cleanupOldCacheFiles() {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        
        for file in files {
            if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
               creationDate < oneWeekAgo {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}

// MARK: - Async Image View with Caching
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var loader = ImageLoader()
    @ObservedObject private var cacheManager = ImageCacheManager.shared
    
    init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loader.loadImage(from: url)
                    }
            }
        }
    }
}

// MARK: - Image Loader
@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let cacheManager = ImageCacheManager.shared
    private var cancellable: AnyCancellable?
    
    func loadImage(from urlString: String) {
        // Check cache first
        if let cachedImage = cacheManager.image(for: urlString) {
            image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] downloadedImage in
                    self?.image = downloadedImage
                    self?.cacheManager.cacheImage(downloadedImage, for: urlString)
                }
            )
    }
    
    deinit {
        cancellable?.cancel()
    }
}

// MARK: - Convenience Initializers
extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: String) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            content: content,
            placeholder: { ProgressView() }
        )
    }
}