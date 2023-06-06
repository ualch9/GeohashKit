//
//  GeohashCache+Rehashable.swift
//
//
//  Created by Alan Chu on 6/5/23.
//

#if canImport(CoreLocation)
import CoreLocation

public protocol Geohashable {
    var coordinates: CLLocationCoordinate2D { get }
}

enum GeohashableError: Error {
    case rehashFailed(String)
}

extension GeohashCache {
    public mutating func insert<GeohashableArrayElement: Geohashable>(_ newElement: GeohashableArrayElement)
        where Element == Array<GeohashableArrayElement>
    {
        let geohash = Geohash(newElement.coordinates, precision: self.geohashPrecision)

        self.cache[geohash, default: []].append(newElement)
    }

    /// - precondition: `precision` is a non-zero positive integer.
    /// - throws: ``GeohashableError`` if an error occurs while rehashing to a lower precision.
    public mutating func rehash<GeohashableArrayElement: Geohashable>(precision: Int) throws
        where Element == Array<GeohashableArrayElement>
    {
        precondition(precision > 0)

        // A lower precision involves truncating the existing geohash string.
        func rehashLowerPrecision(precision newPrecision: Int) throws -> [Geohash: Element] {
            var newCache: [Geohash: Element] = [:]

            for (_, keyValue) in self.cache.enumerated() {
                let truncated = keyValue.key.geohash.prefix(newPrecision)
                guard let newGeohash = Geohash(geohash: String(truncated)) else {
                    throw GeohashableError.rehashFailed("Unexpected geohash truncation result")
                }

                newCache[newGeohash, default: []].append(contentsOf: keyValue.value)
            }

            return newCache
        }

        // A higher precision involves recalculating the geohash.
        func rehashHigherPrecision(precision: Int) -> [Geohash: Element] {
            var newCache: [Geohash: Element] = [:]

            for collection in self.elements {
                for element in collection {
                    let newGeohash = Geohash(element.coordinates, precision: precision)
                    newCache[newGeohash, default: []].append(element)
                }
            }

            return newCache
        }

        if precision < self.geohashPrecision {
            self.cache = try rehashLowerPrecision(precision: precision)
            self.geohashPrecision = precision
        } else if precision > self.geohashPrecision {
            self.cache = rehashHigherPrecision(precision: precision)
            self.geohashPrecision = precision
        } else {
            return  // Equal geohash precision.
        }
    }
}

#endif
