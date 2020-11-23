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
            return NSLocalizedString("localError.noInternet.message", comment: "")
        case .parseErrorFailed:
            return NSLocalizedString("localError.parsing.message", comment: "")
        case .parseResponseError:
            return NSLocalizedString("localError.parsing.message", comment: "")
        case .unknown:
            return NSLocalizedString("localError.unknown.message", comment: "")
        case .noData:
            return NSLocalizedString("localError.noData.message", comment: "")
        }
    }

    var code: Int {
        switch self {
        case .parseErrorFailed:
            return -1001
        case .parseResponseError:
            return -1002
        case .noInternetConnection:
            return -1003
        case .unknown:
            return -1000
        case .noData:
            return -1005
        }
    }
}
