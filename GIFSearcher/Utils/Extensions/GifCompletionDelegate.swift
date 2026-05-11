//
//  GifCompletionDelegate.swift
//  GIFSearcher
//
//  Created by Maksim Li on 21/04/2026.
//

import UIKit
import SwiftyGif

final class GifCompletionDelegate: NSObject, SwiftyGifDelegate {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func gifURLDidFinish(sender: UIImageView) {
        completion()
    }
    
    func gifURLDidFail(sender:UIImageView, url: URL, error: Error?) {
        if let error = error as NSError?, error.code == NSURLErrorCancelled {
            return
        }
        completion()
    }
}

