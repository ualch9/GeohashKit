# GeohashKit
![Swift](https://github.com/ualch9/GeohashKit/workflows/Swift/badge.svg)

GeohashKit is a native Swift implementation of the [Geohash hashing algorithm](https://www.movable-type.co.uk/scripts/geohash.html). Supporting encode, decode and neighbor search. The original Swift (v1) implementation is from [maximveksler/GeohashKit](https://github.com/maximveksler/GeohashKit). The new (v2) implementation uses a data structure to define the Geohash as a rectangular cell, rather than just a string.

## Platforms
- iOS, macOS, watchOS, tvOS
- Ubuntu

## API

### v2
A `Geohash` is a data structure.

#### Encode
```swift
let geohash = Geohash(coordinates: (42.6, -5.6), precision: 5)
print(geohash.geohash)      // "ezs42"
```

#### Decode
```swift
let geohash = Geohash(geohash: "ezs42")
print(geohash.coordinates)  // (latitude: 42.60498046875, longitude: -5.60302734375)
```

#### Neighbors
```swift
let neighbors = Geohash(geohash: "u000").neighbors  // Returns an array of neighbor geohash cells.
print(neighbors.north)                              // Get the north (top) cell.
print(geohash.neighbors.all.map { $0.geohash })     // ["u001", "u003", "u002", "spbr", "spbp", "ezzz", "gbpb", "gbpc"]
```

#### MapKit
```swift
let geohash = Geohash(geohash: "ezs42")
let region: MKCoordinateRegion = geohash.region
```

#### Re: Precision
I purposely left out a precision enum. I found that explaining the approximate size of the cell at 
a given precision was confusing, it is difficult to explain a size without using numbers (`case 2500km` is not valid Swift). 
Geohashes are rectangular Mercator cells with true size dependent on the latitude, so 
defining a `case twentyFiveHundredKilometers` is still not necessarily true.

### v1 (maximveksler/GeohashKit)
To use the maximveksler-compatible API, checkout exactly  `1.0`:
```swift
.package(url: "https://github.com/ualch9/geohashkit.git", .exact("1.0"))
```

#### Encode
```swift
Geohash.encode(latitude: 42.6, longitude: -5.6) // "ezs42"
```

#### Specify desired precision
```swift
Geohash.encode(latitude: -25.382708, longitude: -49.265506, 12) // "6gkzwgjzn820"
```

#### Decode
```swift
Geohash.decode("ezs42")! // (latitude: 42.60498046875, longitude: -5.60302734375)
```

#### Neighbor Search
```swift
Geohash.neighbors("u000")! // ["u001", "u003", "u002", "spbr", "spbp", "ezzz", "gbpb", "gbpc"]
```

## Install
Use Swift Package Manager.

## License
MIT License.
