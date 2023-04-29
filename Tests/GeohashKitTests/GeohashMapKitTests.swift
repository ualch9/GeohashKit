import XCTest
@testable import GeohashKit

#if canImport(MapKit)
import MapKit

final class GeohashMapKitTests: XCTestCase {
    func testHashesInRegion() {
        let captiolHill = MKMapRect(
            x: 43000993.632010244,
            y: 93716493.6709905,
            width: 15247.761742688715,
            height: 24753.363981068134
        )

        let region = MKCoordinateRegion(captiolHill)
        let geohashes = region.geohashes(precision: 6)

        for geohash in geohashes {
            let geohashRegion = MKMapRect(geohash.region)
            print(geohashRegion)
        }
    }

    static var allTests = [
        ("testHashesInRegion", testHashesInRegion)
    ]
}

#endif
