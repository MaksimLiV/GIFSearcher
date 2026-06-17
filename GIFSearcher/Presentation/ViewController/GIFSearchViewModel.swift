//
//  GIFSearchViewModel.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

// MARK: - GIFSearchViewModelDelegate

protocol GIFSearchViewModelDelegate: AnyObject {
    func didUpdateGifs()
    func didFailWithError(_ error: Error)
    func didStartLoading()
    func didFinishLoading()
    func didAppendGifs(at indexPaths: [IndexPath])
}

// MARK: - GIFSearchViewModel

class GIFSearchViewModel {
    
    // MARK: - Public Properties
    
    weak var delegate: GIFSearchViewModelDelegate?
    private(set) var gifs: [GIF] = []
    private(set) var isLoading = false
    private(set) var currentSearchQuery: String = ""
    private(set) var currentPage = 0
    private(set) var hasMorePages = true
    
    // MARK: - Private Properties
    
    private let giphyService: GiphyServiceProtocol
    private let itemsPerPage = 20
    private var searchWorkItem: DispatchWorkItem?
    
    // MARK: - Initialization
    
    init(giphyService: GiphyServiceProtocol = GiphyService()) {
        self.giphyService = giphyService
    }
    
    // MARK: - Public Methods
    
    func loadInitialGifs() {
        fetchTrendingGifs()
    }
    
    func searchGifs(query: String) {
        searchWorkItem?.cancel()
        
        guard query != currentSearchQuery else {
            return
        }
        currentSearchQuery = query
        
        if query.isEmpty {
            fetchTrendingGifs()
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch()
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: workItem)
    }
    
    func loadMoreGifs() {
        guard !isLoading, hasMorePages else {
            return
        }
        
        if currentSearchQuery.isEmpty {
            fetchTrendingGifs(loadMore: true)
        } else {
            performSearch(loadMore: true)
        }
    }
    
    func gif(at index: Int) -> GIF? {
        guard index < gifs.count else { return nil }
        return gifs[index]
    }
    
    // MARK: - Private Methods
    
    private func resetSearch() {
        gifs = []
        currentPage = 0
        hasMorePages = true
        isLoading = false
    }
    
    private func fetchTrendingGifs(loadMore: Bool = false) {
        guard !isLoading else {
            return
        }
        
        if !loadMore {
            resetSearch()
        } else {
            currentPage += 1
        }
        
        let offset = currentPage * itemsPerPage
        
        isLoading = true
        delegate?.didStartLoading()
        
        giphyService.getTrendingGifs(limit: itemsPerPage, offset: offset) { [weak self] result in
            guard let self else { return }
            
            self.isLoading = false
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let response):
                self.hasMorePages = offset + response.data.count < response.pagination.totalCount
                if loadMore {
                    let startIndex = self.gifs.count
                    self.gifs.append(contentsOf: response.data)
                    let indexPaths = (startIndex..<self.gifs.count).map { IndexPath(item: $0, section: 0) }
                    self.delegate?.didAppendGifs(at: indexPaths)
                } else {
                    self.gifs = response.data
                    self.delegate?.didUpdateGifs()
                }
                
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
    
    private func performSearch(loadMore: Bool = false) {
        guard !isLoading else {
            return
        }
        
        if !loadMore {
            resetSearch()
        } else {
            currentPage += 1
        }
        
        let offset = currentPage * itemsPerPage
        
        isLoading = true
        delegate?.didStartLoading()
        
        giphyService.searchGifs(query: currentSearchQuery, limit: itemsPerPage, offset: offset) { [weak self] result in
            guard let self else { return }
            
            self.isLoading = false
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let response):
                self.hasMorePages = offset + response.data.count < response.pagination.totalCount
                if loadMore {
                    let startIndex = self.gifs.count
                    self.gifs.append(contentsOf: response.data)
                    let indexPaths = (startIndex..<self.gifs.count).map { IndexPath(item: $0, section: 0) }
                    self.delegate?.didAppendGifs(at: indexPaths)
                } else {
                    self.gifs = response.data
                    self.delegate?.didUpdateGifs()
                }
                
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
}
