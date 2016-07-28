//
//  GistRouter.swift
//  githubManager
//
//  Created by Bruno Paulino on 7/23/16.
//  Copyright © 2016 brunojppb. All rights reserved.
//

import Alamofire

enum GistRouter: URLRequestConvertible {
    
    static let baseURLString = "https://api.github.com"
    
    case GetPublic()
    case GetAtPath(String)
    
    var URLRequest: NSMutableURLRequest {
        
        var method: Alamofire.Method {
            switch self {
            case .GetPublic:
                return .GET
            case .GetAtPath:
                return .GET
            }
        }
            
        let result: (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .GetPublic:
                return ("/gists/public", nil)
            case .GetAtPath(let path):
                let url = NSURL(string: path)
                let relativePath = url!.relativePath!
                return (relativePath, nil)
            }
            
        }()
        
        let URL = NSURL(string: GistRouter.baseURLString)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: result.parameters)
        
        encodedRequest.HTTPMethod = method.rawValue
        return encodedRequest
    }
    
    
}
