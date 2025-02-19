//
//  PhotoModel.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import Foundation

struct PhotosModel: Decodable, Equatable, Hashable {
    let id: String
    let createdAt: String
    let authorName: String
    let imageURL: String
    
    static func == (lhs: PhotosModel, rhs: PhotosModel) -> Bool {
            return lhs.id == rhs.id
        }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case user
        case urls
    }

    enum UserKeys: String, CodingKey {
        case name
    }

    enum UrlsKeys: String, CodingKey {
        case regular
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        
        let userContainer = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        authorName = try userContainer.decode(String.self, forKey: .name)
        
        let urlsContainer = try container.nestedContainer(keyedBy: UrlsKeys.self, forKey: .urls)
        imageURL = try urlsContainer.decode(String.self, forKey: .regular)
    }
}

struct SearchResponse: Decodable {
    let total: Int
    let totalPages: Int
    let results: [PhotosModel]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

