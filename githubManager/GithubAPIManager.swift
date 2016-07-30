//
//  GithubAPIManager.swift
//  githubManager
//
//  Created by Bruno Paulino on 7/23/16.
//  Copyright © 2016 brunojppb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GithubAPIManager {
    
    static let sharedInstance = GithubAPIManager()
    var alamofireManager: Alamofire.Manager
    
    let clientID: String = "771bfea0be2102c0a612"
    let clientSecret: String = "e0650ec49cf01034910cfe24bfdffacf251aa625"
    var OAuthToken: String?
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        alamofireManager = Alamofire.Manager(configuration: configuration)
    }
    
    // MARK: Github OAuth
    func hasOAuthToken() -> Bool {
        if let token = self.OAuthToken {
            return !token.isEmpty
        } else {
            return false
        }
    }
    
    func URLToStartOAuth2Login() -> NSURL? {
        let authPath = "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope&state=TEST_STATE"
        guard let authURL = NSURL(string: authPath) else {
            // TODO: handle the error
            return nil
        }
        return authURL
    }
    
    func processOAuthStep1Response(url: NSURL) {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code: String?
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if queryItem.name.lowercaseString == "code" {
                    code = queryItem.value
                    break
                }
            }
            
            // Request token to Github
            if let receivedCode = code {
                self.swapAuthCodeForToken(receivedCode)
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(false, forKey: "loadingOAuthToken")
            }
        }
    }
    
    func swapAuthCodeForToken(receivedCode: String) {
        let getTokenPath = "https://github.com/login/oauth/access_token"
        let tokenParams = ["client_id": clientID, "client_secret": clientSecret, "code": receivedCode]
        let jsonHeader = ["Accept": "application/json"]
        
        
        Alamofire.request(.POST, getTokenPath, parameters: tokenParams, headers: jsonHeader)
            .responseJSON { response in
                print("Token got back")
                print("Response: \(response)")
                if let error = response.result.error {
                    print("Request token exchange error")
                    print(error)
                    return
                }
                print(response.result.value)
                if let data = response.result.value {
                    let json = SwiftyJSON.JSON(data)
                    print(json)
                    for (key, value) in json {
                        switch key {
                        case "access_token":
                            self.OAuthToken = value.string
                        case "scope":
                            // TODO: Verify Scope
                            print("SET SCOPE")
                        case "token_type":
                            // TODO: Verify token type
                            print("Check if BEARER")
                        default:
                            print("got more I expected from the OAUTH token exchange")
                            print(key)
                            
                        }
                    }
                }
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(false, forKey: "loadingOAuthToken")
                
                if self.hasOAuthToken() {
                    self.printMyStarredGistsWithOAuth2()
                }
                
        }
    }
    
    func printMyStarredGistsWithOAuth2() {
        // TODO: get and print starred gists
        alamofireManager.request(GistRouter.GetMyStarred())
            .responseString { response in
                guard response.result.error == nil else {
                    print(response.result.error)
                    return
                }
                
                if let receivedString = response.result.value {
                    print(receivedString)
                }
        }
    }
    
    // MARK: Basic Authentication
    func printMyStarredGistWithBasicAuth() {
        alamofireManager.request(GistRouter.GetMyStarred())
            .responseString { response in
                if let receivedString = response.result.value {
                    print(receivedString)
                    let json = SwiftyJSON.JSON(receivedString)
                    if let message = json["message"].string {
                        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: message)
                        print(error)
                        // TODO: Bubble up message error
                    }
                    // TODO: Manipulate JSON
                }
                
                if let error = response.result.error {
                    print(error)
                    // TODO: Buuble up request error
                }
        }
    }
    
    func getGists(urlRequest: URLRequestConvertible, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
        alamofireManager.request(urlRequest)
            .validate()
            .responseArray { (response: Response<[Gist], NSError>) in
                guard response.result.error == nil,
                    let gists = response.result.value else {
                    print(response.result.error)
                    completionHandler(response.result, nil)
                    return
                }
                
                let nextURL = self.getNextPageFromHeaders(response.response)
                completionHandler(.Success(gists), nextURL)
        }
    }
    
    func getPublicGists(pageToLoad: String?, completionHandler: (Result<[Gist], NSError>, String?) -> Void ) {
        if let urlString = pageToLoad {
            getGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
        } else {
            getGists(GistRouter.GetPublic(), completionHandler: completionHandler)
        }
    }
    
    
    private func getNextPageFromHeaders(response: NSHTTPURLResponse?) -> String? {
        if let linkHeader = response?.allHeaderFields["Link"] as? String {
            
            let components = linkHeader.characters.split { $0 == "," }.map { String($0) }
            for item in components {
                let rangeOfNext = item.rangeOfString("rel=\"next\"", options: [])
                if rangeOfNext != nil {
                    let rangeOfPaddedURL = item.rangeOfString("<(.*)>;", options: .RegularExpressionSearch)
                    if let range = rangeOfPaddedURL {
                        let nextURL = item.substringWithRange(range)
                        let startIndex = nextURL.startIndex.advancedBy(1)
                        let endIndex = nextURL.endIndex.advancedBy(-2)
                        let urlRange = startIndex..<endIndex
                        return nextURL.substringWithRange(urlRange)
                    }
                }
            }
        }
        return nil
    }
}
