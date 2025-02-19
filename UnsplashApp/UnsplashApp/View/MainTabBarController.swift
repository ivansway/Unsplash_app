//
//  MainTabBarController.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let photosVC = MainViewController()
        photosVC.tabBarItem = UITabBarItem(title: "Фото", image: UIImage(systemName: "photo"), tag: 0)
        
        let favoritesVC = FavoritesViewController()
        favoritesVC.tabBarItem = UITabBarItem(title: "Избранное", image: UIImage(systemName: "heart"), tag: 1)
        
        viewControllers = [
            UINavigationController(rootViewController: photosVC),
            UINavigationController(rootViewController: favoritesVC)
        ]
    }
}

