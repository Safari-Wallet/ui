//
//  ENSService.swift
//  Wallet (iOS)
//
//  Created by Stefano on 14.01.22.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

protocol ENSReverseResolvable {
    func resolve(address: RawAddress) async throws -> String
}

protocol ENSResolvable {
    func resolve(ens: String) async throws -> RawAddress
}

final class ENSResolver {
    
    private let client: EthereumClient?
    private let ensContract: ENSContract
    private let network: Network
    
    init(network: Network) {
        self.network = network
        let key = network == .ethereum ? ApiKeys.alchemyMainnet : ApiKeys.alchemyRopsten
        self.client = EthereumClient(network: network, provider: .alchemy(key: key))
        self.ensContract = ENSContract(network: network)
    }
}

// MARK: - ENSReverseResolvable

extension ENSResolver: ENSReverseResolvable {
    
    func resolve(address: RawAddress) async throws -> String {
        guard let client = client else { throw ENSError.clientError }
        
        // Normalise and hash the name
        let hashedName = hash(address: address)
        
        // Call resolver() on the ENS registry. This returns the address of the resolver responsible for the name.
        let resolverAddressHex = try await resolver(forName: hashedName)
        
        guard resolverAddressHex != .nullAddress else { throw ENSError.resolverContractUnknown }
        let resolverAddress = decode(address: resolverAddressHex)
        
        // Resolve the ENS name with the returned resolver
        let nameCall = ensContract.nameResolver.name(hashedName, contractAddress: Address(raw: resolverAddress))
        let ensNameHex: String = try await client.ethCall(call: nameCall)
        
        guard let ensName = decode(ensName: ensNameHex) else {
            throw ENSError.failedDecoding
        }
        
        guard !ensName.isEmpty else { throw ENSError.ensUnknown }
        
        return ensName
    }
    
    private func hash(address: RawAddress) -> String {
        let ensReverse = address.lowercased().withoutHexPrefix() + ".addr.reverse"
        return hash(name: ensReverse).withHexPrefix()
    }
    
    private func decode(ensName hex: String) -> String? {
        return ABIDecoder.decodeSignleType(type: .string, data: Data(hex: hex)).value as? String
    }
}

// MARK: - ENSResolvable

extension ENSResolver: ENSResolvable {
    
    func resolve(ens: String) async throws -> RawAddress {
        guard let client = client else { throw ENSError.clientError }
        
        // Normalise and hash the name
        let hashedName = hash(name: ens).withHexPrefix()
        
        // Call resolver() on the ENS registry. This returns the address of the resolver responsible for the name.
        let resolverAddressHex = try await resolver(forName: hashedName)
        
        // Resolve the address with the returned resolver
        guard resolverAddressHex != .nullAddress else { throw ENSError.resolverContractUnknown }
        let resolverAddress = decode(address: resolverAddressHex)
        
        let addrCall = ensContract.addrResolver.addr(hashedName, contractAddress: Address(raw: resolverAddress))
        let addressHex: String = try await client.ethCall(call: addrCall)
        let address = decode(address: addressHex)
        
        guard address != .nullAddress else { throw ENSError.ensUnknown }
        
        return address
    }
}

// MARK: - Private

private extension ENSResolver {
    
    func hash(name: String) -> String {
        let ensComponents = name.components(separatedBy: ".")
        let hashedEns = ensComponents.reversed().reduce(Data(count: 32)) { data, component in
            var data = data
            let componentData = component.data(using: .utf8) ?? Data()
            data.append(componentData.sha3(.keccak256))
            return data.sha3(.keccak256)
        }
        return hashedEns.toHexString()
    }
    
    func resolver(forName name: String) async throws -> String {
        guard let client = client else { throw ENSError.clientError }
        let resolverCall = ensContract.registry.resolver(name)
        let resolverAddressHex: String = try await client.ethCall(call: resolverCall)
        return resolverAddressHex
    }
    
    func decode(address hex: String) -> RawAddress {
        let index = hex.index(hex.endIndex, offsetBy: -40)
        let rawAddress = String(hex[index...]).withHexPrefix()
        return rawAddress
    }
}

private extension String {
    
    static let nullAddress = "0x0000000000000000000000000000000000000000000000000000000000000000"
}

enum ENSError: Error {
    case invalidName
    case ensUnknown
    case resolverContractUnknown
    case failedDecoding
    case clientError
}
