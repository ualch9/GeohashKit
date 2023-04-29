//
//  Geohash+MapKit.swift
//
//  Created by Alan Chu on 8/2/20.
//

#if canImport(MapKit)
import MapKit

extension Geohash {
    /// The geohash cell expressed as an `MKCoordinateRegion`.
    public var region: MKCoordinateRegion {
        let coordinates = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let size = self.size

        let span = MKCoordinateSpan(latitudeDelta: size.latitude,
                                    longitudeDelta: size.longitude)

        return MKCoordinateRegion(center: coordinates, span: span)
    }

    func intersects(_ region: MKCoordinateRegion) -> Bool {
        let lhsRect = MKMapRect(self.region)
        let rhsRect = MKMapRect(region)

        return lhsRect.intersects(rhsRect)
    }
}

extension MKCoordinateRegion {
    public func geohashes(precision: Int) -> Set<Geohash> {
        guard let origin = Geohash(self.center, precision: precision) else {
            return []
        }

        // Get the most northwest geohash of the region
        let northwestHash = recursiveUntilBounds(going: .west, recursiveUntilBounds(going: .north, origin))

        var hashes: Set<Geohash> = []

        // Snakes thru geohash grids
        var currentLeftMostGeohash: Geohash = northwestHash
        
        repeat {
            var currentGeohash: Geohash = currentLeftMostGeohash

            repeat {
                hashes.insert(currentGeohash)
                currentGeohash = currentGeohash.neighbor(direction: .east)!
            } while currentGeohash.intersects(self)

            currentLeftMostGeohash = currentLeftMostGeohash.neighbor(direction: .south)!
        } while currentLeftMostGeohash.intersects(self)

        return hashes
    }

    /// Recursively traverses Geohashes in the specified direction until it reaches the top of this MKCoordinateRegion.
    private func recursiveUntilBounds(going direction: Geohash.CompassPoint, _ geohash: Geohash) -> Geohash {
        guard let neighbor = geohash.neighbor(direction: direction) else {
            return geohash
        }

        let selfRect = MKMapRect(self)
        let neighborRect = MKMapRect(neighbor.region)

        if selfRect.intersects(neighborRect) {
            return recursiveUntilBounds(going: direction, neighbor)
        } else {
            return geohash
        }
    }
}

public extension MKMapRect {
    init(_ coordinateRegion: MKCoordinateRegion) {
        let topLeft = CLLocationCoordinate2D(
            latitude: coordinateRegion.center.latitude + (coordinateRegion.span.latitudeDelta/2.0),
            longitude: coordinateRegion.center.longitude - (coordinateRegion.span.longitudeDelta/2.0)
        )

        let bottomRight = CLLocationCoordinate2D(
            latitude: coordinateRegion.center.latitude - (coordinateRegion.span.latitudeDelta/2.0),
            longitude: coordinateRegion.center.longitude + (coordinateRegion.span.longitudeDelta/2.0)
        )

        let topLeftMapPoint = MKMapPoint(topLeft)
        let bottomRightMapPoint = MKMapPoint(bottomRight)

        let origin = MKMapPoint(x: topLeftMapPoint.x,
                                y: topLeftMapPoint.y)
        let size = MKMapSize(width: fabs(bottomRightMapPoint.x - topLeftMapPoint.x),
                             height: fabs(bottomRightMapPoint.y - topLeftMapPoint.y))

        self.init(origin: origin, size: size)
    }
}
#endif

#if canImport(CoreLocation)
import CoreLocation

extension Geohash {
    /// Creates a geohash based on the provided coordinates and the requested precision.
    /// - parameter coordinates: The coordinates to use for generating the hash.
    /// - parameter precision: The number of characters to generate.
    ///     ```
    ///     Precision   Cell width      Cell height
    ///             1   ≤ 5,000km   x   5,000km
    ///             2   ≤ 1,250km   x   625km
    ///             3   ≤ 156km     x   156km
    ///             4   ≤ 39.1km    x   19.5km
    ///             5   ≤ 4.89km    x   4.89km
    ///             6   ≤ 1.22km    x   0.61km
    ///             7   ≤ 153m      x   153m
    ///             8   ≤ 38.2m     x   19.1m
    ///             9   ≤ 4.77m     x   4.77m
    ///            10   ≤ 1.19m     x   0.596m
    ///            11   ≤ 149mm     x   149mm
    ///            12   ≤ 37.2mm    x   18.6mm
    ///     ```
    /// - returns: If the specified coordinates are invalid, this returns nil.
    public init?(_ coordinates: CLLocationCoordinate2D, precision: Int) {
        self.init(coordinates: (coordinates.latitude, coordinates.longitude), precision: precision)
    }
}
#endif
