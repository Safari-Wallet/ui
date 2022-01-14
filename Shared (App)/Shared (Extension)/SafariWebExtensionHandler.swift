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
    
    let userSettings = UserSettings()
    let logger = Logger()
    
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
            
            // Validate incoming message
            
            guard let method = message["method"] as? NativeMessageMethod else { throw WalletError.noMethod }
            guard let params = message["params"] as? String else { throw WalletError.invalidInput("Missing params property")}
            
            JSONEncoder().encode(params)
            
//            given some method, get the corresponding type for that method (eg EthGetBalanceMessage)
//            given the type, instantiate a new message of that type with the method and params (eg EthGetBalanceMessage())
            
            var msg: FrontendMessage
            switch msg {
            case "helloFren":
                msg = HelloFrenMessage(from: params)
            default:
                throw WalletError.invalidInput("Unknown method type \(method)")
            }
            
            
            
//            let parsedMessage = validateParams(method: method, params: params)
                        
            logger.critical("Safari-wallet SafariWebExtensionHandler: Received message from browser.runtime.sendNativeMessage: \(String(describing: message), privacy: .public)")
            
            // Parse message
            do {
                let returnValue = try await handle(message: msg)
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

    func validateParams<T>(method: NativeMessageMethod, params: String) throws -> T {
        switch method {
        case NativeMessageMethod.eth_getAccounts:
            return try EthGetAccountsMessage(serializedMessageJson)
        case NativeMessageMethod.eth_getBalance:
            return try EthGetBalanceMessage(serializedMessageJson)
        case NativeMessageMethod.helloFren:
            return try HelloFrenMessage(serializedMessageJson)
        default:
            throw WalletError.invalidInput("Unknown method '\(method)'")
        }
    }
    
    func handle(message: Any) async throws -> Any {
        let providerAPI = ProviderAPI(delegate: userSettings)
        
        if let parsedMessage = message as? [String: Any] {
            guard let jsonMessage = JSONEncoder().encode(message) else  { throw WalletError.invalidInput("Unparsable JSON input") }
            guard let method = parsedMessage["method"] as? String else { throw WalletError.noMethod }
            
            let validatedMessage: Any
            
            switch method {
            case "eth_getAccounts":
                validatedMessage = try EthGetAccountsMessage(jsonMessage)
            case "eth_getBalance":
                validatedMessage = try EthGetBalanceMessage(jsonMessage)
            default:
                throw WalletError.invalidInput("Unknown method '\(method)'")
            }
            
            logger.critical("Safari-wallet SafariWebExtensionHandler: Received object with method \(method, privacy: .public) and params \(String(describing: validatedMessage.params), privacy: .public)")
            
            return try await providerAPI.parseMessage(method: method, params: validatedMessage.params)
        } else {
            throw WalletError.invalidInput(nil)
        }
    }
}
