//
//  DetailViewController.swift
//  UnsplashApp
//
//  Created by Ivan Myrza on 05.02.2025.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    init(photo: PhotosModel) {
        self.viewModel = DetailViewModel(photo: photo)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Детали"
        setupLayout()
        bindViewModel()
        viewModel.loadImage()
    }
}

extension DetailViewController {
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(infoLabel)
        view.addSubview(likeButton)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(view.snp.width).multipliedBy(0.75)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        infoLabel.text = viewModel.photoDetails
        updateLikeButton()
        
        viewModel.onImageLoaded = { [weak self] image in
            self?.imageView.image = image
        }
        
        viewModel.onFavoriteUpdated = { [weak self] _ in
            self?.updateLikeButton()
        }
    }
    
    private func updateLikeButton() {
        let state = viewModel.isFavorite()
        print("Обновление кнопки, isFavorite = \(state)")
        let title = state ? "Удалить" : "Лайк"
        likeButton.setTitle(title, for: .normal)
    }

    
    @objc private func likeButtonTapped() {
        viewModel.toggleFavorite()
    }
}
