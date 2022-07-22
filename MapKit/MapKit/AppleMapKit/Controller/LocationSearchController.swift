//
//  LocationTableViewController.swift
//  AppleMapKit
//
//  Created by MAC106 on 07/07/22.
//

import UIKit
import MapKit

protocol HandleMapSearch: AnyObject {
    func dropPinZoomIn(_ placemark: MKPlacemark)
}

class LocationSearchController: UITableViewController {
  
    private var matchingItems = [MKMapItem]()
    var mapView: MKMapView?
    weak var delegate: HandleMapSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as? LocationTableViewCell
        guard let cell = cell else { return UITableViewCell() }
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.cellData = selectedItem
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        delegate?.dropPinZoomIn(selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UISearchResultsUpdating
 
extension LocationSearchController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self else { return }
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
