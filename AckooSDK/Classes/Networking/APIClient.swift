//
//  APIClient.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/14/20.
//

import Foundation

func executeRequest<T>(_ request: AckooRequest, success: @escaping (_ results: T) -> Void, failure: @escaping (_ error: Error) -> Void) {
    if Reachability.isConnectedToNetwork() {
    } else {
        /// cache request and retry
    }
}
