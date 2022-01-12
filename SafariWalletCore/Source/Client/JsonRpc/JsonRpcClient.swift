//
//  JsonRpcClient.swift
//  Wallet (iOS)
//
//  Created by Tassilo von Gerlach on 10/18/21.
//

import Foundation

public struct JsonRpcClient {
   
    public enum NetworkError: Error {
        case invalidUrl
        case jsonRpcError(JsonRpcError)
        case decodingError
        case encodingError
        case unknown
    }
    
    public let url: URL
   
    public func makeRequest<P: Encodable, R: Decodable>(method: String,
                                                        params: P,
                                                        resultType: R.Type,
                                                        urlSession: WalletURLSession = URLSession.shared)  async throws -> R {
      
//        var urlRequest = URLRequest(url: url,
//                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
//        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        let rpcRequest = JsonRpcRequest<P>(method: method, params: params)
//        guard let body = try? JSONEncoder().encode(rpcRequest) else {
//            throw NetworkError.encodingError
//        }
//        urlRequest.httpBody = body
//
//        let (data, _) = try await urlSession.data(for: urlRequest, delegate: nil)
        let data = try await makeRequest(method: method, params: params, urlSession: urlSession)
        let jsonRpcResponse = try JSONDecoder().decode(JsonRpcResponse<R>.self, from: data)
        if let result = jsonRpcResponse.result {
            return result
        } else if let rpcError = jsonRpcResponse.error {
            throw NetworkError.jsonRpcError(rpcError)
        } else {
            throw NetworkError.unknown
        }
    }
    
    public func makeRequest<P: Encodable>(method: String,
                                   params: P,
                                   urlSession: WalletURLSession = URLSession.shared) async throws -> Data {
        var urlRequest = URLRequest(url: url,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        let rpcRequest = JsonRpcRequest<P>(method: method, params: params)
        guard let body = try? JSONEncoder().encode(rpcRequest) else {
            throw NetworkError.encodingError
        }
        urlRequest.httpBody = body

        return try await urlSession.data(for: urlRequest, delegate: nil).0
    }
    
    public func makeRawRequest(data: Data, urlSession: WalletURLSession = URLSession.shared) async throws -> Data {
        var urlRequest = URLRequest(url: url,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = data

        return try await urlSession.data(for: urlRequest, delegate: nil).0
    }
    
//    func makeRequest(method: String, dictParams: Any, urlSession: WalletURLSession = URLSession.shared) async throws -> Data {
//        var urlRequest = URLRequest(url: url,
//                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
//        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        let dict: [String: Any] = [
//            "jsonrpc": "2.0",
//            "method": method,
//            "params": dictParams,
//            "id": 1
//        ]
//        let jsonData = try JSONSerialization.data(withJSONObject: dict)
//        urlRequest.httpBody = jsonData
//        return try await urlSession.data(for: urlRequest, delegate: nil).0
//    }
   
    public func makeRequest<R: Codable>(method: String,
                                       resultType: R.Type,
                                       urlSession: WalletURLSession = URLSession.shared)  async throws -> R {
       let params: [Bool] = []
       return try await makeRequest(method: method, params: params, resultType: resultType)
   }
   
}
