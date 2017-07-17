//
//  PhotoDataSource.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 14/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    var photos = [Photo]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "PhotoCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PhotoCollectionViewCell
        
        // TODO: adding images for a cell is slow. 
        // This needs improving. Also no spinner happens whilst the images are being fetched. 
//        let photo = photos[indexPath.row]
//        if let imageData = try? Data(contentsOf: photo.remoteURL) {
//            cell.imageView.image = UIImage(data: imageData)
//        }
        
        return cell
    }
}
