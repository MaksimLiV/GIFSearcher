//
//  GIFSearchViewModel.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

protocol GIFSearchViewModelDelegate: AnyObject {
    func didUpdateGifs()
    func didFailWithError(_ error: Error)
    func didStartLoading()
    func didFinishLoading()
}

class GIFSearchViewModel {
    private let giphyService: GiphyServiceProtocol
    weak var delegate: GIFSearchViewModelDelegate?
    
    private(set) var gifs: [GIF] = []
    private(set) var isLoading = false
    private(set) var currentSearchQuery: String = ""
    private(set) var currentPage = 0
    private(set) var hasMorePages = true
    
    private let itemsPerPage = 20
    private var searchWorkItem: DispatchWorkItem?
    
    init(giphyService: GiphyServiceProtocol = GiphyService()) {
        self.giphyService = giphyService
    }
    
    
    func loadInitialGifs() {
        fetchTrendingGifs()
    }
    
    
    func searchGifs(query: String) {
        
        searchWorkItem?.cancel()
        
        if query.isEmpty {
            
            resetSearch()
            fetchTrendingGifs()
            return
        }
        
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.resetSearch()
            self?.currentSearchQuery = query
            self?.performSearch()
        }
        
        searchWorkItem = workItem
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: workItem)
    }
    
    
    func loadMoreGifs() {
        guard !isLoading, hasMorePages else { return }
        
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
    
    
    private func resetSearch() {
        gifs = []
        currentPage = 0
        hasMorePages = true
        delegate?.didUpdateGifs()
    }
    
    
    private func fetchTrendingGifs(loadMore: Bool = false) {
        guard !isLoading else { return }
        
        if loadMore {
            currentPage += 1
        }
        
        let offset = currentPage * itemsPerPage
        
        isLoading = true
        delegate?.didStartLoading()
        
        giphyService.getTrendingGifs(limit: itemsPerPage, offset: offset) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let response):
                
                self.hasMorePages = offset + response.data.count < response.pagination.totalCount
                
                if loadMore {
                    self.gifs.append(contentsOf: response.data)
                } else {
                    self.gifs = response.data
                }
                
                self.delegate?.didUpdateGifs()
                
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
    
    
    private func performSearch(loadMore: Bool = false) {
        guard !isLoading else { return }
        
        if loadMore {
            currentPage += 1
        }
        
        let offset = currentPage * itemsPerPage
        
        isLoading = true
        delegate?.didStartLoading()
        
        giphyService.searchGifs(query: currentSearchQuery, limit: itemsPerPage, offset: offset) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let response):
                
                self.hasMorePages = offset + response.data.count < response.pagination.totalCount
                
                if loadMore {
                    self.gifs.append(contentsOf: response.data)
                } else {
                    self.gifs = response.data
                }
                
                self.delegate?.didUpdateGifs()
                
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
}
