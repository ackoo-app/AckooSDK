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

@objc
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
@objc
public class AckooSDKManager:NSObject {
    // MARK: -
    // MARK: - Properties
    
    /// The shared singleton AckooSDKManager object
    /// Which will be used report related activity to the backend.
    private static var sharedManager: AckooSDKManager = {
        let sdkManager = AckooSDKManager()
        return sdkManager
    }()
    @objc
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
    @objc
     public class func shared() -> AckooSDKManager {
        // get token in the background here
        return sharedManager
    }
    @objc func appMovedToForeground() {
        self.validateAckooSession { (succeeded, response) in
            print(response)
        }
    }
    @objc
    public func continueActivity(userActivity:NSUserActivity) {
          if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                  if let url = userActivity.webpageURL {
                  let params:[String:String] = url.queryParams()
                    if let sessionToken:String = params["session-token"] {
                        print("sessionToken", sessionToken);
                        storeSessionToken(sessionToken: sessionToken)
                        self.validateAckooSession {
                            print($0, $1)
                        }
                    }
            }
        }
    }
    @objc
    public func identify(id: String, profile: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        var updatedUser = profile;
        updatedUser["userId"] = id;
        
        guard let activationState = self.activationState else {
            callback(false, Constants.SDK_ERRORS.SDK_INACTIVE)
            return;
        }
        if case .active(_) = activationState {
           self.identifyUser(payload: updatedUser, callback: callback)
        } else {
            callback(false, Constants.SDK_ERRORS.SDK_INACTIVE)
        }
    }
    /// Report user activity to Ackoo backend
    /// - Attention: callback will be always called on the main thread.
    /// - Parameters:
    ///   - props: activity class that holds relevant information like token, email address
    ///   - callback: call back with server response or error.
    @objc
    public func trackViewItem(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let payload: [String : Any] = ["name": "VIEW_ITEM", "props": props];
        // Check if token is acquired
        if self.activationState != nil {
            // No need to do anything
            self.trackEvent(payload: payload, callback: callback)
        } else {
            self.validateAckooSession { (succeeded, response) in
                if succeeded {
                    self.trackEvent(payload: payload, callback: callback)
                } else {
                    //Session not found
                    callback(false, Constants.SDK_ERRORS.SDK_INACTIVE)
                }
            }
        }
    }
    
    @objc
    public func trackCheckout(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let payload: [String : Any] = ["name": "CHECKOUT", "props": props];
        // Check if token is acquired
        if self.activationState != nil {
            // No need to do anything
            self.trackEvent(payload: payload, callback: callback)
        } else {
            self.validateAckooSession { (succeeded, response) in
                if succeeded {
                    self.trackEvent(payload: payload, callback: callback)
                } else {
                    //Session not found
                    callback(false, Constants.SDK_ERRORS.SDK_INACTIVE)
                }
            }
        }
    }
    
    @objc
    public func trackAddToCart(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let payload: [String : Any] = ["name": "ADD_TO_CART", "props": props];
        // Check if token is acquired
        if self.activationState != nil {
            // No need to do anything
            self.trackEvent(payload: payload, callback: callback)
        } else {
            self.validateAckooSession { (succeeded, response) in
                if succeeded {
                    self.trackEvent(payload: payload, callback: callback)
                } else {
                    //Session not found
                    callback(false, Constants.SDK_ERRORS.SDK_INACTIVE)
                }
            }
        }
    }
    
    /// Checks if user is valid or not
    /// - Parameters:
    ///   - callback: call back with true or false
    
    private func isUserValidForSDK(callback: @escaping (_ activationState: AckooActivationState) -> Void) {
        if let activationState = self.activationState {
             callback(activationState)
        } else {
            validateAckooSession() {_,_ in
                callback(self.activationState!);
            }
        }
    }
    
    @objc
    public func getSessionToken(callback: @escaping (_ isActive: Bool,_ sessionToken:String?,_ error:NSError?) -> Void) {
        self.isUserValidForSDK { (state:AckooActivationState) in
            switch state {
                
            case .active(sessionToken: let sessionToken):
                callback(true,sessionToken,nil)
            case .inactive(errorCode: let errorCode, errorMessage: let errorMessage):
                let errorCodeInt:Int  = Int(errorCode) ?? 400
                let error:NSError = NSError(domain: "Ackoo.Error", code: errorCodeInt, userInfo: ["code": errorCode, "message" : errorMessage])
                callback(false,nil,error)
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
    
    private func trackEvent(payload: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let requestURL = Constants.URL_PATHS.TRACK
       do {
       let jsonData =  try JSONSerialization.data(withJSONObject: payload)
           NetworkingManager.sharedInstance.postRequest(jsonData, url: requestURL, callback: {(_ succeeded: Bool, _ response: Any) -> Void in
               DispatchQueue.main.async(execute: {() -> Void in
                if(succeeded) {
                    callback(succeeded, response)
                } else {
                    callback(succeeded, self.formatResponseToAckooError(response))
                }
               })
           })
       }
       catch {
           callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.INVALID_REQUEST])
       }
    }
    private func identifyUser(payload: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let requestURL = Constants.URL_PATHS.IDENTIFY
       do {
       let jsonData =  try JSONSerialization.data(withJSONObject: payload)
           NetworkingManager.sharedInstance.postRequest(jsonData, url: requestURL, callback: {(_ succeeded: Bool, _ response: Any) -> Void in
               DispatchQueue.main.async(execute: {() -> Void in
                if(succeeded) {
                    callback(succeeded, response)
                } else {
                    callback(succeeded, self.formatResponseToAckooError(response))
                }
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
    private func formatResponseToAckooError(_ response: Any) -> AckooSdkError {
        
        do {
            let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: JSONSerialization.data(withJSONObject: response));
            
                let errorCode = serverResponse.error!.code;
                let errorMessage = serverResponse.error!.message;
                self.activationState = .inactive(errorCode: errorCode, errorMessage: errorMessage);
                return AckooSdkError(code: errorCode, message: errorMessage);
        } catch {
            return Constants.SDK_ERRORS.BACKEND_MISMATCH;
        }
    }
    
    private func validateAckooSession(callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        self.getTokenFromServer { (succeeded, response) in
                do {
                    let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: JSONSerialization.data(withJSONObject: response));
                    
                    if serverResponse.ok {
                        let sessionToken = serverResponse.data!["sessionToken"];
                        self.activationState = .active(sessionToken: sessionToken!)
                        callback(true, sessionToken as Any);
                    } else {
                        let errorCode = serverResponse.error!.code;
                        let errorMessage = serverResponse.error!.message;
                        self.activationState = .inactive(errorCode: errorCode, errorMessage: errorMessage);
                        callback(false, AckooSdkError(code: errorCode, message: errorMessage));
                    }
                } catch {
                    self.activationState = .inactive(errorCode: "String", errorMessage: "String");
                    callback(succeeded, Constants.SDK_ERRORS.BACKEND_MISMATCH)
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
            callback(false, Constants.SDK_ERRORS.BACKEND_MISMATCH)
        }
    }
}

