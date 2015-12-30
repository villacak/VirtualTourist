//
//  VirtualTouristConstants.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/30/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation

extension VirtualTouristDB {
    
    struct Keys {
        static let ID = "id"
        static let ErrorStatusMessage = "status_message"
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
    }
    
    struct Resources {
        static let Config = "configuration"
    }
    
    struct Values {
        static let KevinBaconIDValue = 4724
    }    
}