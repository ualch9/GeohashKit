//
//  File.swift
//  
//
//  Created by Alan Chu on 8/2/20.
//

#if canImport(MapKit)
import MapKit

extension Geohash {
    public static func encode(latitude: Double, longitude: Double, _ precision: Int = Geohash.defaultPrecision) -> MKMapRect {
        return self.geohashbox(latitude: latitude, longitude: longitude, precision)!.mapRect
    }

    public static func encode(latitude: Double, longitude: Double, _ precision: Int = Geohash.defaultPrecision) -> MKCoordinateRegion {
        return self.geohashbox(latitude: latitude, longitude: longitude, precision)!.coordinateRegion
    }
}
#endif
