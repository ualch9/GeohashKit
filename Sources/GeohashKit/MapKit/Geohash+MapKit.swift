//
//  Geohash+MapKit.swift
//
//  Created by Alan Chu on 8/2/20.
//

#if canImport(MapKit)
import MapKit

extension Geohash {
    public var region: MKCoordinateRegion {
        let coordinates = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let size = self.box.size

        let span = MKCoordinateSpan(latitudeDelta: size.latitude,
                                    longitudeDelta: size.longitude)

        return MKCoordinateRegion(center: coordinates, span: span)
    }
}
#endif

#if canImport(CoreLocation)
import CoreLocation

extension Geohash {
    public init?(_ coordinates: CLLocationCoordinate2D, precision: Int) {
        self.init(coordinates: (coordinates.latitude, coordinates.longitude), precision: precision)
    }
}
#endif
