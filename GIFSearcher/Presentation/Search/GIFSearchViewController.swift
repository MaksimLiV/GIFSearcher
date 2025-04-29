//
//  GIFSearchViewController.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit

class GIFSearchViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = GIFSearchViewModel()
    private var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let footerLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupCollectionView()
        setupNetworkMonitoring()
        
        viewModel.delegate = self
        viewModel.loadInitialGifs()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "GIF Searcher"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure the loading indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search GIF..."
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        updateLayoutForCurrentOrientation(layout)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(GIFCollectionViewCell.self, forCellWithReuseIdentifier: GIFCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        footerLoadingIndicator.hidesWhenStopped = true
    }
    
    private func updateLayoutForCurrentOrientation(_ layout: UICollectionViewFlowLayout) {
        let isPortrait = UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == .unknown
        
        let spacing: CGFloat = 10
        let totalSpacing = spacing * (isPortrait ? 3 : 5) // 2+1 or 4+1 spacings
        let width = view.frame.width - totalSpacing
        
        let itemWidth = (width / (isPortrait ? 2 : 4))
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        layout.footerReferenceSize = CGSize(width: view.frame.width, height: 50)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self,
                  let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
            self.updateLayoutForCurrentOrientation(layout)
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring { [weak self] isConnected in
            if !isConnected {
                self?.showAlert(title: "No Internet Connection", message: "Please check your internet connection and try again.")
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension GIFSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFCollectionViewCell.reuseIdentifier, for: indexPath) as? GIFCollectionViewCell,
              let gif = viewModel.gif(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: gif)
        
        if indexPath.item == viewModel.gifs.count - 5 && !viewModel.isLoading {
            viewModel.loadMoreGifs()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
            
            footerLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(footerLoadingIndicator)
            
            NSLayoutConstraint.activate([
                footerLoadingIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
                footerLoadingIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
            ])
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate
extension GIFSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let gif = viewModel.gif(at: indexPath.item) else { return }
        
        let detailVC = GIFDetailViewController(gif: gif)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - GIFSearchViewModelDelegate
extension GIFSearchViewController: GIFSearchViewModelDelegate {
    func didUpdateGifs() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showErrorAlert(error)
        }
    }
    
    func didStartLoading() {
        DispatchQueue.main.async { [weak self] in
            if self?.viewModel.gifs.isEmpty == true {
                self?.activityIndicator.startAnimating()
            } else {
                self?.footerLoadingIndicator.startAnimating()
            }
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.footerLoadingIndicator.stopAnimating()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension GIFSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.searchGifs(query: searchText)
    }
}
