//
//  AckooSDKManager.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation
import AdSupport
import UIKit

/// Type of the event that AckooSDK supports. Which will be sent
/// When usere performs the particular action (like register, open app, login, purchase)
public enum AckooEventTypeString:String,Encodable {
    /// When user installs application
    case installApp = "INSTALL"
    
    /// When user opens app
    case openApp = "APP_OPEN"
    
    /// When user registers itself with the system
    case register = "USER_REGISTER"
    
    /// when user logs-in in the app
    case login = "USER_LOGIN"
    
    /// When user make the actual purchase of the item
    case purchase = "PURCHASE"
}

@objc public enum AckooEventType: Int,Encodable {
    case installApp, openApp, register,login,purchase
}

/// AckooSDKManager class to report all activity to backend
@objc(AckooSDKManager)
public class AckooSDKManager:NSObject {
    // MARK: -
    // MARK: - Properties
    
    /// The shared singleton AckooSDKManager object
    /// Which will be used report related activity to the backend.
    private static var sharedManager: AckooSDKManager = {
        let sdkManager = AckooSDKManager(baseURL: URL(string: NetworkingManager.sharedInstance.getApiBaseUrl(buildMode: BUILD_MODE))!)
        UIDevice.current.isBatteryMonitoringEnabled = true
        return sdkManager
    }()
    private var fingerPrintingParam:FingerPrintingOption = FingerPrintingOption()

    private let baseURL: URL

    /// Initialization
    private init(baseURL: URL) {
       
        self.baseURL = baseURL
         super.init()
        let notificationCenter = NotificationCenter.default
               notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    // MARK: - Accessors
    /// access shared singleton object
    @objc public class func shared() -> AckooSDKManager {
        // get token in the background here
        
        return sharedManager
    }
    @objc func appMovedToForeground() {
        self.getTokenFromServer { (succeeded, response) in
            print(response)
            if let responseDict:[String:Any] = response as? [String:Any], let sessionToken:String = responseDict["sessionToken"] as? String {
                self.storeSessionInUserDefault(sessionToken: sessionToken)
            }
        }
    }
    /// Report user activity to Ackoo backend
    /// - Attention: callback will be always called on the main thread.
    /// - Parameters:
    ///   - type: type of event
    ///   - activity: activity class that holds relevant information like token, email address
    ///   - callback: call back with server response or error.
    @objc
    public func reportActivity(type:AckooEventType,activity:UserActivity,callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        
        // Check if token is acquired
        if !activity.token.isEmpty {
            // No need to do anything
            self.makeAnActualApiCall(type: type, activity: activity, order: nil, callback: callback)
        } else {
            self.getTokenFromServer { (succeeded, response) in
                print(response)
                if let responseDict:[String:Any] = response as? [String:Any], let sessionToken:String = responseDict["sessionToken"] as? String {
                    activity.token = sessionToken
                    self.storeSessionInUserDefault(sessionToken: sessionToken)
                    self.makeAnActualApiCall(type: type, activity: activity, order: nil, callback: callback)
                } else {
                    //Session not found
                    callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.SESSION_NOT_VALID])
                }
            }
        }
        
        
       
    }
    
    
    func storeSessionInUserDefault(sessionToken:String) {
        UserDefaults.standard.set(sessionToken, forKey: Constants.SDK_KEYS.TOKEN_SESSION)
        UserDefaults.standard.synchronize()
    }
    
    /// Report user purchase activity to Ackoo backend
       /// - Attention: callback will be always called on the main thread.
       /// - Parameters:
       ///   - type: type of event
       ///   - activity: activity class that holds relevant information like token, email address
       ///   - callback: call back with server response or error.
    @objc public func reportPurchase(type:AckooEventType,activity:UserActivity,order:Order,callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
           
           // Check if token is acquired
           if !activity.token.isEmpty {
               // No need to do anything
            self.makeAnActualApiCall(type: type, activity: activity, order: order, callback: callback)
           } else {
               self.getTokenFromServer { (succeeded, response) in
                   print(response)
                   if let responseDict:[String:Any] = response as? [String:Any], let sessionToken:String = responseDict["sessionToken"] as? String {
                       activity.token = sessionToken
                       UserDefaults.standard.set(sessionToken, forKey: Constants.SDK_KEYS.TOKEN_SESSION)
                       UserDefaults.standard.synchronize()
                    self.makeAnActualApiCall(type: type, activity: activity, order: order, callback: callback)
                   } else {
                       //Session not found
                       callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.SESSION_NOT_VALID])
                   }
                   
               }
           }
       }
    
    private func makeAnActualApiCall(type:AckooEventType,activity:UserActivity,order:Order?,callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let requestURL = "events"
        let payLoad:Payload
        if (type == .purchase) {
            let payLoadProperty:PayloadProperty = PayloadProperty(order: order, activity: activity)
            payLoad = Payload(type: getEventTypeInt(event: type), payload: payLoadProperty)
        } else {
            let payLoadProperty:PayloadProperty = PayloadProperty(order: nil, activity: activity)
            payLoad = Payload(type: getEventTypeInt(event: type), payload: payLoadProperty)
        }
       do {
       let jsonData = try JSONEncoder().encode(payLoad)
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
    private func getEventTypeInt(event:AckooEventType) -> AckooEventTypeString {
        switch event {
        case .installApp:
            return .installApp
        case .openApp:
            return .openApp
        case .register:
            return .register
        case .login:
            return .login
        case .purchase:
            return .purchase
        }
    }
    private func getIDFAOfDevice() -> String {
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    private func getDevicInfo() -> FingerPrintingOption {
        return self.fingerPrintingParam
    }
    
    private func getUserIdentity() -> UserIdentity {
        let identity:UserIdentity = UserIdentity(idfaUuidString: self.getIDFAOfDevice())
        identity.fingerprint = self.getDevicInfo()
        return identity
    }
    private func getTokenFromServer(callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let identity:UserIdentity = self.getUserIdentity()
            
        let requestURL = "users/partner/fingerprint"
        
        do {
            let jsonData:Data = try JSONEncoder().encode(identity)
            //print(String(decoding: jsonData, as: UTF8.self))
            NetworkingManager.sharedInstance.postRequest(jsonData, url: requestURL, callback: {(_ succeeded: Bool, _ response: Any) -> Void in
                // set token here
                print(response)
                callback(succeeded, response)
                
            })
        }
        catch {
            print("Error in retrieving token")
            callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.INVALID_REQUEST])
        }
    }

}
