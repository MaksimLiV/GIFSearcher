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
    static let connectivityDidChange = Notification.Name("NetworkConnectivityDidChange")
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isConnected: Bool = false
    private var connectivityHandler: ((Bool) -> Void)?
    
    private init() {
        monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let connected = path.status == .satisfied
            
            guard connected != self.isConnected else {
                return
            }
            
            self.isConnected = connected
            DispatchQueue.main.async {
                self.connectivityHandler?(self.isConnected)
                NotificationCenter.default.post(
                    name: NetworkMonitor.connectivityDidChange,
                    object: nil,
                    userInfo: ["isConnected": connected]
                )
            }
        }
    }
    
    func startMonitoring(handler: @escaping (Bool) -> Void) {
        self.connectivityHandler = handler
        
        let currentPath = monitor.currentPath
        self.isConnected = currentPath.status == .satisfied
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        connectivityHandler = nil
        monitor.cancel()
    }
    
    deinit {
        monitor.cancel()
    }
}
