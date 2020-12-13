//
//  APIClient.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 11/14/20.
//

import Foundation

func executeRequest<T: Codable>(_ request: AckooRequest, success: @escaping (_ result: T) -> Void, failure: @escaping (_ error: AckooError) -> Void) {
    if Reachability.isConnectedToNetwork() {
        let session = URLSession.shared

        guard let url = URL(string: request.apiURL) else {
            failure(AckooError(error: LocalError.invalidURL, api: request.apiURL))
            return
        }
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        // request body
        if let parameters = request.parameters {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            urlRequest.httpBody = jsonData
        }
        // request header
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        let task = session.dataTask(with: urlRequest, completionHandler: {  (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                failure(AckooError(error: error, api: request.apiURL))
            }
            if let response = response as? HTTPURLResponse, response.isResponseOK(), let data = data {
                do {
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(T.self, from: data)
                    success(object)
                } catch {
                    // parsing response error
                    failure(AckooError(error: LocalError.parseResponseError, api: request.apiURL))
                }

            } else if let data = data {
                // try to parse data to error
                do {
                    let decoder = JSONDecoder()
                    let object = try decoder.decode(BackEndError.self, from: data)
                    let error = AckooError(code: object.error.code, message: object.error.message, api: request.apiURL)
                    failure(error)
                } catch {
                    // parsing error
                    failure(AckooError(error: LocalError.parseErrorFailed, api: request.apiURL))
                }
            } else {
                failure(AckooError(error: LocalError.noData, api: request.apiURL))
            }

            return ()
        })
        task.resume()

    } else {
        // TODO:
        /// cache request and retry
        failure(AckooError(error: LocalError.noInternetConnection, api: request.apiURL))
    }
}
