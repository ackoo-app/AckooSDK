//
//  Constants.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//

import Foundation
class Constants {
    struct SDKKeys {
        static let SessionToken: String = "AckooSDKSessionToken"
    }
    struct ErrorMessages {
        static let noInternent: String = "Internet not reachable"
        static let failedErrorParsing: String = "failed to parse error"
        static let failedResponseParsing: String = "failed to parse response"
    }
    
    static let baseURL = "https://api.ackoo.app/"
    static let tokenQueryKey = "session-token"
    
    struct URLPaths {
        static let track: String = "partner/track"
        static let identify: String = "partner/identify"
        static let fingerprint: String = "partner/fingerprint"
    }

}
