//
//  GithubAPIManager.swift
//  githubManager
//
//  Created by Bruno Paulino on 7/23/16.
//  Copyright © 2016 brunojppb. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GithubAPIManager {
    
    static let sharedInstance = GithubAPIManager()
    
    func getPublicGists(completionHandler: (Result<[Gist], NSError>) -> Void ) {
        Alamofire.request(GistRouter.GetPublic())
            .responseArray { (response: Response<[Gist], NSError>) in
                completionHandler(response.result)
        }
    }
    
    func printPublicGists() {
        Alamofire.request(GistRouter.GetPublic())
            .responseString { response in
                if let receivedString = response.result.value {
                    print(receivedString)
                }
        }
    }
}
