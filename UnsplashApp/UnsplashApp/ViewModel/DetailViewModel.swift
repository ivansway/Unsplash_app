//
//  DetailViewModel.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import Foundation
import UIKit

class DetailViewModel {
    private let photo: PhotosModel
    var onImageLoaded: ((UIImage?) -> Void)?
    var onFavoriteUpdated: ((Bool) -> Void)?
    
    init(photo: PhotosModel) {
        self.photo = photo
    }
    
    var photoDetails: String {
        let dateText = "Дата: \(photo.createdAt)"
        let authorText = "Автор: \(photo.authorName)"
        return "\(dateText)\n\(authorText)"
    }
    
    func isFavorite() -> Bool {
        FavoritesManager.shared.isFavorite(photo: photo)

    }
    
    func loadImage() {
        guard let url = URL(string: photo.imageURL) else {
            onImageLoaded?(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.onImageLoaded?(image)
                }
            } else {
                DispatchQueue.main.async {
                    self.onImageLoaded?(nil)
                }
            }
        }.resume()
    }
    
    func toggleFavorite() {
        if isFavorite() {
            FavoritesManager.shared.remove(photo: photo)
        } else {
            FavoritesManager.shared.add(photo: photo)
        }
        let newState = FavoritesManager.shared.isFavorite(photo: photo)

        DispatchQueue.main.async {
            self.onFavoriteUpdated?(newState)
        }
    }
}
