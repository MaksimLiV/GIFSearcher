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
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    private lazy var footerLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(GIFCollectionViewCell.self, forCellWithReuseIdentifier: GIFCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
        
        return collectionView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No GIFs found"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupCollectionView()
        viewModel.delegate = self
        print("viewDidLoad: calling loadInitialGifs")
        setupNetworkMonitoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        updateLayoutForCurrentOrientation(layout)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        NetworkMonitor.shared.stopMonitoring()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "GIF Searcher"
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
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
        
        footerLoadingIndicator.hidesWhenStopped = true
    }
    
    
    // MARK: - Layout
    
    private func updateLayoutForCurrentOrientation(_ layout: UICollectionViewFlowLayout) {
        let isPortrait = UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == .unknown
        
        let spacing: CGFloat = 10
        let totalSpacing = spacing * (isPortrait ? 3 : 5)
        let width = view.frame.width - totalSpacing
        let itemWidth = width / (isPortrait ? 2 : 4)
        
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
    
    // MARK: - Network
    
    private var initialLoadDone = false
    
    private let noInternetView = NoInternetView()
    
    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring { [weak self] isConnected in
            guard let self else { return }
            
            if isConnected && !self.initialLoadDone {
                self.initialLoadDone = true
                self.noInternetView.hide()
                self.viewModel.loadInitialGifs()
            } else if isConnected && self.initialLoadDone {
                self.navigationItem.searchController = self.searchController
                self.noInternetView.hide()
                self.viewModel.loadInitialGifs()
            } else if !isConnected {
                self.footerLoadingIndicator.stopAnimating()
                self.navigationItem.searchController = nil
                self.noInternetView.show(in: self.view)
            }
        }
    }
}
// MARK: - UICollectionViewDataSource

extension GIFSearchViewController: UICollectionViewDataSource { // сколько ячеек показывать
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // как выглядит сама ячейка
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GIFCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! GIFCollectionViewCell
        
        if let gif = viewModel.gif(at: indexPath.item) {
            cell.configure(with: gif)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView { // что нужно показывать
        guard kind == UICollectionView.elementKindSectionFooter else {
            return UICollectionReusableView()
        }
        
        let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "FooterView",
            for: indexPath
        )
        
        if footerLoadingIndicator.superview == nil {
            footerLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(footerLoadingIndicator)
            NSLayoutConstraint.activate([
                footerLoadingIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
                footerLoadingIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
            ])
        }
        
        return footerView
    }
}

// MARK: - UICollectionViewDelegate

extension GIFSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let gif = viewModel.gif(at: indexPath.item) else { return }
        let detailVC = GIFDetailViewController(gif: gif)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard NetworkMonitor.shared.isConnected else { return }
        guard viewModel.hasMorePages else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        guard contentHeight > 0 else { return }
        
        if offsetY > contentHeight - frameHeight - 200 && !viewModel.isLoading {
            viewModel.loadMoreGifs()
        }
    }
}

// MARK: - GIFSearchViewModelDelegate

extension GIFSearchViewController: GIFSearchViewModelDelegate {
    func didUpdateGifs() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            let isEmpty = self.viewModel.gifs.isEmpty && !self.viewModel.isLoading
            self.emptyStateLabel.isHidden = !isEmpty
        }
    }
    
    func didAppendGifs(at indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Проверяем что количество элементов в коллекции совпадает с данными
            let currentCount = self.collectionView.numberOfItems(inSection: 0)
            let expectedCount = self.viewModel.gifs.count - indexPaths.count
            
            if currentCount == expectedCount {
                self.collectionView.insertItems(at: indexPaths)
            } else {
                // Данные рассинхронизированы — делаем полную перезагрузку
                self.collectionView.reloadData()
            }
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            if let networkError = error as? NetworkError,
               case .noInternetConnection = networkError {
                return
            }
            
            if let urlError = error as? NetworkError,
               case .unknown(let underlying) = urlError {
                let nsError = underlying as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                    nsError.code == NSURLErrorCannotFindHost {
                    return
                }
            }
            
            self?.showErrorAlert(error)
        }
    }
    
    func didStartLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.emptyStateLabel.isHidden = true
            if self.viewModel.gifs.isEmpty == true {
                self.activityIndicator.startAnimating()
            } else {
                self.footerLoadingIndicator.startAnimating()
            }
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            self.footerLoadingIndicator.stopAnimating()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension GIFSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchGifs(query: searchText)
    }
}
