//
//  AckooRequest.swift
//  AckooSDK
//
//  Created by Sally Ahmed on 11/14/20.
//

import Foundation
enum RequestHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}
final class AckooRequest: NSObject {
    var identifer: String = ""
    var apiURL: String = ""
    var parameters: [String: Any]?
    var headers: [String: String]?
    var httpMethod: RequestHTTPMethod = .get
    var timeOut: DispatchTimeInterval!
    override init() {
    }
}
