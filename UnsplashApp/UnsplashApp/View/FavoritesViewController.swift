//
//  FavoritesViewController.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import UIKit
import SnapKit

class FavoritesViewController: UIViewController {
    
    private var favoritePhotos: [PhotosModel] = FavoritesManager.shared.favorites
    private let viewModel = MainViewModel()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Избранное"
        view.backgroundColor = .systemBackground
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesUpdated()
    }
}

extension FavoritesViewController {
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)
    }
    
    @objc private func favoritesUpdated() {
        favoritePhotos = FavoritesManager.shared.favorites
        self.collectionView.reloadData()
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Количество элементов
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritePhotos.count
    }
    
    // Конфигурация ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let photo = favoritePhotos[indexPath.item]

        viewModel.loadImage(for: photo) { image in
            DispatchQueue.main.async {
                // Проверяем, что ячейка всё ещё отображается для данного indexPath
                if let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.configure(with: image)
                }
            }
        }
        
        return cell
    }
    
    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let totalSpacing = (spacing * 3)
        let availableWidth = collectionView.frame.width - totalSpacing
        let width = availableWidth / 2
        return CGSize(width: width, height: width)
    }
    
    // Обработка нажатия по ячейке
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = favoritePhotos[indexPath.item]
        let detailVC = DetailViewController(photo: photo)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

