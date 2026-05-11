//
//  GIFDetailViewController.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit
import SwiftyGif

class GIFDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: GIFDetailViewModel
    
    private lazy var gifImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    
    private var currentGifTask: URLSessionDataTask?
    private var gifDelegate: GifCompletionDelegate?
    
    private let noInternetView = NoInternetView()
    
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
        subscribeToNetworkChanges()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentGifTask?.cancel()
        currentGifTask = nil
        gifDelegate = nil
        gifImageView.clear()
        NotificationCenter.default.removeObserver(self)
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
        
    }
    
    // MARK: - Configuration
    
    private func configureWithGif() {
        let gif = viewModel.gif
        titleLabel.text = gif.title
        
        guard let url = URL(string: gif.images.original.url) else { return }
        
        currentGifTask?.cancel()
        gifImageView.clear()
        
        gifDelegate = GifCompletionDelegate { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
        
        gifImageView.delegate = gifDelegate
        
        currentGifTask = gifImageView.setGifFromURL(
            url,
            levelOfIntegrity: .default,
            loopCount: -1,
            showLoader: false
        )
    }
    
    // MARK: - Network
    
    private func subscribeToNetworkChanges() {
        if !NetworkMonitor.shared.isConnected {
            noInternetView.show(in: view)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConnectivityChange(_:)),
            name: NetworkMonitor.connectivityDidChange,
            object: nil
        )
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
    
    @objc private func handleConnectivityChange(_ notification: Notification) {
        guard let isConnected = notification.userInfo?["isConnected"] as? Bool else { return }
        if isConnected {
            noInternetView.hide()
        } else {
            noInternetView.show(in: view)
        }
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
            self?.configureWithGif()
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            if let networkError = error as? NetworkError,
               case .noInternetConnection = networkError {
                return
            }
            self?.showErrorAlert(error)
        }
    }
    
}
