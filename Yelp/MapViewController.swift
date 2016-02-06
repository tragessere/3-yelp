//
//  MapViewController.swift
//  Yelp
//
//  Created by Evan on 2/5/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	
	var locationManager: CLLocationManager!
    var businesses: [Business]?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		locationManager.distanceFilter = 200
		locationManager.requestWhenInUseAuthorization()
		
		let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
		goToLocation(centerLocation)
      
        if businesses != nil {
            for business in businesses! {
                if business.coordinate != nil {
                    addAnnotationAtCoordinateWithTitle(business.coordinate!.coordinate, title: business.name!)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func goToLocation(location: CLLocation) {
		let span = MKCoordinateSpanMake(0.09, 0.09)
		let region = MKCoordinateRegionMake(location.coordinate, span)
		mapView.setRegion(region, animated: false)
	}

    func addAnnotationAtCoordinateWithTitle(coordinate: CLLocationCoordinate2D, title: String) {
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		annotation.title = title
		mapView.addAnnotation(annotation)
      
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func didPressOK(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

extension MapViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			locationManager.startUpdatingLocation()
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			let span = MKCoordinateSpanMake(0.1, 0.1)
			let region = MKCoordinateRegionMake(location.coordinate, span)
			mapView.setRegion(region, animated: false)
		}
	}
}