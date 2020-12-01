//
//  Repo.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation
func getData<T: Codable>(request: AckooRequest, cachingPolicy: CachePolicyProtocol, success: @escaping (_ result: T) -> Void, failed: @escaping (_ error: AckooError) -> Void) {
    if cachingPolicy.shouldCallAPI() {
        executeRequest(request) { (object: T) in
            if cachingPolicy.useCacheType() != .none {
                let cacheType = CacheGenertor(cachingPolicy.useCacheType())
                cacheType?.saveObject(with: request.identifer, object: object)
            }
            success(object)}
            failure: { (error) in
                failed(error) }

    } else if cachingPolicy.useCacheType() != .none {
        let cacheType = CacheGenertor(cachingPolicy.useCacheType())
        let object: T? = cacheType?.retriveObject(with: request.identifer)
        if let object = object {
            success(object)
        } else {
            failed(AckooError(error: LocalError.noData))
        }
    } else {
        failed(AckooError(error: LocalError.noData))
    }

}
