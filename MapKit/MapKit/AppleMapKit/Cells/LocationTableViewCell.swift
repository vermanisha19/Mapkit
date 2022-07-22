//
//  LocationTableViewCell.swift
//  AppleMapKit
//
//  Created by MAC106 on 07/07/22.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    
    static let identifier = "LocationTableViewCell"
    var cellData: MKPlacemark? {
        didSet {
            if let cellData = cellData {
                title.text = cellData.name
                subTitle.text = parseAddress(selectedItem: cellData)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func parseAddress(selectedItem:MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            selectedItem.thoroughfare ?? "",
            comma,
            selectedItem.locality ?? "",
            secondSpace,
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}
