//
//  MainViewModel.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import Foundation
import UIKit

class MainViewModel {
    
    private(set) var photos: [PhotosModel] = []
    private var currentPage = 1
    private var isLoading = false
    private var currentQuery = "blue"
    
    // Замыкания для оповещения контроллера об изменениях
    var onPhotosUpdated: ((Int, Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    var photosCount: Int {
        return photos.count
    }
    
    func photo(at index: Int) -> PhotosModel {
        guard index < photos.count else {
            fatalError("Index out of range: requested \(index), but photos.count = \(photos.count)")
        }
        return photos[index]
    }
    
    // MARK: - Работа с данными
    
    func fetchPhotos(reset: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        
        if reset {
            currentPage = 1
            photos.removeAll()
        }
        
        APIService.shared.fetchPhotos(query: currentQuery, page: currentPage, perPage: 20) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let newPhotos):
                    let newPhotosCount = newPhotos.count
                    self.photos.append(contentsOf: newPhotos)
                    self.onPhotosUpdated?(newPhotosCount, reset)
                case .failure(let error):
                    self.onError?(error)
                }
                self.isLoading = false
            }
        }
    }
    
    func loadMorePhotos() {
        currentPage += 1
        fetchPhotos()
    }
    
    func updateQuery(_ query: String) {
        currentQuery = query
        fetchPhotos(reset: true)
    }
    
    // Загрузка изображения с использованием ImageCacheManager
    func loadImage(for photo: PhotosModel, completion: @escaping (UIImage?) -> Void) {
        ImageCacheManager.shared.loadImage(urlString: photo.imageURL, completion: completion)
    }
}
