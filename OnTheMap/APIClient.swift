//
//  APIClient.swift
//  OnTheMap
//
//  Created by Victor Guerra on 11/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import Foundation

// All possible HTTP methods used
enum HttpMethod : String {
    case DELETE = "DELETE", GET = "GET", POST = "POST", PUT = "PUT"
}

// Some typealiases to make code more readeble
typealias URLParametersDict = [String : AnyObject]
typealias JSONDict = [String : AnyObject]
typealias HeadersDict = [String : String]
typealias CompletionClosure = (result: AnyObject!, error: NSError?) -> Void
typealias onErrorClosure = (error: NSError?) -> Void

class APIClient : NSObject {

    let session : NSURLSession
    // what is known as uniqueKey for the Parse API.
    var userID : String!
    var objectID : String?
    var fbToken : String?

    var udacity_account : JSONDict! = nil
    var lastName : String! = nil
    var firstName : String! = nil
    var studentLocations : [StudentLocation]? = nil
    static let sharedInstance = APIClient()

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - General Task for http methods
    func taskForHTTPMethod(httpMethod: HttpMethod, baseURL: String, method: String,
        parameters: URLParametersDict, httpHeaders: HeadersDict, jsonBody: JSONDict,
        completionHandler: CompletionClosure) -> NSURLSessionDataTask {
            
            let urlString = baseURL + method + APIClient.escapedParameters(parameters)
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = httpMethod.rawValue
            for (headerField , value) in httpHeaders {
                request.addValue(value, forHTTPHeaderField: headerField)
            }
            
            if !jsonBody.isEmpty && httpMethod != .GET {
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions(rawValue: 0))
            }
            
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                if let error = downloadError {
                    completionHandler(result: nil, error: error)
                } else {
                    APIClient.parseJSONWithCompletionHandler(APIClient.Constants.skipConfig[baseURL]!,
                        data: data!, completionHandler: completionHandler)
                }
            }
            
            task.resume()
            return task
    }

    func taskForDELETEMethod(baseURL: String, method: String, parameters: URLParametersDict,
        headers: HeadersDict, completionHandler: CompletionClosure) -> NSURLSessionDataTask {
        
        return taskForHTTPMethod(.DELETE, baseURL: baseURL,
            method: method, parameters: parameters, httpHeaders: headers,
            jsonBody: JSONDict(), completionHandler: completionHandler)
    }

    
    func taskForGETMethod(baseURL: String, method: String, parameters: URLParametersDict,
        headers: HeadersDict, completionHandler: CompletionClosure) -> NSURLSessionDataTask {
        
        return taskForHTTPMethod(.GET, baseURL: baseURL,
            method: method, parameters: parameters, httpHeaders: headers,
            jsonBody: JSONDict(), completionHandler: completionHandler)
       
    }
    
    func taskForPOSTMethod(baseURL: String, method: String, parameters: URLParametersDict,
        headers: HeadersDict, jsonBody: JSONDict, completionHandler: CompletionClosure) -> NSURLSessionDataTask {
        
        return taskForHTTPMethod(.POST, baseURL: baseURL,
            method: method, parameters: parameters, httpHeaders: headers,
            jsonBody: jsonBody, completionHandler: completionHandler)
    }
    
    func taskForPUTMethod(baseURL: String, method: String, headers: HeadersDict,
        jsonBody: JSONDict, completionHandler: CompletionClosure) -> NSURLSessionDataTask {

        return taskForHTTPMethod(.PUT, baseURL: baseURL,
            method: method, parameters: URLParametersDict(), httpHeaders: headers,
            jsonBody: jsonBody, completionHandler: completionHandler)
    }

    
    // Helper: Given raw JSON, return an usable Foundation object
    class func parseJSONWithCompletionHandler(skipChars: Int, data: NSData, completionHandler: CompletionClosure) {
        do {
            let parsedResult: AnyObject = try NSJSONSerialization.JSONObjectWithData(
            APIClient.skipFirstCharsOf(data, skipChars: skipChars),
            options: NSJSONReadingOptions.AllowFragments)
            
            if let errorMessage = parsedResult.valueForKey(APIClient.JSONResponseKeys.Error) as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                let code = parsedResult.valueForKey(APIClient.JSONResponseKeys.Code) as? Int
                let status = parsedResult.valueForKey(APIClient.JSONResponseKeys.Status) as? Int
                let responseError = NSError(domain: APIClient.Constants.ErrorDomain, code: status ?? code!, userInfo: userInfo)
                completionHandler(result: parsedResult, error: responseError)
            } else {
                completionHandler(result: parsedResult, error: nil)
            }
            
        } catch let error as NSError {
            completionHandler(result: nil, error: error)
        }
    }

    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    // Helper function: Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    // Helper function: Trimming some leading chars depending on the server we communicate with
    class func skipFirstCharsOf(data: NSData, skipChars: Int) -> NSData {
        return data.subdataWithRange(NSMakeRange( skipChars, data.length - skipChars))
    }
}