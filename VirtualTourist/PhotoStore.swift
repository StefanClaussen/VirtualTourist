//
//  PhotoStore.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

enum PhotoStoreError: Error {
    case unknown
}

class PhotoStore {
    //Rename to fetchPhotosSearch maybe
    static func GETPhotosFromFlickr(completion: @escaping (Result<[Photo]>) -> Void) {
        let session = URLSession.shared
        let request = URLRequest(url: FlickrAPI.searchURL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let results = processGETPhotosFromFlickr(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(results)
            }
        }
        task.resume()
    }
    
    private static func processGETPhotosFromFlickr(data: Data?, error: Error?) -> Result<[Photo]> {
        guard let jsonData = data else {
            return .failure(error ?? PhotoStoreError.unknown)
        }
        return FlickrAPI.photos(fromJSON: jsonData)
    }
}
