# GeohashKit

GeohashKit is a native Swift implementation of the geohash hashing algorithem. Supporting encode, decode and neighbor search. This is an indirect fork of [maximveksler/Geohashkit](https://github.com/maximveksler/GeohashKit), meant for Swift Package Manager support.

## API

### Encode
```swift
Geohash.encode(latitude: 42.6, longitude: -5.6) // "ezs42"
```

###### Specify desired precision
```swift
Geohash.encode(latitude: -25.382708, longitude: -49.265506, 12) // "6gkzwgjzn820"
```

### Decode
```swift
Geohash.decode("ezs42")! // (latitude: 42.60498046875, longitude: -5.60302734375)
```

### Neighbor Search
```swift
Geohash.neighbors("u000")! // ["u001", "u003", "u002", "spbr", "spbp", "ezzz", "gbpb", "gbpc"]
```

## Install
Use Swift Package Manager.

## License
MIT License.
