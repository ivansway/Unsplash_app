//
//  MainViewController.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    private let viewModel = MainViewModel()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<MainViewSection, PhotosModel>!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фото"
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupDataSource()
        setupSearchController()
        setupRefreshControl()
        bindViewModel()
        viewModel.fetchPhotos()
    }
}

/// Настройка коллекции
extension MainViewController {
    private func setupCollectionView() {
        // Настраиваем layout
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Устанавливаем делегата для обработки событий (например, для пагинации)
        collectionView.delegate = self
        
        // Регистрируем ячейку
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)
    }
}

// Настройка пагинации
extension MainViewController {
    private func setupDataSource() {
        // Этот блок кода инициализирует diffable data source для вашей коллекции.
        dataSource = UICollectionViewDiffableDataSource<MainViewSection, PhotosModel>(collectionView: collectionView) { [weak self] (collectionView, indexPath, photo) -> UICollectionViewCell? in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
                return nil
            }
            
            // Сбрасываем изображение для переиспользуемой ячейки
            cell.configure(with: nil)
            
            // Загружаем изображение через ViewModel
            self.viewModel.loadImage(for: photo) { image in
                DispatchQueue.main.async {
                    if let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
                        cell.configure(with: image)
                    }
                }
            }
            
            return cell
        }
        
        // Создаем начальный snapshot
        var snapshot = NSDiffableDataSourceSnapshot<MainViewSection, PhotosModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

/// Настройка Refresh Control
extension MainViewController {
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshPhotos() {
        viewModel.fetchPhotos(reset: true)
    }
    
    // Привязка ViewModel
    private func bindViewModel() {
        viewModel.onPhotosUpdated = { [weak self] newPhotosCount, isReset in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.collectionView.refreshControl?.endRefreshing()
                
                // Получаем текущий snapshot
                var snapshot = self.dataSource.snapshot()
                
                if isReset {
                    // При сбросе удаляем все элементы и добавляем заново
                    snapshot.deleteAllItems()
                    snapshot.appendSections([.main])
                    snapshot.appendItems(self.viewModel.photos)
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                } else {
                    // При подгрузке новых данных добавляем только новые элементы
                    let newItems = Array(self.viewModel.photos.suffix(newPhotosCount))
                    snapshot.appendItems(newItems, toSection: .main)
                    self.dataSource.apply(snapshot, animatingDifferences: true)
                }
            }
        }
        
        viewModel.onError = { error in
            print("Ошибка получения фото: \(error)")
        }
    }
}

/// UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Задаём размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let totalSpacing = (spacing * 3)
        let availableWidth = collectionView.frame.width - totalSpacing
        let width = availableWidth / 2
        return CGSize(width: width, height: width)
    }
    
    // Обработка нажатия на ячейку
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = dataSource.itemIdentifier(for: indexPath) else { return }
        let detailVC = DetailViewController(photo: photo)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Пагинация: когда прокручиваем до конца, загружаем ещё
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 4 {
            viewModel.loadMorePhotos()
        }
    }
}

/// UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.updateQuery(query)
        searchController.dismiss(animated: true)
    }
    
    // Настройка Search Controller
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
}

