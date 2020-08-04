//
//  Geohash.swift
//  Original by Maxim Veksler. Redistributed under MIT license.
//

public struct Geohash {
    // MARK: - Types
    enum CompassPoint {
        /// Top
        case north

        /// Bottom
        case south

        /// Right
        case east

        /// Left
        case west
    }

    public typealias Coordinates = (latitude: Double, longitude: Double)
    public typealias Hash = String

    // MARK: - Constants
    public static let defaultPrecision = 5

    // MARK: - Properties
    public var latitude: Double     { self.box.point.latitude }
    public var longitude: Double    { self.box.point.longitude }
    public var geohash: Hash        { self.box.hash }
    public let precision: Int

    let box: GeohashBox

    // MARK: - Initializers

    public init?(coordinates: Coordinates, precision: Int = Geohash.defaultPrecision) {
        guard let box = GeohashBox(coordinates: coordinates, precision: precision) else {
            return nil
        }

        self.precision = precision
        self.box = box
    }

    public init?(geohash: String) {
        guard let box = GeohashBox(hash: geohash) else { return nil }
        self.precision = geohash.count
        self.box = box
    }

    // MARK: - Neighbors
    public struct Neighbors {
        public let origin: Geohash
        public let north: Geohash
        public let northeast: Geohash
        public let east: Geohash
        public let southeast: Geohash
        public let south: Geohash
        public let southwest: Geohash
        public let west: Geohash
        public let northwest: Geohash

        /// The neighboring geohashes sorted by compass direction in clockwise starting with `North`.
        public var all: [Geohash] {
            return [
                north,
                northeast,
                east,
                southeast,
                south,
                southwest,
                west,
                northwest
            ]
        }
    }

    /// - returns: The neighboring geohashes.
    public var neighbors: Neighbors? {
        guard
            let n = neighbor(direction: .north),    // N
            let s = neighbor(direction: .south),    // S
            let e = neighbor(direction: .east),     // E
            let w = neighbor(direction: .west),     // W
            let ne = n.neighbor(direction: .east),  // NE
            let nw = n.neighbor(direction: .west),  // NW
            let se = s.neighbor(direction: .east),  // SE
            let sw = s.neighbor(direction: .west)   // SW
        else { return nil }

        return Neighbors(origin: self, north: n, northeast: ne, east: e, southeast: se, south: s, southwest: sw, west: w, northwest: nw)
    }

    func neighbor(direction: CompassPoint) -> Geohash? {
        let latitude: Double
        let longitude: Double
        switch direction {
        case .north:
            latitude =  box.point.latitude + box.size.latitude // North is upper in the latitude scale
            longitude = self.longitude
        case .south:
            latitude =  box.point.latitude - box.size.latitude // South is lower in the latitude scale
            longitude = self.longitude
        case .east:
            latitude =  self.latitude
            longitude = box.point.longitude + box.size.longitude // East is bigger in the longitude scale
        case .west:
            latitude =  self.latitude
            longitude = box.point.longitude - box.size.longitude // West is lower in the longitude scale
        }

        return Geohash(coordinates: (latitude, longitude), precision: self.precision)
    }
}
