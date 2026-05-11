
//
//  UIImageViewGif.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit
import SwiftyGif

extension UIImageView {
    
    @discardableResult
    func setGifFromURL(
        _ url: URL,
        levelOfIntegrity: GifLevelOfIntegrity = .default,
        loopCount: Int = -1,
        showLoader: Bool = false
    ) -> URLSessionDataTask? {
        return self.setGifFromURL(
            url,
            loopCount: loopCount,
            levelOfIntegrity: levelOfIntegrity,
            showLoader: showLoader
        )
    }
    
    func prepareForReuse() {
        clear()
        delegate = nil
    }
}
