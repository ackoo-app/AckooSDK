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


class Utils {
//    public static func convertImageToDate(_ image:UIImage) -> (Data?,format:String) {
//        
//        let imageData:Data
//        
//        let alphaInfo = image.cgImage!.alphaInfo
//        let hasAlpha = !(alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast)
//        let imageIsPng = hasAlpha
//        // But if we have an image data, we will look at the preffix
//       
//        if imageIsPng {
//            imageData = image.pngData()!
//            return (imageData,"png")
//        }
//        else {
//            imageData = image.jpegData(compressionQuality: 1.0)!
//             return (imageData,"jpeg")
//        }
//        
//    }
}
