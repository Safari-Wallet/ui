//
//  Client.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/24/21.
//

import Foundation
import MEWwalletKit
import Network
import BigInt

public class BaseClient {
    
    private (set) var isConnected: Bool = false
    
    let jsonRpcClient: JsonRpcClient
    let network: Network
    let monitor = NWPathMonitor()
    
    public init?(network: Network = .ethereum, provider: NodeProvider) {
        guard let baseURL = provider.baseURL(for: network) else { return nil }
        self.jsonRpcClient = JsonRpcClient(url: baseURL)
        self.network = network
        self.monitor.pathUpdateHandler = { self.isConnected = ($0.status == .satisfied) }
        self.monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    deinit {
        self.monitor.cancel()
    }
   
}
