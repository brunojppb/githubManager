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
    
    func getPublicGists(completionHandler: (Result<[Gist], NSError>) -> Void ) {
        Alamofire.request(GistRouter.GetPublic())
            .responseArray { (response: Response<[Gist], NSError>) in
                completionHandler(response.result)
        }
    }
    
    func imageFromURLString(imageURLString: String, completionHandler: (UIImage?, NSError?) -> Void) {
        alamofireManager.request(.GET, imageURLString)
            .response { (request, response, data, error) in
                if data == nil {
                    completionHandler(nil, nil)
                    return
                }
                let image = UIImage(data: data! as NSData)
                completionHandler(image, nil)
        }
    }
}
