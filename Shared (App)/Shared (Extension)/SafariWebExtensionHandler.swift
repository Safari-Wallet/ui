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
    var server: HttpServer? = HttpServer()
    
    override init() {
        logger.critical("Safari-wallet SafariWebExtensionHandler: Handler init")
        
        // If developer mode is enabled and extension is running in the simulator, load http server
        // http://127.0.0.1:8080
        #if targetEnvironment(simulator)
        if let sharedContainer = UserDefaults(suiteName: APP_GROUP), let _ = sharedContainer.object(forKey: "DevMode"), sharedContainer.bool(forKey: "DevMode") == true {
            do {
                if let server = server {
                    server["/"] = { .ok(.htmlBody("You asked for \($0)"))  }
                    try server.start()
                    logger.critical("Safari-wallet SafariWebExtensionHandler: http server started")
                }
            } catch {
                logger.critical("Safari-wallet SafariWebExtensionHandler: Error staring http server: \(error.localizedDescription)")
                server = nil // deallocate http server
            }
        }
        #else
        logger.critical("Safari-wallet SafariWebExtensionHandler: init not in simulator")
        #endif
        super.init()
    }
    
    deinit {
        logger.critical("Safari-wallet SafariWebExtensionHandler: Handler deinit")
//        server.stop() Keep the http server running
    }

    func beginRequest(with context: NSExtensionContext) {
        
        // TODO: can we fire a timer here that keeps checks on changes (e.g. account)?
        
        Task {
            let response = NSExtensionItem()
            defer { context.completeRequest(returningItems: [response], completionHandler: nil) }

            // Sanity check
            let item = context.inputItems[0] as! NSExtensionItem
            guard let message = item.userInfo?[SFExtensionMessageKey] else {
                response.userInfo = errorResponse(error: "No message key in message.\(String(describing: item.userInfo))")
                logger.critical("Safari-wallet SafariWebExtensionHandler: No message key in message")
                return
            }
                        
            logger.critical("Safari-wallet SafariWebExtensionHandler: Received message from browser.runtime.sendNativeMessage: \(String(describing: message))")
            
            // Parse message
            do {
                let returnValue = try await handle(message: message)
                response.userInfo = [SFExtensionMessageKey: returnValue]
                logger.critical("Safari-wallet SafariWebExtensionHandler received \(String(describing: returnValue))")
            } catch WalletError.noMethod {
                response.userInfo = errorResponse(error: "No method found")
            } catch WalletCoreError.noParameters {
                response.userInfo = errorResponse(error: "Missing paramaters")
            } catch WalletError.invalidInput {
                response.userInfo = errorResponse(error: "Error parsing input")
            } catch WalletCoreError.noClient {
                response.userInfo = errorResponse(error: "No Client")
            } catch {
                response.userInfo = errorResponse(error: error.localizedDescription)
//                logger.critical("Safari-wallet SafariWebExtensionHandler error: \(error.localizedDescription))")
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
            return try await providerAPI.parseMessage(method: method, params: params)
        } else {
            throw WalletError.invalidInput
        }
    }
}
