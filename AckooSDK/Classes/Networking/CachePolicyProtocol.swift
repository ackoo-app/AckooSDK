//
//  CachePolicyProtocol.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation

enum CacheType {
    case userDefault
}
protocol CachePolicyProtocol {
    func shouldUseCacheType() -> CacheType
    func shouldCallAPI() -> Bool
}
