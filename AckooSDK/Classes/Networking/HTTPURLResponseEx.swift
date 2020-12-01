//
//  HTTPURLResponseEx.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/23/20.
//

import Foundation
extension HTTPURLResponse {
     func isResponseOK() -> Bool {
      return (200...299).contains(self.statusCode)
     }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
