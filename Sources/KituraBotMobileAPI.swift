//
//  KituraBotMobileAPI.swift
//  KituraBotMobileAPI
//
//  Created by Jacopo Mangiavacchi on 10/3/16.
//
//

import Foundation
import SwiftyJSON
import Kitura
import KituraRequest
import LoggerAPI
import KituraBot


// MARK KituraBotMobileAPI

/// Implement Facebook Messenger Bot Webhook.
/// See [Facebook's documentation](https://developers.facebook.com/docs/messenger-platform/implementation#subscribe_app_pages)
/// for more information.
public class KituraBotMobileAPI : KituraBotProtocol {
    public var channelName: String?
    public var botProtocolMessageNotificationHandler: BotInternalMessageNotificationHandler?

    public let securityToken: String
    public let webHookPath: String
    
    /// Initialize a `KituraBotMobileAPI` instance.
    ///
    /// - Parameter appSecret: App Secret can be retrieved from the App Dashboard.
    /// - Parameter validationToken: Arbitrary value used to validate a webhook.
    /// - Parameter pageAccessToken: Generate a page access token for your page from the App Dashboard.
    /// - Parameter webHookPath: URI for the webhook.
    public init(securityToken: String, webHookPath: String) {
        self.securityToken = securityToken
        self.webHookPath = webHookPath
    }
    
    public func configure(router: Router, channelName: String, botProtocolMessageNotificationHandler: @escaping BotInternalMessageNotificationHandler) {
        self.channelName = channelName
        self.botProtocolMessageNotificationHandler = botProtocolMessageNotificationHandler
        
        router.post(webHookPath, handler: processRequestHandler)
    }
    
    //Send a text message using the internal Send API.
    public func sendTextMessage(recipientId: String, messageText: String, context: [String: Any]?) {

        Log.debug("PUSH not yet implemented!!!")
        print("PUSH not yet implemented!!!")
    
    }
    
    
    //PRIVATE REST API Handlers
    
    /// Exposed API to Send Message to the Bot client.
    /// Used from the Mobile App.
    ///
    /// INPUT JSON Payload
    /// {
    ///     "senderID" : "xxx",
    ///     "messageText" : "xxx",
    ///     "securityToken" : "xxx"
    ///     "context" : {}
    /// }
    ///
    /// OUTPUT JSON Payload
    /// {
    ///     "responseMessage" : "xxx",
    ///     "context" : {}
    /// }
    private func processRequestHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("POST - process Bot request message from KituraBotMobileAPI")
        print("POST - process Bot request message from KituraBotMobileAPI")
        
        var data = Data()
        if try request.read(into: &data) > 0 {
            let json = JSON(data: data)
            if let senderID = json["senderID"].string, let msgText = json["messageText"].string, let accessToken = json["securityToken"].string {
                guard accessToken == securityToken else {
                    try response.status(.forbidden).end()
                    return
                }
                
                let context = json["context"].dictionaryObject
                
                if let (responseMessage, responseContext) = botProtocolMessageNotificationHandler?(channelName!, senderID, msgText, context) {
                    //Send JSON response for responseMessage
                    var jsonResponse = JSON([:])
                    jsonResponse["responseMessage"].stringValue = responseMessage

                    jsonResponse["context"].dictionaryObject = responseContext
                    
                    try response.status(.OK).send(json: jsonResponse).end()
                }
                else {
                    try response.status(.OK).end()
                }

                return
            
            } else {
                Log.debug("Webhook received NO Valid data")
                print("Webhook received NO Valid data")
            }
        }
        
        try response.status(.notAcceptable).end()
    }

}


