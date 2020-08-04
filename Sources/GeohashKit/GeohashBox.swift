//
//  GeohashBox.swift
//  Original by Maxim Veksler. Redistributed under MIT license.
//

enum Parity {
    case even, odd
}

prefix func !(a: Parity) -> Parity {
    return a == .even ? .odd : .even
}

struct GeohashBox {
    // MARK: - Constants
    private static let DecimalToBase32Map = Array("0123456789bcdefghjkmnpqrstuvwxyz") // decimal to 32base mapping (0 => "0", 31 => "z")
    private static let Base32BitflowInit: UInt8 = 0b10000

    // MARK: - Properties
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

    init?(coordinates: Geohash.Coordinates, precision: Int) {
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)

        // to be generated result.
        var geohash = String()

        // Loop helpers
        var parity_mode = Parity.even;
        var base32char = 0
        var bit = GeohashBox.Base32BitflowInit

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
                geohash += String(GeohashBox.DecimalToBase32Map[base32char])
                bit = GeohashBox.Base32BitflowInit // set next character round.
                base32char = 0
            }

        } while geohash.count < precision

        self.hash = geohash
        self.north = lat.1
        self.west = lon.0
        self.south = lat.0
        self.east = lon.1
    }

    init?(hash: String) {
        var parity_mode = Parity.even
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)

        for c in hash {
            guard let bitmap = GeohashBox.DecimalToBase32Map.firstIndex(of: c) else {
                // Break on non geohash code char.
                return nil
            }

            var mask = Int(GeohashBox.Base32BitflowInit)
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

        self.hash = hash
        self.north = lat.1
        self.west = lon.0
        self.south = lat.0
        self.east = lon.1
    }
}
