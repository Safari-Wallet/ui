//
//  SharedDocument.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/8/21.
//

import Foundation
import MEWwalletKit

struct SharedDocument {

    let url: URL
    
    init(filename: String) throws {
        url = try URL.sharedContainerURL(filename: filename)
    }
    
    func read() async throws -> Data {
        let url = try await NSFileCoordinator().coordinate(readingItemAt: self.url)
        return try Data(contentsOf: url)
    }
    
    func write(_ data: Data) async throws {
        let url = try await  NSFileCoordinator().coordinate(writingItemAt: self.url)
        return try data.write(to: url, options: .atomic)
    }
    
    static func list(fileExtension: String) throws -> [SharedDocument] {
        let container = try URL.sharedContainer()
        return try FileManager.default.contentsOfDirectory(atPath: container.path).filter{ $0.pathExtension == fileExtension }.compactMap { try? SharedDocument(filename: $0) }
    }
    
    static func listAddressBundles(network: Network) throws -> [SharedDocument] {
        let networkExtension = network.symbol
        return try list(fileExtension: ADDRESSBUNDLE_FILE_EXTENSION).filter {
            $0.url.deletingPathExtension().pathExtension == networkExtension
        }
    }
}

