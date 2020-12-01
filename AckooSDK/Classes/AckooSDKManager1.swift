//
//  AckooSDKManager1.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/1/20.
//

import Foundation
import UIKit

@objc public protocol AckooSDKType1 {
    func initSession()
    func continueActivity(userActivity: NSUserActivity)
    func identify(id: String, profile: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void)
    func trackViewItem(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void)
    func trackCheckout(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: Any) -> Void)
    func getSessionToken(callback: @escaping (_ sessionToken: String?, _ error: Any?) -> Void)
}


public enum AckooActivationState1 {
    case active(sessionToken: String)
    case inactive(error: AckooError)
}

/// AckooSDKManager class to report all activity to backend
/// Description
@objc
public class AckooSDKManager1: NSObject, AckooSDKType1 {
    private var activationState: AckooActivationState1?
    public static let shared = AckooSDKManager1()
    
    private override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    @objc func appMovedToForeground() {
        self.validateAckooSession { (data, error) in
            if let data = data{
                print(data)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    private func validateAckooSession(callback: @escaping (_ data: SessionTokenModel?, _ error:AckooError?) -> Void) {
        let identity: UserIdentity = UserIdentity()
        let requestURL = Constants.URL_PATHS.FINGERPRINT
        
        let factory = AckooRequestFactory()
        let request = factory.createRequest(apiMethod: Constants.baseURL + requestURL, httpMethod: .post, parameters: identity.dictionary, headers: baseHeaders())
        getData(request: request, cachingPolicy: SessionTokenPolicy()) {  [weak self] (data: SessionTokenModel) in
            if let token = data.data?.sessionToken {
                self?.activationState = .active(sessionToken: token)
            }
            callback(data  , nil)
        } failed: { [weak self] (error) in
            self?.activationState = .inactive(error: error)
            callback(nil, error)
        }
        
        
    }
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    public func initSession() {
        
    }
    
    public func continueActivity(userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let params: [String: String] = url.queryParams()
                if let sessionToken: String = params[Constants.tokenQueryKey] {
                    UserDefaultCache.shared.saveObject(with: Constants.tokenQueryKey, object: sessionToken)
                    self.validateAckooSession { (data, error) in
                        if let data = data{
                            print(data)
                        } else if let error = error {
                            print(error)
                        }
                    }
                    
                }
            }
        }
    }
    
    public func identify(id: String, profile: [String : Any], callback: @escaping (Bool, Any) -> Void) {
        var updatedUser = profile
        updatedUser["userId"] = id
        if checkStateIsActive().0 == true {
            let requestURL = Constants.URL_PATHS.IDENTIFY
            let factory = AckooRequestFactory()
            let request = factory.createRequest(apiMethod: Constants.baseURL + requestURL, httpMethod: .post, parameters: updatedUser, headers: baseHeaders())
            getData(request: request, cachingPolicy: SessionTokenPolicy()) {(data: SessionTokenModel) in
                callback(true , data)
            } failed: {  (error) in
                callback(false , error)

            }
            
        }else{
            callback(false , checkStateIsActive().1 ?? AckooError(error: LocalError.unknown))
        }
        
    }
    
    public func trackViewItem(_ props: [String : Any], callback: @escaping (Bool, Any) -> Void) {
        let payload: [String: Any] = ["name": "VIEW_ITEM", "props": props]
        if checkStateIsActive().0 == true {
            let requestURL = Constants.URL_PATHS.TRACK
            let factory = AckooRequestFactory()
            let request = factory.createRequest(apiMethod: Constants.baseURL + requestURL, httpMethod: .post, parameters: payload, headers: baseHeaders())
            getData(request: request, cachingPolicy: SessionTokenPolicy()) {(data: SessionTokenModel) in
                callback(true , data)
            } failed: {  (error) in
                callback(false , error)

            }
            
        }else{
            callback(false , checkStateIsActive().1 ?? AckooError(error: LocalError.unknown))
        }
        
    }
    
    public func trackCheckout(_ props: [String : Any], callback: @escaping (Bool, Any) -> Void) {
        
        
    }
    
    public func getSessionToken(callback: @escaping (String?, Any?) -> Void) {
        
    }
    
    
    private func checkStateIsActive() -> (Bool , AckooError?){
        if let activationState = activationState  {
            switch activationState {
            case .active(sessionToken: _):
              return  (true , nil)
            case .inactive(error: let error):
                return  (false , error)
                
            }
        }
        return  (false , AckooError(error: LocalError.unknown))

    }
    
    
}
