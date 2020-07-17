//
//  UserActivity.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation


/// User activity that holds information regarding user's actions
@objc(UserActivity)
public class UserActivity:BaseActivity {
    
    /// unique token that associated with user
    var token:String
    
    /// wether user is logged In at the time of performing this activity
    var isLoggedIn:Bool
    
    /// email address of the user
    var email:String?
    

    /// UserActivity Initializer
    /// - Parameters:
    ///   - isLoggedIn: wether user is logged In at the time of performing this activity
    ///   - email: email address of the user
    ///   - order: Order details
    @objc
    public init(isLoggedIn:Bool,email:String?) {
        self.token = UserActivity.getToken()
        self.isLoggedIn = isLoggedIn
        self.email = email
        
        super.init()
    }
    static func getToken() -> String {
        if let token:String = UserDefaults.standard.object(forKey: Constants.SDK_KEYS.TOKEN_SESSION) as? String {
            return token
        }
        return ""
    }
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
   
}
