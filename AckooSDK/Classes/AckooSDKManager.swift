//
//  AckooSDKManager.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation
import AdSupport

/// Type of the event that AckooSDK supports. Which will be sent
/// When usere performs the particular action (like register, open app, login, purchase)
public enum AckooEventType {
    /// When user installs application
    case installApp
    
    /// When user opens app
    case openApp
    
    /// When user registers itself with the system
    case register
    
    /// when user logs-in in the app
    case login
    
    /// When user make the actual purchase of the item
    case purchase
}


/// AckooSDKManager class to report all activity to backend
public class AckooSDKManager {
    // MARK: -
    // MARK: - Properties
    
    /// The shared singleton AckooSDKManager object
    /// Which will be used report related activity to the backend.
    private static var sharedManager: AckooSDKManager = {
        let sdkManager = AckooSDKManager(baseURL: URL(string: "")!)
        // Configuration
        // initalise Network manger with Base URL
        
        return sdkManager
    }()
    private var fingerPrintingParam:FingerPrintingOption = FingerPrintingOption()

    private let baseURL: URL

    /// Initialization
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
    // MARK: - Accessors
    /// access shared singleton object
    public class func shared() -> AckooSDKManager {
        return sharedManager
    }
    
    /// Report user activity to Ackoo backend
    /// - Attention: callback will be always called on the main thread.
    /// - Parameters:
    ///   - type: type of event
    ///   - activity: activity class that holds relevant information like token, email address
    ///   - callback: call back with server response or error.
    public func reportActivity(type:AckooEventType,activity:UserActivity,callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void) {
        let requestURL = "UserActivity"
        
        let jsonData = try! JSONEncoder().encode(activity)
        NetworkingManager.sharedInstance.postRequest(jsonData, url: requestURL, callback: {(_ succeeded: Bool, _ response: Any) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                callback(succeeded, response)
            })
        })
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
        identity.fingerPrintingParam = self.getDevicInfo()
        return identity
    }

}
