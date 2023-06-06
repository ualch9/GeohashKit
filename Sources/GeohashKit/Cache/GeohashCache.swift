//
//  GeohashCache.swift
//  
//
//  Created by Alan Chu on 6/5/23.
//

/// A data structure that organizes elements in a key-value style based on their Geohash.
public struct GeohashCache<Element> {
    public var geohashes: [Geohash] {
        Array(cache.keys)
    }

    /// A flattened collection of all elements.
    public var elements: [Element] {
        Array(cache.values)
    }

    public internal(set) var geohashPrecision: Int
    public var activeGeohashes: Set<Geohash> = []

    var cache: [Geohash: Element] = [:]

    public subscript(_ hash: String) -> Element? {
        get {
            guard let geohash = Geohash(geohash: hash) else {
                return nil
            }

            return cache[geohash]
        }
    }

    public subscript(_ geohash: Geohash) -> Element? {
        get {
            return cache[geohash]
        }
        set {
            cache[geohash] = newValue
        }
    }

    public init(precision: Int) {
        self.geohashPrecision = precision
        self.activeGeohashes = []
        self.cache = [:]
    }

    public func contains(geohash: Geohash) -> Bool {
        return cache.keys.contains(geohash)
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

