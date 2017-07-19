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
    
    private let session = URLSession.shared
    
    // Makes request to Flickr's flickr.photos.search method
    func fetchPhotos(completion: @escaping (Result<[Photo]>) -> Void) {
        let request = URLRequest(url: FlickrAPI.searchURL)
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            var result = strongSelf.processPhotosRequest(data: data, error: error)
            if case .success = result {
                do {
                    try strongSelf.persistantContainer.viewContext.save()
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
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let strongSelf = self else { return }
            let result = strongSelf.processImageRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func fetchAllPhotos(completion: @escaping (Result<[Photo]>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        // TODO: Add logic so that duplicate photos are removed.
        
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
    
    // MARK: - Private methods
    
    private func processPhotosRequest(data: Data?, error: Error?) -> Result<[Photo]> {
        guard let jsonData = data else {
            return .failure(error ?? PhotoStoreError.unknown)
        }
        return FlickrAPI.photos(fromJSON: jsonData, into: persistantContainer.viewContext)
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> Result<UIImage> {
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
