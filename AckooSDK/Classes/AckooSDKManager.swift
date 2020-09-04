//
//  AckooSDKManager.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation
import UIKit

/// Type of the event that AckooSDK supports. Which will be sent
/// When usere performs the particular action (like register, open app, login, purchase)
public enum AckooEventTypeString:String,Encodable {
    
    /// when user logs-in in the app
    case login = "PARTNER_APP_LOGIN"
    
    /// When user make the actual purchase of the item
    case purchase = "PARTNER_APP_PURCHASE"
}

 public enum AckooEventType: Int,Encodable {
    case login,purchase
}

/// AckooSDKManager class to report all activity to backend
/// Description

public class AckooSDKManager:NSObject {
    // MARK: -
    // MARK: - Properties
    
    /// The shared singleton AckooSDKManager object
    /// Which will be used report related activity to the backend.
    private static var sharedManager: AckooSDKManager = {
        let sdkManager = AckooSDKManager()
        return sdkManager
    }()
    public class func initaliseSharedInstance(appToken:String) {
        AckooSDKManager.shared().appToken = appToken;
    }
    private var isUserActive:Bool = false
    private var appToken:String = ""

    /// Initialization
    private override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
               notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    // MARK: - Accessors
    /// access shared singleton object
     public class func shared() -> AckooSDKManager {
        // get token in the background here
        
        return sharedManager
    }
    @objc func appMovedToForeground() {
        self.validateAckooSession { (succeeded, response) in
            print(response)
        }
    }

    public func continueActivity(userActivity:NSUserActivity) {
          if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                  if let url = userActivity.webpageURL {
                  let params:[String:String] = url.queryParams()
                    if let sessionToken:String = params["sessionToken"] {
                        self.enableSDK(sessionToken: sessionToken);
                        self.validateAckooSession {
                            print($0, $1)
                        }
                    }
            }

        }
    }
    
    
    public func identify(id: String, user: [String: String], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        var updatedUser = user;
        updatedUser["userId"] = id;
        let payload = Payload(name: .login, props: updatedUser);
        if self.isUserActive {
            // No need to do anything
            self.sendEventToServer(payload: payload, callback: callback)
        } else {
            self.validateAckooSession { (succeeded, response) in
                if succeeded {
                    self.sendEventToServer(payload: payload, callback: callback)
                } else {
                    //Session not found
                    callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.SESSION_NOT_VALID])
                }
            }
        }
    }
    /// Report user activity to Ackoo backend
    /// - Attention: callback will be always called on the main thread.
    /// - Parameters:
    ///   - type: type of event
    ///   - activity: activity class that holds relevant information like token, email address
    ///   - callback: call back with server response or error.
    
    public func reportActivity(type:AckooEventType, callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let payload = Payload(name: getEventTypeName(event:type), props: ["a": "b"]);
        
        // Check if token is acquired
        if !self.isUserActive {
            // No need to do anything
            self.sendEventToServer(payload: payload, callback: callback)
        } else {
            self.validateAckooSession { (succeeded, response) in
                if succeeded {
                    self.sendEventToServer(payload: payload, callback: callback)
                } else {
                    //Session not found
                    callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.SESSION_NOT_VALID])
                }
            }
        }
    }
    
    /// Checks if user is valid or not
    /// - Parameters:
    ///   - callback: call back with true or false
    
    public func isUserValidForSDK() -> Bool {
        return self.isUserActive
    }
    
    func enableSDK(sessionToken:String) {
        UserDefaults.standard.set(sessionToken, forKey: Constants.SDK_KEYS.SESSION_TOKEN)
        UserDefaults.standard.synchronize()
        isUserActive = true
    }
    func disbaleSDK() {
        UserDefaults.standard.removeObject(forKey: Constants.SDK_KEYS.SESSION_TOKEN);
        isUserActive = false
    }
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    /// Report user purchase activity to Ackoo backend
   /// - Attention: callback will be always called on the main thread.
   /// - Parameters:
   ///   - order: order class that holds the reported purchase information
   ///   - callback: call back with server response or error.
     public func reportPurchase(order:Order,callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let payload = Payload(name: .purchase, props: order.toDict());
           // Check if token is acquired
        if !self.isUserActive {
                // report event to server directly
                self.sendEventToServer(payload: payload, callback: callback)
           } else {
               self.validateAckooSession { (succeeded, response) in
                   if succeeded {
                    self.sendEventToServer(payload: payload, callback: callback)
                   } else {
                       //Session not found
                       callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.SESSION_NOT_VALID])
                   }
                   
               }
           }
       }
    
    private func sendEventToServer(payload: Payload, callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let requestURL = Constants.URL_PATHS.TRACK
       do {
       let jsonData = try JSONEncoder().encode(payload)
           NetworkingManager.sharedInstance.postRequest(jsonData, url: requestURL, callback: {(_ succeeded: Bool, _ response: Any) -> Void in
               DispatchQueue.main.async(execute: {() -> Void in
                   callback(succeeded, response)
               })
           })
       }
       catch {
           callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.INVALID_REQUEST])
       }
    }
    private func getEventTypeName(event:AckooEventType) -> AckooEventTypeString {
        switch event {
        case .login:
            return .login
        case .purchase:
            return .purchase
        }
    }
    
    private func validateAckooSession(callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        self.getTokenFromServer { (succeeded, response) in
            if let response:[String:Any] =  response as? [String:Any] ,let responseDict:[String:Any] = response["data"] as? [String:Any], let sessionToken:String = responseDict["sessionToken"] as? String {
                self.enableSDK(sessionToken: sessionToken)
            } else {
                self.disbaleSDK()
            }
            callback(succeeded,response)
        }
    }
  
    private func getTokenFromServer(callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let identity:UserIdentity = UserIdentity()
        let requestURL = Constants.URL_PATHS.FINGERPRINT
        
        do {
            let jsonData:Data = try JSONEncoder().encode(identity)
            //print(String(decoding: jsonData, as: UTF8.self))
            NetworkingManager.sharedInstance.postRequest(jsonData, url: requestURL, callback: {(_ succeeded: Bool, _ response: Any) -> Void in
                // set token here
                callback(succeeded, response)
                
            })
        }
        catch {
            print("Error in retrieving token")
            callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.INVALID_REQUEST])
        }
    }
}
