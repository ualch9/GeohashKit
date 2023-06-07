//
//  GeohashCache.swift
//  
//
//  Created by Alan Chu on 6/5/23.
//

#if canImport(CoreLocation)
import CoreLocation

public protocol Geohashable: Equatable {
    var coordinates: CLLocationCoordinate2D { get }
}

enum GeohashableError: Error {
    case rehashFailed(String)
}

/// A data structure that organizes elements in a key-value style based on their Geohash.
public struct GeohashCache<Element: Geohashable> {
    public struct Index: Equatable {
        let geohash: Geohash
        let arrayIndex: Int
    }

    public var geohashes: [Geohash] {
        Array(cache.keys)
    }

    /// A flattened collection of all elements.
    public var elements: [Element] {
        return cache.values.flatMap { $0 }
    }

    public internal(set) var geohashPrecision: Int

    private var cache: [Geohash: [Element]] = [:]

    public subscript(_ hash: String) -> [Element]? {
        guard let geohash = Geohash(geohash: hash) else {
            return nil
        }

        return cache[geohash]
    }

    public subscript(_ geohash: Geohash) -> [Element]? {
        return cache[geohash]
    }

    public subscript(_ index: Index) -> Element? {
        return cache[index.geohash]?[index.arrayIndex]
    }

    public init(precision: Int) {
        self.geohashPrecision = precision
        self.cache = [:]
    }

    public func contains(geohash: Geohash) -> Bool {
        return cache.keys.contains(geohash)
    }

    public func index(of element: Element) -> Index? {
        let geohash = Geohash(element.coordinates, precision: geohashPrecision)
        guard let index = self.cache[geohash]?.firstIndex(where: { candidate in
            candidate == element
        }) else {
            return nil
        }

        return Index(geohash: geohash, arrayIndex: index)
    }

    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        guard let index = self.index(of: element) else {
            return nil
        }

        return self.remove(at: index)
    }

    @discardableResult
    public mutating func remove(at index: Index) -> Element? {
        return self.cache[index.geohash]?.remove(at: index.arrayIndex)
    }

    public mutating func insert(_ newElement: Element) {
        let geohash = Geohash(newElement.coordinates, precision: self.geohashPrecision)
        self.cache[geohash, default: []].append(newElement)
    }

    /// - precondition: `precision` is a non-zero positive integer.
    /// - throws: ``GeohashableError`` if an error occurs while rehashing to a lower precision.
    public mutating func rehash(precision: Int) throws {
        precondition(precision > 0)

        // A lower precision involves truncating the existing geohash string.
        func rehashLowerPrecision(precision newPrecision: Int) throws -> [Geohash: [Element]] {
            var newCache: [Geohash: [Element]] = [:]

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
        func rehashHigherPrecision(precision: Int) -> [Geohash: [Element]] {
            var newCache: [Geohash: [Element]] = [:]

            for collection in self.cache.values {
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

    /// Updates/Inserts element for the given geohash key, and returns the difference result.
    /// - If the geohash key did not previously exist, the difference result will include the new Geohash in its `keyChanges`, and the new element in its `elementChanges`.
    /// - If the geohash key did previously exist, the difference result will only include the new element in its `elementChanges`.
//    @discardableResult
//    public mutating func upsert(geohash: Geohash, element: Element) -> GeohashCacheDifference<Geohash, Element> {
//        let geohashDiff: [GeohashCacheDifference<Geohash, Element>.Change<Geohash>]
//        var elementDiff: [GeohashCacheDifference<Geohash, Element>.Change<Element>] = []
//
//        if self.contains(geohash: geohash), let existingElement = cache[geohash] {
//            geohashDiff = []
//            elementDiff.append(.removal(existingElement))
//        } else {
//            geohashDiff = [.insertion(geohash)]
//        }
//
//        self.cache[geohash] = element
//        elementDiff.append(.insertion(element))
//
//        return GeohashCacheDifference(keyChanges: geohashDiff, elementChanges: elementDiff)
//    }
//
//    /// Removes non-active geohashes from memory.
//    @discardableResult
//    public mutating func discardContentIfPossible() -> GeohashCacheDifference<Geohash, Element> {
//        var geohashDiff: [GeohashCacheDifference<Geohash, Element>.Change<Geohash>] = []
//        var elementDiff: [GeohashCacheDifference<Geohash, Element>.Change<Element>] = []
//
//        // TODO: Don't remove elements of neighboring active-geohashes.
//        for (geohash, _) in cache where !activeGeohashes.contains(geohash) {
//            if let elements = self.cache[geohash] {
//                elementDiff.append(.removal(elements))
//            }
//            geohashDiff.append(.removal(geohash))
//            self.cache[geohash] = nil
//        }
//
//        return GeohashCacheDifference(keyChanges: geohashDiff, elementChanges: elementDiff)
//    }
}

#endif
