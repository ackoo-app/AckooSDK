//
//  Constants.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//

import Foundation

@objc(Constants)
class Constants:NSObject {
    
    
    struct RESPONSE_KEYS {
        static let NEW_ERROR_MESSAGE:String = "Message"
    }
    struct SDK_KEYS {
        static let TOKEN_SESSION:String = "AckooSDKSession"
    }
    struct ENGLISH {
        
        static let NO_INTERNET_MESSAGE:String = "Internet not reachable"
        static let INVALID_REQUEST:String = "Host is invalid"
        static let SESSION_NOT_VALID:String = "User is not a valid Ackoo user"
    }

}
