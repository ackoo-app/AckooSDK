//
//  NetworkingManager.swift
//  Ackoo
//
//  Created by mihir mehta on 05/06/20.
//



import UIKit
import Foundation
import UIKit
import MobileCoreServices
import SystemConfiguration


/// Build mode that defines which build mode to user
 enum BuildMode: Int {
    case qa = 1
    case dev
    case production
    case staging
}

var BUILD_MODE:BuildMode = BuildMode.dev


/// 
 class NetworkingManager {
    
    //Singleton object
    static let sharedInstance = NetworkingManager()
    
    let currentBuildMode:BuildMode = BUILD_MODE
    
    var API_BASE_URL:String?

     init() {
        API_BASE_URL = getApiBaseUrl(buildMode: currentBuildMode)
    }
    
    func getCurrentBuildMode() -> BuildMode{
        return currentBuildMode
    }
    
    func getApiBaseUrl(buildMode: BuildMode) -> String {
     
        var apiBaseURL: String!
        switch buildMode {
            case .qa:
                print("QA")

                apiBaseURL = "https://api-qa.ackoo.no/api/" //QA
            break
            case .dev:
                print("DEV")
                apiBaseURL = "https://api-dev.ackoo.no/api/" //Dev
            break
            case .production:
                print("PRODUCTION")
                apiBaseURL = "https://api.ackoo.no/api/" //Production
            break
            case .staging:
                print("STAGING")
                apiBaseURL = "https://api-stg.ackoo.no/api/" //Staging
            break
         }
        return apiBaseURL
     }
    
    func prepareRequestToServerWith(_ requestString:String, methodType:String,params:Data?) -> URLRequest  {
        
        var request = URLRequest(url: URL(string: API_BASE_URL! + requestString)!)
        request.httpMethod = methodType
        request = setHeadersToRequest(request)
        if params != nil {
            request.httpBody = params
        }
        
        let hData = try! JSONSerialization.data(withJSONObject: request.allHTTPHeaderFields!, options: [])
        
        let hString = String(data: hData, encoding: String.Encoding.utf8)
        
        print("URL : \(request.url!.absoluteString) \nHeader : \(hString!) \n");
        
        if let data = request.httpBody {
            
            let str = String(data: data, encoding: String.Encoding.utf8)
            
            print("\nBody : \(str!) ");
        }
        
        return request
        
    }

    func createDataTastWithRequest( _ request:URLRequest,  callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.NO_INTERNET_MESSAGE])
            return
        }
        
         let session = URLSession.shared
        
        //session.dataTas
        
        let task = session.dataTask(with: request, completionHandler: {  (data:Data?, response:URLResponse?, error:Error?) in
            //print("\(params)")
            self.validateResponse(data, response: response, error: error, callback: callback)
            return ()
        })
        task.resume()
    }
    func createDataTastWithRequest( _ request:URLRequest,  callback: @escaping (_ succeeded: Bool, _ response: Data?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            if let theJSONData:Data = try? JSONSerialization.data(
                withJSONObject: [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.NO_INTERNET_MESSAGE],
                options: []) {
                callback(false, theJSONData)
            }
            return
        }
        
        let session = URLSession.shared
        
        //session.dataTas
        
        let task = session.dataTask(with: request, completionHandler: {  (data:Data?, response:URLResponse?, error:Error?) in
            //print("\(params)")
            if let httpResponse = response as? HTTPURLResponse ,httpResponse.statusCode == 200 {
                
                callback(true, data)
                
            }
            else {
                callback(false, data)
            }
            return ()
        })
        task.resume()
    }
    
    //  MARK: Add Additional Header Params To Request
    func addAdditionalHeaderParamsToRequest(_ requestURL:URLRequest, addionalHeaderParam:Dictionary<String,Any>) -> URLRequest  {
        
        var request = requestURL
        
        for (key, value) in addionalHeaderParam {
            print("Param: Value: \(value as Any) for key: \"\(key as String)\"")
            request.addValue(String(describing: value), forHTTPHeaderField: key)
        }
        return request
    }
    

    //MARK:- POST Request
    func postRequest(_ params: Data, url: String, callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.NO_INTERNET_MESSAGE])
            return
        }
        
        let request:URLRequest = prepareRequestToServerWith(url, methodType: "POST", params: params)
        self.createDataTastWithRequest(request, callback: callback)
    }
    
    //MARK:- PUT Request
    func putRequest(_ params: Data?, url: String,additionalHeaderParamDict:Dictionary<String,Any>? = nil, callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.NO_INTERNET_MESSAGE])
            return
        }
        
        var request:URLRequest = prepareRequestToServerWith(url, methodType: "PUT", params: params)
        if additionalHeaderParamDict != nil {
            request = self.addAdditionalHeaderParamsToRequest(request, addionalHeaderParam: additionalHeaderParamDict!)
            
            let hData = try! JSONSerialization.data(withJSONObject: request.allHTTPHeaderFields!, options: [])
            let hString = String(data: hData, encoding: String.Encoding.utf8)
            
            print("FINAL URL : \(request.url!.absoluteString) \n Revised Header : \(hString!) \n");
        }
        self.createDataTastWithRequest(request, callback: callback)
    }
    
    //MARK:- DELETE Request
    func deleteRequest(_ params: Data?, url: String, callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        let request:URLRequest = prepareRequestToServerWith(url, methodType: "DELETE", params: params)
        self.createDataTastWithRequest(request, callback: callback)
    }
    
    //MARK:- GET Request
    
    func getRequest(_ url: String,_ additionalHeaderParamDict:Dictionary<String,Any>? = nil, callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            callback(false, [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.NO_INTERNET_MESSAGE])
            return
        }
        
        var request:URLRequest = prepareRequestToServerWith(url, methodType: "GET", params: nil)
        if additionalHeaderParamDict != nil {
            request = self.addAdditionalHeaderParamsToRequest(request, addionalHeaderParam: additionalHeaderParamDict!)
            
            let hData = try! JSONSerialization.data(withJSONObject: request.allHTTPHeaderFields!, options: [])
            let hString = String(data: hData, encoding: String.Encoding.utf8)
            
            print("FINAL URL : \(request.url!.absoluteString) \n Revised Header : \(hString!) \n");
        }
        self.createDataTastWithRequest(request, callback: callback)
    }
    func getRequest(_ url: String, additionalHeaderParamDict:Dictionary<String,Any>? = nil, callback: @escaping (_ succeeded: Bool, _ response: Data?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            if let theJSONData:Data = try? JSONSerialization.data(
                withJSONObject: [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:Constants.ENGLISH.NO_INTERNET_MESSAGE],
                options: []) {
                callback(false, theJSONData)
            }
            return
        }
        
        var request:URLRequest = prepareRequestToServerWith(url, methodType: "GET", params: nil)
        if additionalHeaderParamDict != nil {
            request = self.addAdditionalHeaderParamsToRequest(request, addionalHeaderParam: additionalHeaderParamDict!)
            
            let hData = try! JSONSerialization.data(withJSONObject: request.allHTTPHeaderFields!, options: [])
            let hString = String(data: hData, encoding: String.Encoding.utf8)
            
            print("FINAL URL : \(request.url!.absoluteString) \n Revised Header : \(hString!) \n");
        }
        self.createDataTastWithRequest(request, callback: callback)
    }
    
    //MARK:- MULTIPART Request
    func postImageAsMutlipartRequest(_ url: String,image:UIImage, callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
      var request:URLRequest = prepareRequestToServerWith(url, methodType: "POST", params: nil)
        request.timeoutInterval = 180
        let imageData:(Data?,String) = Utils.convertImageToDate(image)
        
        let boundary = generateBoundaryString()
        
        
        
        let fullData = photoDataToFormData(imageData.0!,boundary:boundary,fileName:imageData.1)
        
        request.setValue("multipart/form-data; boundary=" + boundary,
                         forHTTPHeaderField: "Content-Type")
        
        // REQUIRED!
        request.setValue(String(fullData.count), forHTTPHeaderField: "Content-Length")
        
        request.httpBody = fullData
        
        self.createDataTastWithRequest(request, callback: callback)
    }
    
    //MARK:- Helpers
    
    func validateResponse(_ data:Data?,response:URLResponse?,error:Error?,callback: (_ succeeded: Bool, _ response: Any?) -> Void){
        //print("URL ")
        guard let data:Data = data, let response:URLResponse = response, error == nil else {
            
            print("Error = \(String(describing: error))")
            let responseDict = [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:error?.localizedDescription]
            
            callback(false, responseDict as Any?)
            return
        }
        
        
        
        print("Response: \(String(describing: String(data: data, encoding: String.Encoding.utf8))) for URL \(String(describing: response.url))")
        do {
            
            let json = try JSONSerialization.jsonObject(with: data, options: [])
                //print("\(response)")
            
           
                
            if let jsonDict:Dictionary<String,AnyObject> = json as? Dictionary<String,AnyObject> {
                if jsonDict.count == 0 {
                    callback(false, [:])
                    return
                }
            }

            
            if let resDict:Dictionary<String,Any> = json as? Dictionary<String,Any> /* , let sON:Dictionary<String,Any> = resDict as?  Dictionary<String,Any> */ {
                successCall(response: response, json: resDict, callback: callback)
            }
            else if let resArray:Array<[String:Any]> = json as? Array<[String:Any]> /* , let sON:Array<[String:Any]> = resArray as?  Array<[String:Any]> */ {
                successCall(response: response, json: resArray, callback: callback)
            }
            else {
                successCall(response: response, json: json , callback: callback)
            }
        }
        catch let error as NSError {
            
            let httpResponse = response as? HTTPURLResponse
            print("json error: \(error.localizedDescription)\nCode:\(httpResponse!.statusCode)")
            print("\(response.url!)")
            print("\(String(describing: String(data: data, encoding:String.Encoding.utf8)))")
            
            let responseDict = [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:HTTPURLResponse.localizedString(forStatusCode: httpResponse!.statusCode)]
            
            let responseDict2 = [Constants.RESPONSE_KEYS.NEW_ERROR_MESSAGE:error.localizedDescription]
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    
                    callback(false, responseDict2)
                    
                }
                else {
                    callback(false, responseDict)
                }
            }
            else {
                callback(false, responseDict2)
            }
        }
    }
    func successCall(response:URLResponse?,json:Any,callback: (_ succeeded: Bool, _ response: Any?) -> Void){
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                
                callback(true, json)
                
            }
            else {
                callback(false, json)
            }
        }
        else {
            
            callback(false, [:])
        }

    }
    
    //Set required header parameters to request
    func setHeadersToRequest( _ request: URLRequest) -> URLRequest {
        
        var request = request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
        //print(request.allHTTPHeaderFields)
    }
    
    func currentTimeMillis() -> Int64{
        let nowDouble = Date().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    //MARK: - For Multipart (Image)
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func photoDataToFormData(_ data:Data,boundary:String,fileName:String) -> Data {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"upload." + fileName + "\"\r\n"
        print(lineTwo)
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/" + fileName + "\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 4
        fullData.append(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        return fullData as Data
    }
}


class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}


extension NSMutableData {
    
    func appendString(_ string: String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
