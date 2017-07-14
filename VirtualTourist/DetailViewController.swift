//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 12/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationCoordinate = CLLocationCoordinate2D()
    let photoDataSource = PhotoDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource

        addMapAnnotation()
        
        PhotoStore.GETPhotosFromFlickr { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(photos):
                print("Photos count: \(photos.count)")
                strongSelf.photoDataSource.photos = photos
                
            case let .failure(error):
                print("Error getting photos from Flickr: \(error)")
                self?.photoDataSource.photos.removeAll()
            }
            strongSelf.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private func addMapAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
        
        focusMap(on: locationCoordinate)
    }
    
    private func focusMap(on coordinate: CLLocationCoordinate2D) {
        let metres: CLLocationDistance = 5000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, metres, metres)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
