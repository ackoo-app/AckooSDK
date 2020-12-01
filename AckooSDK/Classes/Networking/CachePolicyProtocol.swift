//
//  CachePolicyProtocol.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation

enum CacheType {
    case userDefault
    case none
}
protocol CachePolicyProtocol {
    func useCacheType() -> CacheType
    func shouldCallAPI() -> Bool
}
