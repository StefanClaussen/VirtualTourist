//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 12/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLongPressGestureRecognizer()
    }
    
    func configureLongPressGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:(#selector(longPress)))
        gestureRecognizer.minimumPressDuration = 2.0
        gestureRecognizer.delegate = self
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(ofTouch: 0, in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - MapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "MapToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToDetail", let viewController = segue.destination as? DetailViewController {
            // pass the map coordinates
        }
    }
    

}
