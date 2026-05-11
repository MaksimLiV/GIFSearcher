//
//  GIFCollectionViewCell.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit
import SwiftyGif

class GIFCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "GIFCollectionViewCell"
    
    // MARK: - UI Components
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Private Properties
    
    private var currentGifTask: URLSessionDataTask?
    private var gifDelegate: GifCompletionDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureShadows()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemGray5
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func configureShadows() {
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentGifTask?.cancel()
        currentGifTask = nil
        gifDelegate = nil
        
        imageView.prepareForReuse()
        
        titleLabel.text = nil
        activityIndicator.startAnimating()
    }
    
    // MARK: - Configuration
    
    func configure(with gif: GIF) {
        titleLabel.text = gif.title
        activityIndicator.startAnimating()
        
        guard let url = URL(string: gif.images.preview.url) else {
            activityIndicator.stopAnimating()
            return
        }
        
        gifDelegate = GifCompletionDelegate { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
        imageView.delegate = gifDelegate
        
        currentGifTask?.cancel()
        currentGifTask = imageView.setGifFromURL(
            url,
            levelOfIntegrity: .default,
            loopCount: -1,
            showLoader: false
        )
    }
}
