//
//  GIFDetailViewModel.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

// MARK: - GIFDetailViewModelDelegate

protocol GIFDetailViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didFailWithError(_ error: Error)
}

// MARK: - GIFDetailViewModel

class GIFDetailViewModel {
    
    // MARK: - Private Properties
    
    private let giphyService: GiphyServiceProtocol
    
    // MARK: - Public Properties
    
    weak var delegate: GIFDetailViewModelDelegate?
    private(set) var gif: GIF
    
    // MARK: - Initialization
    
    init(gif: GIF, giphyService: GiphyServiceProtocol = GiphyService()) {
        self.gif = gif
        self.giphyService = giphyService
    }
    
    // MARK: - Public Methods
    
    func loadFullDetails() {
        delegate?.didStartLoading()
        
        giphyService.getGifById(id: gif.id) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let detailedGif):
                    self.gif = detailedGif
                    self.delegate?.didFinishLoading()
                case .failure(let error):
                    self.delegate?.didFailWithError(error)
                }
            }
        }
    }
}
