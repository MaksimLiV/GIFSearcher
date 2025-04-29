//
//  NetworkMonitor.swift
//  GIFSearcher
//
//  Created by Maksim Li on 29/04/2025.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private(set) var isConnected: Bool = true
    private var connectivityHandler: ((Bool) -> Void)?
    
    private init() {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            self.isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                self.connectivityHandler?(self.isConnected)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func startMonitoring(handler: @escaping (Bool) -> Void) {
        self.connectivityHandler = handler
    }
    
    func stopMonitoring() {
        connectivityHandler = nil
    }
    
    deinit {
        monitor.cancel()
    }
}
