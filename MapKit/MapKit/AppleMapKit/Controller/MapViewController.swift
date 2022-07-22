//
//  MapViewController.swift
//  MapKit
//
//  Created by MAC106 on 07/07/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet private weak var mapView: MKMapView!
    private var locationManager = CLLocationManager()
    private var searchController: UISearchController?
    private var selectedPin: MKPlacemark?
    private var currentLocation: CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setLocationManager()
        setSearchController()
    }
    
    private func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func setSearchController() {
        guard let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchController") as? LocationSearchController else {
            return
        }
        locationSearchTable.mapView = mapView
        locationSearchTable.delegate = self
        searchController = UISearchController(searchResultsController: locationSearchTable)
        guard let searchController = searchController else { return }
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search here"
        searchController.searchResultsUpdater = locationSearchTable
        searchController.dimsBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
    }
    
    @objc private func getDirections() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error in location manager..\(error)")
    }
}

//MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController?.searchBar.text = ""
        let annotations = mapView.annotations
        for annotation in annotations {
            if annotation is MKUserLocation {
                continue
            }
            mapView.removeAnnotation(annotation)
        }
        guard let currentLocation = currentLocation else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

//MARK: - MKMapViewDelegate

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        guard let pinView = pinView else { return nil }
        pinView.pinTintColor = UIColor.orange
        pinView.canShowCallout = true
        pinView.image = #imageLiteral(resourceName: "splash")
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(#imageLiteral(resourceName: "car"), for: .normal)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        pinView.leftCalloutAccessoryView = button
        return pinView
    }
}

//MARK: - HandleMapSearch

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

