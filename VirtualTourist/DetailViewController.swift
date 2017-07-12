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
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationCoordinate = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()

        addMapAnnotation()
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
