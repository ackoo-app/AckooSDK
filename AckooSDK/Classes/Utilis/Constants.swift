//
//  Constants.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//

import Foundation


class Constants {
    
    
    struct RESPONSE_KEYS {
        static let NEW_ERROR_MESSAGE:String = "Message"
    }
    struct SDK_KEYS {
        static let SESSION_TOKEN:String = "AckooSDKSessionToken"
    }
    struct ENGLISH {
        
        static let NO_INTERNET_MESSAGE:String = "Internet not reachable"
        static let INVALID_REQUEST:String = "Host is invalid"
        static let SESSION_NOT_VALID:String = "User is not a valid Ackoo user"
    }
    struct URL_PATHS {
        static let TRACK:String = "partner/track"
        static let FINGERPRINT:String = "partner/fingerprint"
    }
    

}
