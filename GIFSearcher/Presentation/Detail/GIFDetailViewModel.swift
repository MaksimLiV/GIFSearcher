//
//  GIFDetailViewModel.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation

protocol GIFDetailViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didFailWithError(_ error: Error)
}

class GIFDetailViewModel {
    private let giphyService: GiphyServiceProtocol
    weak var delegate: GIFDetailViewModelDelegate?
    
    private(set) var gif: GIF
    
    init(gif: GIF, giphyService: GiphyServiceProtocol = GiphyService()) {
        self.gif = gif
        self.giphyService = giphyService
    }
    
    func loadFullDetails() {
        delegate?.didStartLoading()
        
        giphyService.getGifById(id: gif.id) { [weak self] result in
            guard let self = self else { return }
            
            self.delegate?.didFinishLoading()
            
            switch result {
            case .success(let detailedGif):
                self.gif = detailedGif
            case .failure(let error):
                self.delegate?.didFailWithError(error)
            }
        }
    }
}
