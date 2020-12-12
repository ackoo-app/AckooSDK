//
//  AckooError.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation
struct BackEndError :Codable{
    let ok: Bool
    let error: AckooError
}

protocol AckooErrorType: Error {
    var message: String { get }
    var code: String { get }
}
@objc
public class AckooError: NSObject,AckooErrorType, Codable {
    var code: String
    var message: String
    private(set) var api: String?
    init(code: String, message: String, api: String?) {
        self.code = code
        self.message = message
        self.api = api
    }

    convenience init(error: Error, api: String? = nil) {
        if let error: AckooErrorType = error as? AckooErrorType {
            self.init(code: error.code, message: error.message, api: api)
        } else {
            self.init(code: String((error as NSError).code), message: error.localizedDescription, api: api)
        }
    }
}
