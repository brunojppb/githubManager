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
    
    let clientID: String = "1234567890"
    let clientSecret: String = "abasdaslkdajd"
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        alamofireManager = Alamofire.Manager(configuration: configuration)
    }
    
    // MARK: Basic Authentication
    func printMyStarredGistWithBasicAuth() {
        alamofireManager.request(GistRouter.GetMyStarred())
            .responseString { response in
                if let receivedString = response.result.value {
                    print(receivedString)
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
