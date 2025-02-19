//
//  FavoritesManager.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private(set) var favorites: [PhotosModel] = []
    
    private init() {}
    
    func add(photo: PhotosModel) {
        if !favorites.contains(where: { $0.id == photo.id }) {
            favorites.append(photo)
            print("Добавлено фото с id: \(photo.id)")
        }
    }
    
    func remove(photo: PhotosModel) {
        favorites.removeAll { $0.id == photo.id }
        print("Удалено фото с id: \(photo.id)")
    }
    
    func isFavorite(photo: PhotosModel) -> Bool {
        let result = favorites.contains { $0.id == photo.id }
        print("Проверка isFavorite для id \(photo.id): \(result)")
        return result
    }
}


