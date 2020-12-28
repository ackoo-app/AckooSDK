//
//  SessionError.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/13/20.
//

import Foundation
enum SessionError: Error {
    case sessionTokenExpired
    case sessionTokenNotRecongized
    case validationError
    case fingerprintNotFound
    case noActiveSession
}

extension SessionError {
    var code: String {
        switch self {
        case .sessionTokenExpired:
            return "SESSION_TOKEN_EXPIRED"
        case .sessionTokenNotRecongized:
            return "SESSION_TOKEN_NOT_RECONGIZED"
        case .validationError:
            return "VALIDATION_ERROR"
        case .fingerprintNotFound:
            return "FINGERPRINT_MATCH_NOT_FOUND"
        case .noActiveSession:
            return "NO_ACTIVE_SESSION"
        }
    }
}
