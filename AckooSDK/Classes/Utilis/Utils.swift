//
//  Utils.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//

import Foundation
import UIKit

extension URL {
    func queryParams() -> [String:String] {
        let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
        let queryTuples: [(String, String)] = queryItems?.compactMap{
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        } ?? []
        return Dictionary(uniqueKeysWithValues: queryTuples)
    }
}



