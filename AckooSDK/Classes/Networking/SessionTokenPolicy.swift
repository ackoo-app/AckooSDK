//
//  sessionTokenPolicy.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/25/20.
//

import Foundation
class SessionTokenPolicy: CachePolicyProtocol {
    func useCacheType() -> CacheType {
        return .userDefault
    }

    func shouldCallAPI() -> Bool {
        return true
    }

}
