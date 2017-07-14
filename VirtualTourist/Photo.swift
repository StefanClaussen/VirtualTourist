//
//  Photo.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

struct Photo {

    let url: URL?
    let title: String
    
    init?(fromJSON json: [String: Any]) {
        guard
            let title = json[Constants.FlickrResponseKeys.Title] as? String,
            let urlString = json[Constants.FlickrResponseKeys.MediumURL] as? String
            else {
                return nil
    }
        self.title = title
        self.url = URL(string: urlString)
    }
}

