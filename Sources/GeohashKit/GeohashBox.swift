//
//  GeohashBox.swift
//  Original by Maxim Veksler. Redistributed under MIT license.
//

struct GeohashBox {
    let hash: String

    let north: Double // top latitude
    let west: Double // left longitude
    let south: Double // bottom latitude
    let east: Double // right longitude
    var point: (latitude: Double, longitude: Double) {
        let latitude = (self.north + self.south) / 2
        let longitude = (self.east + self.west) / 2

        return (latitude: latitude, longitude: longitude)
    }

    var size: (latitude: Double, longitude: Double) {
        // * possible case examples:
        //
        // 1. bbox.north = 60, bbox.south = 40; point.latitude = 50, size.latitude = 20 ✅
        // 2. bbox.north = -40, bbox.south = -60; point.latitude = -50, size.latitude = 20 ✅
        // 3. bbox.north = 10, bbox.south = -10; point.latitude = 0, size.latitude = 20 ✅
        let latitude = north - south

        // * possible case examples:
        //
        // 1. bbox.east = 60, bbox.west = 40; point.longitude = 50, size.longitude = 20 ✅
        // 2. bbox.east = -40, bbox.west = -60; point.longitude = -50, size.longitude = 20 ✅
        // 3. bbox.east = 10, bbox.west = -10; point.longitude = 0, size.longitude = 20 ✅
        let longitude = east - west


        return (latitude: latitude, longitude: longitude)
    }
}

#if canImport(MapKit)
import MapKit

extension GeohashBox {
    var mapRect: MKMapRect {
        let point = self.point
        let size = self.size

        return MKMapRect.init(x: point.latitude, y: point.longitude, width: size.latitude, height: size.longitude)
    }
}
#endif
