//
//  Photo.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

struct Photo {

    let remoteURL: URL
    let title: String
    let photoID: String
    
    init?(fromJSON json: [String: Any]) {
        guard
            let title = json[Constants.FlickrResponseKeys.Title] as? String,
            let urlString = json[Constants.FlickrResponseKeys.MediumURL] as? String,
            let photoID = json[Constants.FlickrResponseKeys.PhotoID] as? String
            else {
                return nil
    }
        self.title = title
        guard let url = URL(string: urlString) else { return nil }
        self.remoteURL = url
        self.photoID = photoID
    }
}

extension Photo: Equatable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        // Two Photos are the same if they have the same photoID
        return lhs.photoID == rhs.photoID
    }
}

