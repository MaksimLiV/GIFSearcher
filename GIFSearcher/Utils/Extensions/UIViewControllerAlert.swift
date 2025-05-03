//
//  UIViewControllerAlert.swift.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, actionTitle: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionTitle, style: .default) { _ in
            completion?()
        }
        
        alert.addAction(action)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorAlert(_ error: Error, completion: (() -> Void)? = nil) {
        showAlert(title: "Error", message: error.localizedDescription, completion: completion)
    }
}
