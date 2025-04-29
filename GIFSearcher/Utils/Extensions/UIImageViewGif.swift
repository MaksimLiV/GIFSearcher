//
//  UIImageViewGif.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit
import ObjectiveC

extension UIImageView {
    private static var taskKey = "GIFDownloadTask"
    
    private var currentTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.taskKeyPointer) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.taskKeyPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    private static var taskKeyPointer = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
    
    func setGifFromURL(_ url: URL, placeholderImage: UIImage? = nil) {
        self.image = placeholderImage
        cancelCurrentTask()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                return
            }
            
            let count = CGImageSourceGetCount(source)
            
            if count == 1, let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                DispatchQueue.main.async {
                    self.image = UIImage(cgImage: cgImage)
                }
                return
            }
            
            var images = [UIImage]()
            var totalDuration: TimeInterval = 0
            
            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                    let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                    
                    var frameDuration: TimeInterval = 0.1
                    if let delayTime = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
                        frameDuration = delayTime
                    }
                    
                    totalDuration += frameDuration
                    images.append(UIImage(cgImage: cgImage))
                }
            }
            
            if !images.isEmpty {
                DispatchQueue.main.async {
                    self.image = UIImage.animatedImage(with: images, duration: totalDuration)
                }
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    private func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    func prepareForReuse() {
        cancelCurrentTask()
        image = nil
    }
}
