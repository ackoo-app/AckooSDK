//
//  Repo.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation
func getData<T: Codable>(request: AckooRequest, success: @escaping (_ result: T) -> Void, failed: @escaping (_ error: AckooError) -> Void) {
        executeRequest(request) { (object: T) in
            success(object)}
            failure: { (error) in
                failed(error)
            }
    

}
