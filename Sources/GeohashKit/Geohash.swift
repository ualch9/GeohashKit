//
//  Geohash.swift
//  Original by Maxim Veksler. Redistributed under MIT license.
//

enum Parity {
    case even, odd
}

prefix func !(a: Parity) -> Parity {
    return a == .even ? .odd : .even
}

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
    private static let DecimalToBase32Map = Array("0123456789bcdefghjkmnpqrstuvwxyz") // decimal to 32base mapping (0 => "0", 31 => "z")
    private static let Base32BitflowInit: UInt8 = 0b10000

    // MARK: - Public properties
    public var latitude: Double {
        return (self.north + self.south) / 2
    }

    public var longitude: Double {
        return (self.east + self.west) / 2
    }

    public var size: Coordinates {
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

    public let geohash: Hash
    public var precision: Int {
        return geohash.count
    }

    // MARK: - Private properties
    let north: Double
    let west: Double
    let south: Double
    let east: Double

    // MARK: - Initializers

    public init(coordinates: Coordinates, precision: Int = Geohash.defaultPrecision) {
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)

        // to be generated result.
        var generatedHash = String()

        // Loop helpers
        var parity_mode = Parity.even;
        var base32char = 0
        var bit = Geohash.Base32BitflowInit

        repeat {
            switch (parity_mode) {
            case .even:
                let mid = (lon.0 + lon.1) / 2
                if (coordinates.longitude >= mid) {
                    base32char |= Int(bit)
                    lon.0 = mid;
                } else {
                    lon.1 = mid;
                }
            case .odd:
                let mid = (lat.0 + lat.1) / 2
                if(coordinates.latitude >= mid) {
                    base32char |= Int(bit)
                    lat.0 = mid;
                } else {
                    lat.1 = mid;
                }
            }

            // Flip between Even and Odd
            parity_mode = !parity_mode
            // And shift to next bit
            bit >>= 1

            if(bit == 0b00000) {
                generatedHash += String(Geohash.DecimalToBase32Map[base32char])
                bit = Geohash.Base32BitflowInit // set next character round.
                base32char = 0
            }

        } while generatedHash.count < precision

        self.north = lat.1
        self.west = lon.0
        self.south = lat.0
        self.east = lon.1

        self.geohash = generatedHash
    }

    public init?(geohash hash: String) {
        var parity_mode = Parity.even
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)

        for c in hash {
            guard let bitmap = Geohash.DecimalToBase32Map.firstIndex(of: c) else {
                // Break on non geohash code char.
                return nil
            }

            var mask = Int(Geohash.Base32BitflowInit)
            while mask != 0 {

                switch (parity_mode) {
                case .even:
                    if(bitmap & mask != 0) {
                        lon.0 = (lon.0 + lon.1) / 2
                    } else {
                        lon.1 = (lon.0 + lon.1) / 2
                    }
                case .odd:
                    if(bitmap & mask != 0) {
                        lat.0 = (lat.0 + lat.1) / 2
                    } else {
                        lat.1 = (lat.0 + lat.1) / 2
                    }
                }

                parity_mode = !parity_mode
                mask >>= 1
            }
        }

        self.north = lat.1
        self.west = lon.0
        self.south = lat.0
        self.east = lon.1

        self.geohash = hash
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
            latitude =  self.latitude + self.size.latitude // North is upper in the latitude scale
            longitude = self.longitude
        case .south:
            latitude =  self.latitude - self.size.latitude // South is lower in the latitude scale
            longitude = self.longitude
        case .east:
            latitude =  self.latitude
            longitude = self.longitude + self.size.longitude // East is bigger in the longitude scale
        case .west:
            latitude =  self.latitude
            longitude = self.longitude - self.size.longitude // West is lower in the longitude scale
        }

        return Geohash(coordinates: (latitude, longitude), precision: self.precision)
    }
}
