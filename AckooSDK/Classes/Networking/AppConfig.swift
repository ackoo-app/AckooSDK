//
//  AppConfig.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/1/20.
//

import Foundation
struct AppConfig1: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ackooToken
    }
    let ackooToken: String

}
func parseAppConfig() -> AppConfig1? {
    if let url = Bundle.main.url(forResource: "Info", withExtension: "plist") {
        if let data = try? Data(contentsOf: url) {
           let decoder = PropertyListDecoder()
           return try? decoder.decode(AppConfig1.self, from: data)
        }
       }
       return nil
   }
