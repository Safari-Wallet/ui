//
//  EtherscanModels.swift
//  
//
//  Created by Stefano on 04.12.21.
//

import Foundation

public enum Etherscan {
    
    public struct ContractResponse: Codable {
        public let status: String
        public let message: String
        public let result: [ContractDetail]
    }

    public struct ContractDetail {
        public let sourceCode: String
        public let abi: String
        public let contractName: String
        public let compilerVersion: String
        public let optimizationUsed: String
        public let runs: String
        public let constructorArguments: String
        public let evmVersion: String
        public let library: String
        public let licenseType: String
        public let proxy: String
        public let implementation: String
        public let swarmSource: String
    }
}

extension Etherscan.ContractDetail: Codable {
    
    enum CodingKeys: String, CodingKey {
        case sourceCode = "SourceCode"
        case abi = "ABI"
        case contractName = "ContractName"
        case compilerVersion = "CompilerVersion"
        case optimizationUsed = "OptimizationUsed"
        case runs = "Runs"
        case constructorArguments = "ConstructorArguments"
        case evmVersion = "EVMVersion"
        case library = "Library"
        case licenseType = "LicenseType"
        case proxy = "Proxy"
        case implementation = "Implementation"
        case swarmSource = "SwarmSource"
    }
}
