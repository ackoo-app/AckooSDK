//
//  DefaultDataPolicy.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/1/20.
//

import Foundation
class DefaultDataPolicy: CachePolicyProtocol {
    func useCacheType() -> CacheType {
        return .none
    }

    func shouldCallAPI() -> Bool {
        return true
    }

}
