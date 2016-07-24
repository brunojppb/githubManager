//
//  ResponseJSONObjectSerializable.swift
//  githubManager
//
//  Created by Bruno Paulino on 7/24/16.
//  Copyright © 2016 brunojppb. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ResponseJSONObjectSerializable {
    init?(json: SwiftyJSON.JSON)
}