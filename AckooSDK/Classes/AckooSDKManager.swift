//
//  AckooSDKManager1.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/1/20.
//

import Foundation
import UIKit

@objc public protocol AckooSDKType {
    func initSession(_ logLevel: AckooLogLevel)
    func continueActivity(userActivity: NSUserActivity)
    func identify(id: String, profile: [String: Any], callback: @escaping (_ succeeded: Bool, _ erorr: AckooError?) -> Void)
    func trackViewItem(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: AckooError?) -> Void)
    func trackAddToCart(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: AckooError?) -> Void)
    func trackCheckout(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ response: AckooError?) -> Void)
    func getSessionToken(callback: @escaping (_ sessionToken: String?, _ error: AckooError?) -> Void)
}

@objc public enum AckooLogLevel : Int{
    case critical = 0
    case debug
    case none
}
public enum AckooActivationState {
    case active(sessionToken: String)
    case inactive(error: AckooError)
}

/// AckooSDKManager class to report all activity to backend
/// Description
@objc
public class AckooSDKManager: NSObject, AckooSDKType {
    private var activationState: AckooActivationState?
    public static let shared = AckooSDKManager()
    private var logLevel: AckooLogLevel!
    private var baseUrl: String = Constants.baseURL;
    
    private override init() {
        super.init();
        surviveInstallation();
    }
    
    func surviveInstallation() {
       let isAckooAlreadyInstalled = UserDefaults.standard.bool(forKey: "ackooAlreadyInstalled");
       if isAckooAlreadyInstalled {
           return;
       }
       UserDefaults.standard.setValue(true, forKey: "ackooAlreadyInstalled")
        retrieveSessionFromClipboard();
    }
    
    func retrieveSessionFromClipboard(){
        let pasteboard = UIPasteboard.general
        if #available(iOS 14.0, *) {
            pasteboard.detectPatterns(for: [.probableWebURL],  completionHandler: {
                result in
                switch(result) {
                case .success:
                    if let urlString = pasteboard.string {
                        if let url: URL = URL(string: urlString ) {
                                if let sessionToken: String = url.queryParams()[Constants.tokenQueryKey] {
                                    
                                    self.startSession(with: sessionToken);
                                }
                            }
                        }
                case .failure(let error):
                    print(error,logLevel:.debug);
                };
                
            })
        } else {
            if let lastCopiedString = pasteboard.string {
                if let url: URL = URL(string: lastCopiedString ) {
                        if let sessionToken: String = url.queryParams()[Constants.tokenQueryKey] {
                            self.startSession(with: sessionToken);
                        }
                    }
                }
            }
    }
    
    
    func validateAckooSession(callback: @escaping (_ data: SessionTokenModel?, _ error:AckooError?) -> Void) {
        let requestURL = Constants.URLPaths.fingerprint
        
        let factory = AckooRequestFactory()
        let request = factory.createRequest(apiMethod: self.baseUrl + requestURL, httpMethod: .post, parameters: [:], headers: baseHeaders())
            getData(request: request) {  [weak self] (data: SessionTokenModel) in
            if let token = data.data?.sessionToken {
                self?.activationState = .active(sessionToken: token)
                saveSessionToken(token)
            }
            callback(data  , nil)
        } failed: { [weak self] (error) in
            if error.code ==  SessionError.fingerprintNotFound.code ||  error.code ==  SessionError.noActiveSession.code  ||  error.code ==  SessionError.sessionTokenExpired.code {
                deleteSessionToken()
            }
            self?.activationState = .inactive(error: error)
            callback(nil, error)
        }
        
        
    }
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    public func initSession(_ logLevel: AckooLogLevel = .none) {
        self.logLevel = logLevel
    }
    public func initSession(_ logLevel: AckooLogLevel = .none, _ baseUrl: String) {
        self.logLevel = logLevel
        self.baseUrl = baseUrl;
    }
    
    public func continueActivity(userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let params: [String: String] = url.queryParams()
                if let sessionToken: String = params[Constants.tokenQueryKey] {
                    startSession(with: sessionToken);
                }
            }
        }
    }
    
    private func startSession (with sessionToken: String) {
        saveSessionToken(sessionToken)
        self.validateAckooSession { (data, error) in
            if let data = data{
                print("AckooToken\(data.data?.sessionToken ?? "")" , logLevel:.debug)
            } else if let error = error {
                print(error.description , logLevel:.debug)
            }
        }
    }
    public func identify(id: String, profile: [String : Any], callback: @escaping (Bool, AckooError?) -> Void) {
        var updatedUser = profile
        updatedUser["userId"] = id
        getActivationState { (token, error) in
            if let error = error {
                callback(false , error)
            }else{
                
                let requestURL = Constants.URLPaths.identify
                let factory = AckooRequestFactory()
                let request = factory.createRequest(apiMethod: self.baseUrl + requestURL, httpMethod: .post, parameters: updatedUser, headers: baseHeaders())
                getData(request: request) {(data: BaseModel) in
                    callback(true , nil)
                } failed: {  (error) in
                    callback(false , error)
                    
                }
            }
        }
        
        
    }
    
    public func trackViewItem(_ props: [String : Any], callback: @escaping (Bool, AckooError?) -> Void) {
        let payload: [String: Any] = ["name": "VIEW_ITEM", "props": props]
        track(payload: payload, callback: callback)
    }
    
    public func trackAddToCart(_ props: [String : Any], callback: @escaping (Bool, AckooError?) -> Void) {
        let payload: [String: Any] = ["name": "ADD_TO_CART", "props": props]
        track(payload: payload, callback: callback)
    }
    
    public func trackCheckout(_ props: [String: Any], callback: @escaping (_ succeeded: Bool, _ error: AckooError?) -> Void){
        let payload: [String: Any] = ["name": "CHECKOUT", "props": props]
        track(payload: payload, callback: callback)
    }
    
    private func track( payload: [String : Any], callback: @escaping (Bool, AckooError?) -> Void){
        getActivationState { (token, error) in
            if let error = error {
                callback(false , error)
            }else{
                let requestURL = Constants.URLPaths.track
                let factory = AckooRequestFactory()
                let request = factory.createRequest(apiMethod: self.baseUrl + requestURL, httpMethod: .post, parameters: payload, headers: baseHeaders())
                getData(request: request) {(data: BaseModel) in
                    callback(true , nil)
                } failed: {  (error) in
                    callback(false , error)
                }
            }
        }
    }
    
    public func getSessionToken(callback: @escaping (String?, AckooError?) -> Void) {
        getActivationState { (token, error) in
            callback(token , error)
        }
    }
    
    
    private func getActivationState(callback: @escaping (_ sessionToken: String?, _ error: AckooError?) -> Void){
        if let activationState = activationState  {
            switch activationState {
            case .active(sessionToken: let token):
                callback(token , nil)
            case .inactive(error: let error):
                callback(nil , error)
            }
        }else{
            validateAckooSession { (sessionToken, error) in
                callback(sessionToken?.data?.sessionToken , error)
            }
        }
        
    }
    
    
}
