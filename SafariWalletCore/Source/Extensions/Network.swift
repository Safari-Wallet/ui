//
//  Network.swift
//  
//
//  Created by Ronald Mannak on 11/16/21.
//

import Foundation
import MEWwalletKit



/*
 For now Safari Wallet only supports:
 - .ethereum
 - .ropsten
 - .ledgerLiveEthereum

 */

extension Network {
    
    public init(name: String) {
        
        switch name.lowercased() {
        case "bitcoin":
            self = .bitcoin
        case "litecoin":
            self = .litecoin
        case "singularDTV".lowercased():
            self = .singularDTV
        case "ropsten":
            self = .ropsten
        case "expanse":
            self = .expanse
        case "ledgerLiveEthereum".lowercased(), "Ethereum - Ledger Live".lowercased():
            self = .ledgerLiveEthereum
        case "ethereum":
            self = .ethereum
        case  "ledgerEthereum".lowercased():
            self = .ledgerEthereum
        case "keepkeyEthereum".lowercased():
            self = .keepkeyEthereum
        case "Ethereum Classic MEW Vintage".lowercased():
            self = .ledgerEthereumClassicVintage
        case "Ethereum Classic - Ledger Live".lowercased():
            self = .ledgerLiveEthereumClassic
        case "Ethereum Classic".lowercased():
            self = .ethereumClassic
        case "Mix Blockchain".lowercased():
            self = .mixBlockchain
        case "Ubiq".lowercased():
            self = .ubiq
        case "RSK Mainnet".lowercased():
            self = .rskMainnet
        case "Ellaism".lowercased():
            self = .ellaism
        case "PIRL".lowercased():
            self = .pirl
        case "Musicoin".lowercased():
            self = .musicoin
        case "Callisto".lowercased():
            self = .callisto
        case "TomoChain".lowercased():
            self = .tomoChain
        case "ThunderCore".lowercased():
            self = .thundercore
        case "Ethereum Social".lowercased():
            self = .ethereumSocial
        case "Atheios".lowercased():
            self = .atheios
        case "EtherGem".lowercased():
            self = .etherGem
        case "EOS Classic".lowercased():
            self = .eosClassic
        case "GoChain".lowercased():
            self = .goChain
        case "EtherSocial Network".lowercased():
            self = .etherSocialNetwork
        case "RSK Testnet".lowercased():
            self = .rskTestnet
        case "Akroma".lowercased():
            self = .akroma
        case "Iolite".lowercased():
            self = .iolite
        case "Ether-1".lowercased():
            self = .ether1
        case "AnonymizedId".lowercased():
            self = .anonymizedId
        case "Kovan".lowercased():
            self = .kovan
        case "Goerli".lowercased():
            self = .goerli
        case "Eth 2.0".lowercased():
            self = .eth2Withdrawal
        default:
            self = .ethereum
        }
    }
}

extension Network: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(name: string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.name.lowercased())
    }
}
