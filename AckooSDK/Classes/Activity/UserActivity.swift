//
//  UserActivity.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation


/// User activity that holds information regarding user's actions
public class UserActivity:BaseActivity {
    
    /// unique token that associated with user
    let token:String
    
    /// wether user is logged In at the time of performing this activity
    var isLoggedIn:Bool
    
    /// email address of the user
    var email:String?
    
    
    /// Order details
    var orderDetail:Order?
    
    /// UserActivity Initializer
    /// - Parameters:
    ///   - token: unique token that associated with user
    ///   - isLoggedIn: wether user is logged In at the time of performing this activity
    ///   - email: email address of the user
    ///   - order: Order details
    init(token:String,isLoggedIn:Bool,email:String?,order:Order?) {
        
        self.token = token
        self.isLoggedIn = isLoggedIn
        self.email = email
        self.orderDetail = order
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
   
}
