import XCTest
@testable import GeohashKit

#if canImport(CoreLocation)
import CoreLocation
#endif

final class GeohashCacheTests: XCTestCase {
    #if canImport(CoreLocation)
    struct TestLocation: Geohashable, Hashable {
        var coordinates: CLLocationCoordinate2D

        init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(coordinates.latitude)
            hasher.combine(coordinates.longitude)
        }

        static func == (lhs: GeohashCacheTests.TestLocation, rhs: GeohashCacheTests.TestLocation) -> Bool {
            return
                lhs.coordinates.latitude == rhs.coordinates.latitude &&
                lhs.coordinates.longitude == rhs.coordinates.longitude
        }
    }

    func testRehash() throws {
        let c23nbsLocations: [TestLocation] = [
            .init(latitude: 47.61524, longitude: -122.32080),   // Broadway & Pine (c23nbs)
            .init(latitude: 47.61515, longitude: -122.31128),   // Madison & Pine (c23nbs)
        ]

        let c23nbeLocations: [TestLocation] = [
            .init(latitude: 47.61117, longitude: -122.32080),   // Madison & Broadway (c23nbe)
        ]

        let allLocations = c23nbsLocations + c23nbeLocations

        var collection = GeohashCache<[TestLocation]>(precision: 6)
        for location in allLocations {
            collection.insert(location)
        }

        XCTAssertEqual(collection.geohashes.count, 2)
        XCTAssertEqual(collection["c23nbs"], c23nbsLocations)
        XCTAssertEqual(collection["c23nbe"], c23nbeLocations)

        try collection.rehash(precision: 5)
        XCTAssertEqual(collection.geohashes.count, 1)

        // Check if the rehash is the same elements, regardless of order
        let collectionSet = try Set(XCTUnwrap(collection["c23nb"]))
        XCTAssertEqual(collectionSet, Set(allLocations))

        try collection.rehash(precision: 6)
        XCTAssertEqual(collection.geohashes.count, 2)
        XCTAssertEqual(collection["c23nbs"], c23nbsLocations)
        XCTAssertEqual(collection["c23nbe"], c23nbeLocations)
    }

    #endif
}
