//
//  LocalError.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation
enum LocalError: Error {
    case noInternetConnection
    case parseResponseError
    case parseErrorFailed
    case unknown
    case noData
}

extension LocalError {
    var message: String {
        switch self {
        case .noInternetConnection:
            return Constants.ErrorMessages.noInternent
        case .parseErrorFailed:
            return Constants.ErrorMessages.failedErrorParsing
        case .parseResponseError:
            return Constants.ErrorMessages.failedResponseParsing
        case .unknown:
            return NSLocalizedString("localError.unknown.message", comment: "")
        case .noData:
            return NSLocalizedString("localError.noData.message", comment: "")
        }
    }

    var code: String {
        switch self {
        case .parseErrorFailed:
            return "LOCAL_FAILED_PARSE_ERROR"
        case .parseResponseError:
            return "LOCAL_FAILED_PARSE_RESPONSE"
        case .noInternetConnection:
            return "LOCAL_NO_CONNECTION"
        case .unknown:
            return "LOCAL_UNKNOWN"
        case .noData:
            return "LOCAL_NO_DATA"
        }
    }
}
