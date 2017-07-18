//
//  PhotoStore.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum PhotoStoreError: Error {
    case unknown
}

class PhotoStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    //Rename to fetchPhotosSearch maybe
    func GETPhotosFromFlickr(completion: @escaping (Result<[Photo]>) -> Void) {
        let request = URLRequest(url: FlickrAPI.searchURL)
        
        //TODO: add strong and weak self
        let task = session.dataTask(with: request) { (data, response, error) in
            let results = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(results)
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> Result<[Photo]> {
        guard let jsonData = data else {
            return .failure(error ?? PhotoStoreError.unknown)
        }
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (Result<UIImage>) -> Void) {
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            let result = self.processImageRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func processImageRequest(data: Data?, error: Error?) -> Result<UIImage> {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error ?? PhotoStoreError.unknown)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }
        return .success(image)
    }
}
