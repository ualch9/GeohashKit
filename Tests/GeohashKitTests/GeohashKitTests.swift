import XCTest
@testable import GeohashKit

final class GeohashKitTests: XCTestCase {
    // - MARK: encode
    func testEncode() {
        // geohash.org
        XCTAssertEqual(Geohash(coordinates: (-25.383, -49.266), precision: 8)?.geohash, "6gkzwgjt")
        XCTAssertEqual(Geohash(coordinates: (-25.382708, -49.265506), precision: 12)?.geohash, "6gkzwgjzn820")
        XCTAssertEqual(Geohash(coordinates: (-25.427, -49.315), precision: 8)?.geohash, "6gkzmg1u")

        // Geohash Tool
        XCTAssertEqual(Geohash(coordinates: (-31.953, 115.857), precision: 8)?.geohash, "qd66hrhk")
        XCTAssertEqual(Geohash(coordinates: (38.89710201881826, -77.03669792041183), precision: 12)?.geohash, "dqcjqcp84c6e")

        // Narrow samples.
        XCTAssertEqual(Geohash(coordinates: (42.6, -5.6), precision: 5)?.geohash, "ezs42")
    }

    func testEncodeDefaultPrecision() {
        // Narrow samples.
        XCTAssertEqual(Geohash(coordinates: (42.6, -5.6))?.geohash, "ezs42")

        // XCTAssertEqual(Geohash.encode(latitude: 0, longitude: 0), "s000") // => "s0000" :( hopefully will be resovled by #Issue:1
    }

    // - MARK: decode
    /// Testing latitude & longitude decode correctness, with epsilon precision.
    func aDecodeUnitTest(_ hash: String, _ expectedLatitude: Double, _ expectedLongitude: Double) {
        let geohash = Geohash(geohash: hash)!

        XCTAssertEqual(geohash.latitude, expectedLatitude, accuracy: Double(Float.ulpOfOne))
        XCTAssertEqual(geohash.longitude, expectedLongitude, accuracy: Double(Float.ulpOfOne))
    }

    func testDecode() {
        aDecodeUnitTest("ezs42", 42.60498046875, -5.60302734375)
        aDecodeUnitTest("spey61y", 43.296432495117, 5.3702545166016)
    }

    func compareNeighbors(origin: String, expectedNeighbors: [String]) {
        let geohash = Geohash(geohash: origin)!
        let originNeighbors = geohash.neighbors?.all.map { $0.geohash }
        XCTAssertEqual(originNeighbors, expectedNeighbors)
    }

    // - MARK: neighbors
    func testNeighbors() {
        // Bugrashov, Tel Aviv, Israel
        compareNeighbors(origin: "sv8wrqfm", expectedNeighbors: ["sv8wrqfq", "sv8wrqfw", "sv8wrqft", "sv8wrqfs", "sv8wrqfk", "sv8wrqfh", "sv8wrqfj", "sv8wrqfn"])

        // Meridian Gardens
        compareNeighbors(origin: "gcpuzzzzz", expectedNeighbors: ["gcpvpbpbp", "u10j00000", "u10hbpbpb", "u10hbpbp8", "gcpuzzzzx", "gcpuzzzzw", "gcpuzzzzy", "gcpvpbpbn"])

        // Overkills are fun!
        compareNeighbors(origin: "cbsuv7ztq43452343239", expectedNeighbors: ["cbsuv7ztq4345234323d", "cbsuv7ztq4345234323f", "cbsuv7ztq4345234323c", "cbsuv7ztq4345234323b", "cbsuv7ztq43452343238", "cbsuv7ztq43452343232", "cbsuv7ztq43452343233", "cbsuv7ztq43452343236"])

        // France
        compareNeighbors(origin: "u000", expectedNeighbors: ["u001", "u003", "u002", "spbr", "spbp", "ezzz", "gbpb", "gbpc"])
    }

    static var allTests = [
        ("testEncode", testEncode),
        ("testEncodeDefaultPrecision", testEncodeDefaultPrecision),
        ("testDecode", testDecode),
        ("testNeighbors", testNeighbors)
    ]
}
