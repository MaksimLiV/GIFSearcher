//
//  GIFDetailViewController.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit

class GIFDetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: GIFDetailViewModel
    
    private let gifImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(gif: GIF) {
        self.viewModel = GIFDetailViewModel(gif: gif)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithGif()
        
        viewModel.delegate = self
        viewModel.loadFullDetails()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "GIF Details"
        view.backgroundColor = .systemBackground
        
        view.addSubview(gifImageView)
        view.addSubview(titleLabel)
        view.addSubview(shareButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            gifImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gifImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gifImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gifImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            titleLabel.topAnchor.constraint(equalTo: gifImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            shareButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            
            activityIndicator.centerXAnchor.constraint(equalTo: gifImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: gifImageView.centerYAnchor)
        ])
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    private func configureWithGif() {
        let gif = viewModel.gif
        titleLabel.text = gif.title
        
        if let url = URL(string: gif.images.original.url) {
            activityIndicator.startAnimating()
            gifImageView.setGifFromURL(url)
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Actions
    @objc private func shareButtonTapped() {
        guard let gifURL = URL(string: viewModel.gif.images.original.url) else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [viewModel.gif.title, gifURL],
            applicationActivities: nil
        )
        
        present(activityViewController, animated: true)
    }
}

// MARK: - GIFDetailViewModelDelegate
extension GIFDetailViewController: GIFDetailViewModelDelegate {
    func didStartLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.configureWithGif()
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showErrorAlert(error)
        }
    }
}
