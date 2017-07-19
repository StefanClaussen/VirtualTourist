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
    
    fileprivate let identifier = String(describing: PhotoCollectionViewCell.self)
    
    var locationCoordinate = CLLocationCoordinate2D()
    let store = PhotoStore()
    var dataSource = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self

        addMapAnnotation()
        
        store.fetchPhotos { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            strongSelf.updateDataSource()
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
    
    private func updateDataSource() {
        store.fetchAllPhotos { [weak self] (photosResult) in
            guard let strongSelf = self else { return }
            switch photosResult {
            case let .success(photos):
                strongSelf.dataSource = photos
            case .failure:
                strongSelf.dataSource.removeAll()
            }
            strongSelf.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension DetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = dataSource[indexPath.row]
        
        store.fetchImage(for: photo) { [weak self] (result) -> Void in
            guard
                let strongSelf = self,
                let photoIndex = strongSelf.dataSource.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = strongSelf.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
}
