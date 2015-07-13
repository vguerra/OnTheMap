//
//  APIClient.swift
//  OnTheMap
//
//  Created by Victor Guerra on 11/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import Foundation

enum HttpMethod : String {
    case DELETE = "DELETE", GET = "GET", POST = "POST", PUT = "PUT"
}

typealias URLParametersDict = [String : AnyObject]
typealias JSONDict = [String : AnyObject]
typealias HeadersDict = [String : String]
typealias CompletionClosure = (result: AnyObject!, error: NSError?) -> Void


class APIClient : NSObject {

    let session : NSURLSession
    // what is known as uniqueKey for the Parse API.
    var userID : String!
    var objectID : String?
    var fbToken : String?

    var udacity_account : JSONDict! = nil
    
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
            println("urlString: \(urlString)")
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = httpMethod.rawValue
            println("about to add headers")
            for (headerField , value) in httpHeaders {
                println("adding to headers")
                println("\(headerField) : \(value)")
                request.addValue(value, forHTTPHeaderField: headerField)
            }
            println("done w/adding headers")
            
            if !jsonBody.isEmpty && httpMethod != .GET {
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                var jsonifyError: NSError? = nil
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody,
                    options: nil, error: &jsonifyError)
            }
            
            let task = session.dataTaskWithRequest(request) { data, response, downloadError in
                if let error = downloadError {
                    let newError = APIClient.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: newError)
                } else {
                    println("no error, lets parse")
                    APIClient.parseJSONWithCompletionHandler(APIClient.Constants.skipConfig[baseURL]!,
                        data: data, completionHandler: completionHandler)
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

    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!,
            options: NSJSONReadingOptions.AllowFragments, error: nil) as? JSONDict {
            
            if let errorMessage = parsedResult[APIClient.JSONResponseKeys.StatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
        }
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(skipChars: Int, data: NSData, completionHandler: CompletionClosure) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(
            APIClient.skipFirstCharsOf(data, skipChars: skipChars),
            options: NSJSONReadingOptions.AllowFragments,
            error: &parsingError)
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }

    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

    class func skipFirstCharsOf(data: NSData, skipChars: Int) -> NSData {
        return data.subdataWithRange(NSMakeRange( skipChars, data.length - skipChars))
    }
    
    // MARK: - Shared Instance
    
}