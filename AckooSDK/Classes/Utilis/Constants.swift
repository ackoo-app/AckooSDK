//
//  Constants.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//

import Foundation


struct SdkError {
    var code:String;
    var message:String;
}
class Constants {
    
    struct RESPONSE_KEYS {
        static let ERROR_KEY:String = "error"
    }
    struct SDK_KEYS {
        static let SESSION_TOKEN:String = "AckooSDKSessionToken"
    }
    struct SDK_ERRORS {
        static let SDK_INACTIVE: SdkError = SdkError(code: "SDK_INACTIVE", message: "The SDK is not active")
        static let BACKEND_MISMATCH: SdkError = SdkError(code: "SDK_SERIALIZATION_ERROR", message: "backend response structure changed or unexpected")
    }
    
    struct ENGLISH {
        
        static let NO_INTERNET_MESSAGE:String = "Internet not reachable"
        static let INVALID_REQUEST:String = "Host is invalid"
        static let SESSION_NOT_VALID:String = "User is not a valid Ackoo user"
    }
    struct URL_PATHS {
        static let TRACK:String = "partner/track"
        static let IDENTIFY:String = "partner/identify"
        static let FINGERPRINT:String = "partner/fingerprint"
    }
    

}
