//
//  SessionTokenModel.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/25/20.
//

import Foundation

// MARK: - SessionTokenModel
struct SessionTokenModel: Codable {
    let ok: Bool?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let sessionToken: String?
}
