//
//  ImageLoader.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

final class ImageLoader {
    // MARK: Data storage
    
    static let shared = ImageLoader()

    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    // MARK: - Load

    func loadImage(
        from urlString: String?,
        completion: @escaping (UIImage?) -> Void
    ) {

        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        // 1. Проверяем кеш
        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return
        }

        // 2. Скачиваем
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in

            guard let self,
                  let data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // 3. Сохраняем в кеш
            self.cache.setObject(image, forKey: urlString as NSString)

            DispatchQueue.main.async {
                completion(image)
            }

        }.resume()
    }
}
