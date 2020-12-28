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
    public var code: String
    public var message: String
    public var details: [[String: String]]?
    private(set) var api: String?
    
    public override var description: String{
        return "error is : \(code) with message : \(message) from api : \(String(describing: api))"
    }
    init(code: String, message: String, details: [[String: String]]? ,api: String?) {
        self.code = code
        self.message = message
        self.details = details
        self.api = api
    }

    convenience init(error: Error, api: String? = nil) {
        self.init(code: String((error as NSError).code), message: error.localizedDescription, details: nil, api: api)
    }
}
