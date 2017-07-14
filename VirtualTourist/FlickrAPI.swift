//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 13/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

enum FlickrError: Error {
    case invalidJSONData
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

struct FlickrAPI {
    
    static var searchURL: URL {
        return flickrURL()
    }
    
    static func photos(fromJSON data: Data) -> Result<[Photo]> {
        let parsedResult: [String: AnyObject]
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch let error {
            return .failure(error)
        }
        
        guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
            return .failure(FlickrError.invalidJSONData)
        }
        
        guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            return .failure(FlickrError.invalidJSONData)
        }
        
        var finalPhotos = [Photo]()
        for photoDictionary in photosArray {
            guard
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String,
                let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String,
                let photo = Photo(title: photoTitle, remoteURL: imageURLString) else {
                    return .failure(FlickrError.invalidJSONData)
            }
            finalPhotos.append(photo)
        }
        
        return .success(finalPhotos)
    }
    
    private static func flickrURL() -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        let latitude: Double = 51.50
        let longitude: Double = 0.12
        
        // TODO: I am currently creating the bbox values here. 
        // This needs to be done elsewhere.
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        let bboxString = "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        
        let parameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
        ]
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
    
        return components.url!
    }
    
}
