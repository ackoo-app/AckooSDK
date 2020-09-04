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
//    case dev
//    case production
//    case staging
}

var BUILD_MODE:BuildMode = BuildMode.qa

struct Config: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ackooBaseURL
       
    }
    let ackooBaseURL: String
   
    
}

struct AppConfig: Decodable {
    private enum CodingKeys: String, CodingKey {
        case partnerToken
    }
    let partnerToken: String
    
}
///

class NetworkingManager {
    
    //Singleton object
    static let sharedInstance = NetworkingManager()
    let currentBuildMode:BuildMode = BUILD_MODE
    var API_BASE_URL:String
    var partnerToken:String

     init() {
        self.API_BASE_URL = NetworkingManager.getApiBaseUrl(buildMode: currentBuildMode)
        self.partnerToken = NetworkingManager.getPartnerToken()
        if (self.partnerToken.isEmpty) {
            fatalError("Please add partner token is the AckooSDK.plist file")
        }
    }
    
    class func parseConfig() -> Config? {
        if let bundle:Bundle = Bundle(identifier: "org.cocoapods.AckooSDK"),
            let url = bundle.url(forResource: "AckooSDK", withExtension: "plist") {
            
        let data = try! Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try! decoder.decode(Config.self, from: data)
        }
        return nil
    }
    
    class func parseAppConfig() -> AppConfig? {
        if let url = Bundle.main.url(forResource: "Info", withExtension: "plist") {
               
           let data = try! Data(contentsOf: url)
               let decoder = PropertyListDecoder()
               return try! decoder.decode(AppConfig.self, from: data)
           }
           return nil
       }
    
    class func getApiBaseUrl(buildMode: BuildMode) -> String {
        var apiBaseURL: String = "https://cryptic-garden-59749.herokuapp.com/"
        switch buildMode {
            case .qa:
                //print("QA")
                if let config:Config = self.parseConfig() {
                    apiBaseURL = config.ackooBaseURL //QA
                }

                //Read from AckooBaseURL
                
            break
           
         }
        return apiBaseURL
     }
    
    class func getPartnerToken() -> String {
        var partnerToken: String = ""
        if let config:AppConfig = self.parseAppConfig() {
            partnerToken = config.partnerToken 
        }
        return partnerToken
     }
    
    func prepareRequestToServerWith(_ requestString:String, methodType:String,params:Data?) -> URLRequest?  {
        
        guard let url = URL(string: API_BASE_URL + requestString) else {
            //print("not valid url")
            return nil
        }
        var request:URLRequest = URLRequest(url: url)
        request.httpMethod = methodType
        request = setHeadersToRequest(request)
        if params != nil {
            request.httpBody = params
        }
        do {
            let hData = try JSONSerialization.data(withJSONObject: request.allHTTPHeaderFields ?? [:], options: [])
            
            let hString = String(data: hData, encoding: String.Encoding.utf8)
            
            print("URL : \(String(describing: request.url?.absoluteString)) \nHeader : \(String(describing: hString)) \n");
            if let data = request.httpBody {
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("\nBody : \(String(describing: str)) ");
            }
        return request
        } catch {
            //print("json error: \(error.localizedDescription)")
             return nil
        }
        
    }

    func createDataTastWithRequest( _ request:URLRequest,  callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.NO_INTERNET_MESSAGE])
            return
        }
        
         let session = URLSession.shared
        
        //session.dataTas
        
        let task = session.dataTask(with: request, completionHandler: {  (data:Data?, response:URLResponse?, error:Error?) in
            ////print("\(params)")
            self.validateResponse(data, response: response, error: error, callback: callback)
            return ()
        })
        task.resume()
    }

    

    //MARK:- POST Request
    func postRequest(_ params: Data, url: String, callback: @escaping (_ succeeded: Bool, _ response: Any?) -> Void) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.NO_INTERNET_MESSAGE])
            return
        }
        
        guard let request:URLRequest = prepareRequestToServerWith(url, methodType: "POST", params: params) else {
            callback(false, [Constants.RESPONSE_KEYS.ERROR_KEY:Constants.ENGLISH.INVALID_REQUEST])
            return
        }
        self.createDataTastWithRequest(request, callback: callback)
    }
    
 
    
    //MARK:- Helpers
    
    func validateResponse(_ data:Data?,response:URLResponse?,error:Error?,callback: (_ succeeded: Bool, _ response: Any?) -> Void){
        ////print("URL ")
        guard let data:Data = data, let response:URLResponse = response, error == nil else {
            
            //print("Error = \(String(describing: error))")
            let responseDict = [Constants.RESPONSE_KEYS.ERROR_KEY:error?.localizedDescription]
            
            callback(false, responseDict as Any?)
            return
        }
        
        
        
        print("Response: \(String(describing: String(data: data, encoding: String.Encoding.utf8))) for URL \(String(describing: response.url))")
        do {
            
            let json = try JSONSerialization.jsonObject(with: data, options: [])
                ////print("\(response)")
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
            //print("json error: \(error.localizedDescription)\nCode:\(String(describing: httpResponse?.statusCode))")
            //print("\(String(describing: response.url))")
            //print("\(String(describing: String(data: data, encoding:String.Encoding.utf8)))")
            
            let responseDict = [Constants.RESPONSE_KEYS.ERROR_KEY:HTTPURLResponse.localizedString(forStatusCode: httpResponse?.statusCode ?? 400)]
            
            let responseDict2 = [Constants.RESPONSE_KEYS.ERROR_KEY:error.localizedDescription]
            
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
            //print("Status Code: \(httpResponse.statusCode)")
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
        let sessionToken:String = UserActivity.getToken()
        if !sessionToken.isEmpty {
            request.addValue(sessionToken, forHTTPHeaderField: "session-token")
        }
        request.addValue(self.partnerToken, forHTTPHeaderField: "app-token")
        return request
        ////print(request.allHTTPHeaderFields)
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

