//
//  CacheGenertor.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation

protocol StorageProtocol {
    @discardableResult
    func saveObject<T: Codable>(with identifer: String, object: T) -> Bool

    @discardableResult
    func deleteObject(with identifer: String) -> Bool

    func retriveObject<T: Codable>(with identifer: String) -> T?

    @discardableResult
    func deleteAll() -> Bool
}

func CacheGenertor(_ cacheStorgeType: CacheType) -> StorageProtocol? {
    switch cacheStorgeType {
    case .userDefault:
        return UserDefaultCache.shared
    case .none:
        return nil
    }
}
