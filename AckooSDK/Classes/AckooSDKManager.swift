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

public enum AckooActivationState {
    case active(sessionToken: String), inactive(errorCode: String, errorMessage: String)
}

struct ServerError: Codable {
    var code: String;
    var message: String;
}

struct ServerResponse: Codable {
    var ok: Bool;
    var data: [String: String]?;
    var error: ServerError?;
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
    public func initSession() {
        
    }
    private var activationState:AckooActivationState?;

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
                        storeSessionToken(sessionToken: sessionToken)
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
        
        guard let activationState = self.activationState else {
            callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.SESSION_NOT_VALID])
            return;
        }
        if case .active(_) = activationState {
           self.sendEventToServer(payload: payload, callback: callback)
        } else {
            callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.SESSION_NOT_VALID])
                
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
        if self.activationState != nil {
            // No need to do anything
            self.sendEventToServer(payload: payload, callback: callback)
        } else {
            self.validateAckooSession { (succeeded, response) in
                if succeeded {
                    self.sendEventToServer(payload: payload, callback: callback)
                } else {
                    //Session not found
                    callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.SESSION_NOT_VALID])
                }
            }
        }
    }
    
    /// Checks if user is valid or not
    /// - Parameters:
    ///   - callback: call back with true or false
    
    public func isUserValidForSDK(callback: @escaping (_ activationState: AckooActivationState) -> Void) {
        if let activationState = self.activationState {
             callback(activationState)
        } else {
            validateAckooSession() {_,_ in
                callback(self.activationState!);
            }
        }
    }
    
    func storeSessionToken(sessionToken:String) {
        UserDefaults.standard.set(sessionToken, forKey: Constants.SDK_KEYS.SESSION_TOKEN)
        UserDefaults.standard.synchronize()
    }
//    func disbaleSDK() {
//        UserDefaults.standard.removeObject(forKey: Constants.SDK_KEYS.SESSION_TOKEN);
//        isUserActive = false
//    }
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
        if self.activationState != nil {
                // report event to server directly
                self.sendEventToServer(payload: payload, callback: callback)
           } else {
               self.validateAckooSession { (succeeded, response) in
                   if succeeded {
                    self.sendEventToServer(payload: payload, callback: callback)
                   } else {
                       //Session not found
                       callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.SESSION_NOT_VALID])
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
           callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.INVALID_REQUEST])
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
                do {
                    let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: JSONSerialization.data(withJSONObject: response));
                    
                    if serverResponse.ok {
                        let sessionToken = serverResponse.data!["sessionToken"];
                        self.activationState = .active(sessionToken: sessionToken!)
                        callback(true, "");
                    } else {
                        let errorCode = serverResponse.error!.code;
                        let errorMessage = serverResponse.error!.message;
                        self.activationState = .inactive(errorCode: errorCode, errorMessage: errorMessage);
                        callback(true, "");
                    }
                } catch {
                    self.activationState = .inactive(errorCode: "SERIALIZATION_ERROR", errorMessage: "backend response structure changed");
                    callback(succeeded,response)
                }
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
            callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.INVALID_REQUEST])
        }
    }
}
