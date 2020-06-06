//
//  Utils.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//

import Foundation
import UIKit
open class Utils {
    public static func convertImageToDate(_ image:UIImage) -> (Data?,format:String) {
        
        let imageData:Data
        
        let alphaInfo = image.cgImage!.alphaInfo
        let hasAlpha = !(alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast)
        let imageIsPng = hasAlpha
        // But if we have an image data, we will look at the preffix
       
        if imageIsPng {
            imageData = image.pngData()!
            return (imageData,"png")
        }
        else {
            imageData = image.jpegData(compressionQuality: 1.0)!
             return (imageData,"jpeg")
        }
        
    }
}
