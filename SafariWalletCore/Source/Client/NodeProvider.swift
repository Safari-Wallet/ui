//
//  ProviderBaseURL.swift
//  Wallet
//
//  Created by Ronald Mannak on 10/24/21.
//

import Foundation
import MEWwalletKit

public enum NodeProvider {
   
   case infura(key: String)
   case alchemy(key: String)
   case custom(baseURL: URL)
   
   public func baseURL(for network: Network) -> URL? {
      
      switch self {
         case .infura(key: let key):
            switch network {
               case .ethereum:
                  return URL(string: "https://mainnet.infura.io/v3/")!.appendingPathComponent(key)
               case .ropsten:
                  return URL(string: "https://ropsten.infura.io/v3/")!.appendingPathComponent(key)
               default:
                  return nil
            }
         case .alchemy(key: let key):
            switch network {
               case .ethereum:
                  return URL(string: "https://eth-mainnet.alchemyapi.io/v2/")!.appendingPathComponent(key)
               case .ropsten:
                  return URL(string: "https://eth-ropsten.alchemyapi.io/v2/")!.appendingPathComponent(key)
               default:
                  return nil
            }
         case .custom(baseURL: let url):
            return url
      }
   }
   
}
