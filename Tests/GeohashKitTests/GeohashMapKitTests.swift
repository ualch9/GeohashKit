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

        // Test high-precision
        XCTAssertGeohashesEqual(
            region.geohashes(precision: 6),
            ["c23nbg", "c23nbm", "c23nbu", "c23nbe", "c23nby", "c23nbx", "c23nbw", "c23nbk", "c23nbz", "c23nbq", "c23nbr", "c23nbv", "c23nbt", "c23nb7", "c23nbs"]
        )

        XCTAssertGeohashesEqual(
            region.geohashes(precision: 5),
            ["c23nb"]
        )
    }

    private func XCTAssertGeohashesEqual(_ lhs: Set<Geohash>, _ rhs: Set<String>, _ message: String = "") {
        let rhsGeohashes = rhs.compactMap(Geohash.init(geohash:))
        XCTAssertEqual(lhs, Set(rhsGeohashes), message)
    }

    static var allTests = [
        ("testHashesInRegion", testHashesInRegion)
    ]
}

#endif
