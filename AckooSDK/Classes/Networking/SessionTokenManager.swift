//
//  SessionTokenManager.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/12/20.
//

import Foundation
func getSessionToken() -> String {
   if let token: String = UserDefaults.standard.object(forKey: Constants.SDKKeys.SessionToken) as? String {
       return token
   }
   return ""
}

func saveSessionToken(_ token: String)  {
    UserDefaults.standard.set(token, forKey:  Constants.SDKKeys.SessionToken)
    UserDefaults.standard.synchronize()
}

func deleteSessionToken()  {
    UserDefaults.standard.removeObject(forKey: Constants.SDKKeys.SessionToken)
    UserDefaults.standard.synchronize()
}
