//
//  Photo.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

struct Photo {

    let remoteURL: String
    let title: String
    
    init?(title: String, remoteURL: String) {
        self.title = title
        self.remoteURL = remoteURL
    }
}

//extension Photo: Equatable {
//    static func == (lhs: Photo, rhs: Photo) -> Bool {
//        // Two Photos are the same if they have the same photoID
//        return lhs.photoID == rhs.photoID
//    }
//}
