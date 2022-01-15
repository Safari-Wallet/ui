//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Nathan Clark on 9/30/21.
//

import SafariServices
import SafariWalletCore
import os.log

let SFExtensionMessageKey = "message"
let SFSFExtensionResponseErrorKey = "error"

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    let logger = Logger()
    let userSettings = UserSettings()
    
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
            
            // Validate incoming message
            
            if let message = message as? [String: Any] {
                guard (message["method"] as? NativeMessageMethod) != nil else { throw WalletError.noMethod }
                guard (message["params"] as? [String: Any]) != nil else { throw WalletError.invalidInput("Missing params property")}
                
                do {
                    let returnValue = try await handle(message)
                    response.userInfo = [SFExtensionMessageKey: returnValue]
                    logger.critical("Safari-wallet SafariWebExtensionHandler received \(String(describing: returnValue), privacy: .public)")
                } catch {
                    response.userInfo = errorResponse(error: error.localizedDescription)
                    logger.critical("Safari-wallet SafariWebExtensionHandler error: \(error.localizedDescription, privacy: .public))")
                }
            }
        }
    }
    
    fileprivate func errorResponse(error: String) -> [String: Any] {
        return [SFExtensionMessageKey: [SFSFExtensionResponseErrorKey: error]]
    }

    // MARK: - Web3 Message handling

    // TODO: can we be more explicit about the params errors?
    func handle(_ message: [String: Any]) async throws -> Any {
        let parsedParams = try parseMessageParams(message: message)
        return try await parsedParams.execute(with: userSettings)
    }
}
