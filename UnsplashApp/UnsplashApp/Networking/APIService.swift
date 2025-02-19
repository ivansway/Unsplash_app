//
//  APIService.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case noData
}

/// Не стал писать более гибкий сервис
class APIService {
    
    static let shared = APIService()
    private init() {}
    
    // Ключ доступа к сервису хранил бы в key chain 
    private let accessKey = "_TtGnh5fX9lfxpMmoKwoDl7nnLcghYGJPNj8yQJ-EFE"
    
    func fetchPhotos(query: String, page: Int, perPage: Int, completion: @escaping (Result<[PhotosModel], Error>) -> Void) {
        let urlString = "https://api.unsplash.com/search/photos?page=\(page)&per_page=\(perPage)&query=\(query)&client_id=\(accessKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(APIError.noData))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                    completion(.success(searchResponse.results))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}

