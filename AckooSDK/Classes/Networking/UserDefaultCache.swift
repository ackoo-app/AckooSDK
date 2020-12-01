//
//  UserDefaultCache.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/24/20.
//

import Foundation
final class UserDefaultCache: NSObject, StorageProtocol {
    override private init() {}

    static let shared = UserDefaultCache()
    @discardableResult
    func saveObject<T: Codable>(with identifer: String, object: T) -> Bool {
        if let jsonData = try? JSONEncoder().encode(object) {
        UserDefaults.standard.set(jsonData, forKey: identifer)
        }
        return UserDefaults.standard.synchronize()
    }

    @discardableResult
    func deleteObject(with identifer: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: identifer)
        return UserDefaults.standard.synchronize()
    }

    @discardableResult
    func deleteAll() -> Bool {
        let domain = Bundle.main.bundleIdentifier
        if let domain = domain {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        return UserDefaults.standard.synchronize()
    }

    func retriveObject<T: Decodable>(with identifer: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: identifer) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(T.self, from: data) {
                return (object)
            }
        }
        return nil
    }
}
