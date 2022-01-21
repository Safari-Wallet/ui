//
//  ENSContract.swift
//  Wallet
//
//  Created by Stefano on 16.01.22.
//

import Foundation
import MEWwalletKit
import SafariWalletCore

struct ENSContract {
    
    let registry: Registry
    let nameResolver: NameResolver
    let addrResolver: AddrResolver
    
    private let network: Network
    
    init(network: Network) {
        self.network = network
        self.registry = Registry(network: network)
        self.nameResolver = NameResolver()
        self.addrResolver = AddrResolver()
    }
    
    struct Registry {
        
        static let mainnetAddress = Address(raw: "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
        static let ropstenAddress = Address(raw: "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
        
        static let resolverFunction: ABI.Element = .function(
            ABI.Element.Function(
                name: "resolver",
                inputs: [.init(name: "node", type: .bytes(length: 32))],
                outputs: [.init(name: "address", type: .string)],
                constant: false,
                payable: false
            )
        )
        
        let network: Network
        
        private var resolverAddress: Address {
            network == .ethereum ? Registry.mainnetAddress : Registry.ropstenAddress
        }
        
        func resolver(_ node: String) -> Call {
            let encodedParameters = Registry.resolverFunction.encodeParameters([node as AnyObject])
            let encodedParametersHex = encodedParameters?.toHexString().withHexPrefix()
            return Call(to: resolverAddress, data: encodedParametersHex)
        }
    }
    
    struct NameResolver {
        
        static let nameFunction: ABI.Element = .function(
            ABI.Element.Function(
                name: "name",
                inputs: [.init(name: "node", type: .bytes(length: 32))],
                outputs: [.init(name: "ens", type: .string)],
                constant: false,
                payable: false
            )
        )
        
        func name(_ node: String, contractAddress: Address) -> Call {
            let encodedParameters = NameResolver.nameFunction.encodeParameters([node as AnyObject])
            let encodedParametersHex = encodedParameters?.toHexString().withHexPrefix()
            return Call(to: contractAddress, data: encodedParametersHex)
        }
    }
    
    struct AddrResolver {
        
        static let addrFunction: ABI.Element = .function(
            ABI.Element.Function(
                name: "addr",
                inputs: [.init(name: "node", type: .bytes(length: 32))],
                outputs: [.init(name: "ens", type: .address)],
                constant: false,
                payable: false
            )
        )
        
        func addr(_ node: String, contractAddress: Address) -> Call {
            let encodedParameters = AddrResolver.addrFunction.encodeParameters([node as AnyObject])
            let encodedParametersHex = encodedParameters?.toHexString().withHexPrefix()
            return Call(to: contractAddress, data: encodedParametersHex)
        }
    }
}
