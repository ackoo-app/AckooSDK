//
//  AckooRequestFactory.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/14/20.
//

import Foundation
final class AckooRequestFactory {
    private var request: AckooRequest!
    func createRequest(apiMethod: String, httpMethod: RequestHTTPMethod, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> AckooRequest {
        request = AckooRequest()
        request.apiURL = apiMethod
        request.httpMethod = httpMethod
        request.parameters = parameters
        request.headers = headers
        request.identifer = apiMethod
        return request
    }
}
func baseHeaders() -> [String: String]? {
    var headers =  ["Content-Type": "application/json"]
    headers["app-key"] = parseAppConfig()?.ackooToken
    headers["sdk-version"] = "0.5.1"
    let sessionToken: String = getSessionToken()
    if !sessionToken.isEmpty {
        headers["session-token"] = sessionToken
    }
    return headers
}
