//
//  ImageCacheManager.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import Foundation
import UIKit

final class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    /// NSCache для хранения UIImage, где ключ – URL картинки в виде NSString
    private let imageCache = NSCache<NSString, UIImage>()
    
    /// Таймер для периодической очистки кэша
    private var cacheClearTimer: Timer?
    
    /// Интервал очистки кэша (например, 5 минут)
    private let cacheClearInterval: TimeInterval = 300
    
    private init() {
        // Запускаем таймер для очистки кэша
        cacheClearTimer = Timer.scheduledTimer(timeInterval: cacheClearInterval,
                                               target: self,
                                               selector: #selector(clearCache),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    deinit {
        cacheClearTimer?.invalidate()
    }
    
    /// Метод для загрузки изображения по URL-строке с использованием кэша.
    /// Если изображение уже есть в кэше, то сразу возвращается оно.
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let key = NSString(string: urlString)
        
        // Если изображение уже есть в кэше, возвращаем его
        if let cachedImage = imageCache.object(forKey: key) {
            completion(cachedImage)
            return
        }
        
        // Если изображения нет, пытаемся создать URL
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Загружаем изображение асинхронно
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            // Сохраняем изображение в кэше
            self.imageCache.setObject(image, forKey: key)
            completion(image)
        }.resume()
    }
    
    /// Метод, вызываемый таймером для очистки кэша
    @objc private func clearCache() {
        imageCache.removeAllObjects()
        print("Image cache cleared")
    }
}

