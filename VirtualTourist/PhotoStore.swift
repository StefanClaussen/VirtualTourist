//
//  PhotoStore.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import CoreData

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
    
    let imageStore = ImageStore()
    
    let persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores{ (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    //Rename to fetchPhotosSearch maybe
    func GETPhotosFromFlickr(completion: @escaping (Result<[Photo]>) -> Void) {
        let request = URLRequest(url: FlickrAPI.searchURL)
        
        //TODO: add strong and weak self
        let task = session.dataTask(with: request) { (data, response, error) in
            var result = self.processPhotosRequest(data: data, error: error)
            if case .success = result {
                do {
                    try self.persistantContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> Result<[Photo]> {
        guard let jsonData = data else {
            return .failure(error ?? PhotoStoreError.unknown)
        }
        return FlickrAPI.photos(fromJSON: jsonData, into: persistantContainer.viewContext)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (Result<UIImage>) -> Void) {
        
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL.")
        }
        let request = URLRequest(url: photoURL as URL)
        
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
    
    func fetchAllPhotos(completion: @escaping (Result<[Photo]>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let viewContext = persistantContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
