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
    case invalidURL
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
        case .invalidURL:
            return Constants.ErrorMessages.invalidURL
        case .noData:
            return Constants.ErrorMessages.noData
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
        case .invalidURL:
            return "INVALID_URL"
        case .noData:
            return "LOCAL_NO_DATA"
        }
    }
}
