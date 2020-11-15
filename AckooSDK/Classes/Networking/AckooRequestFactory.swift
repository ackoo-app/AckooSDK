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
        return request
    }
}
