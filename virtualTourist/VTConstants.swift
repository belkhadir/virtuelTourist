//
//  VTConstants.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 19/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import Foundation

extension VTClient {
    
    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let URL_IMAGE = "https://farm1.staticflickr.com/"
        static let API_KEY = "b402f62259ade86e1c35a85969eb59cb"
    }
    
    
    struct Method {
        static let SEARCH =  "flickr.photos.search"
    }
    
    struct JsonKeys {
        static let STAT = "stat"
        static let CODE = "code"
        static let MESSAGE = "message"
        static let PHOTOS = "photos"
        static let PHOTO = "photo"
        static let ID = "id"
        static let OWNER = "owner"
        static let SECRET = "secret"
        static let TITLE = "title"
        static let URL_M = "url_m"
        static let SERVER = "server"
    }
    
    struct Parameters {
        static let API_KEY = "api_key"
        static let FORMAT = "format"
        static let METHOD = "method"
        static let EXTRAT = "extras"
        static let SAFE_SEARCH = "safe_search"
        static let NOJSONCALLBACK = "nojsoncallback"
        static let AUTH_TOKEN = "auth_token"
        static let API_SIG = "api_sig"
        static let BBOX = "bbox"
    }
    
}