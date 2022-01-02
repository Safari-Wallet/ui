//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Nathan Clark on 9/30/21.
//

import SafariServices
import SafariWalletCore
import os.log
import Swifter

let SFExtensionMessageKey = "message"
let SFSFExtensionResponseErrorKey = "error"
 
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    let walletManager = WalletManager()
    let logger = Logger()
    let server = HttpServer()
    
    override init() {
        do {
            // http://127.0.0.1:8080/hello
            server["/hello"] = { .ok(.htmlBody("You asked for \($0)"))  }
            try server.start()
        } catch {
            print("Error starting web server: \(error)")
        }
        super.init()
    }
    
    func beginRequest(with context: NSExtensionContext) {
        
        // TODO: can we fire a timer here that keeps checks on changes (e.g. account)?
        
        Task {
            let response = NSExtensionItem()
            defer { context.completeRequest(returningItems: [response], completionHandler: nil) }

            // Sanity check
            let item = context.inputItems[0] as! NSExtensionItem
            guard let message = item.userInfo?[SFExtensionMessageKey] else {
                response.userInfo = errorResponse(error: "No message key in message or message is not a string.\(String(describing: item.userInfo))")
                logger.critical("Safari-wallet SafariWebExtensionHandler: No message key in message")
                return
            }
                        
            logger.critical("Safari-wallet SafariWebExtensionHandler: Received message from browser.runtime.sendNativeMessage: \(String(describing: message), privacy: .public)")
            
            // Parse message
            do {
                let returnValue = try await handle(message: message)
                response.userInfo = [SFExtensionMessageKey: returnValue]
                logger.critical("Safari-wallet SafariWebExtensionHandler received \(String(describing: returnValue), privacy: .public)")
            } catch {
                response.userInfo = errorResponse(error: error.localizedDescription)
                logger.critical("Safari-wallet SafariWebExtensionHandler error: \(error.localizedDescription, privacy: .public))")
            }
        }
    }
    
    fileprivate func errorResponse(error: String) -> [String: Any] {
        return [SFExtensionMessageKey: [SFSFExtensionResponseErrorKey: error]]
    }

    // MARK: - Web3 Message handling

    func handle(message: Any) async throws -> Any {
        let providerAPI = ProviderAPI(delegate: walletManager)
        // Parse method and params
        if let message = message as? String {
            return try await providerAPI.parseMessage(method: message, params: nil)
        } else if let message = message as? [String: Any] {
            guard let method = message["method"] as? String else { throw WalletError.noMethod }
            let params = message["params"]
            logger.critical("Safari-wallet SafariWebExtensionHandler: Received object with method \(method, privacy: .public) and params \(String(describing: params), privacy: .public)")
            return try await providerAPI.parseMessage(method: method, params: params)
        } else {
            throw WalletError.invalidInput(nil)
        }
    }
}
