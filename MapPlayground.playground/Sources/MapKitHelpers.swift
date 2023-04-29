import MapKit

extension MKPolygon {
    public convenience init(coordinateRegion: MKCoordinateRegion) {
        let coordinates = coordinateRegion.cornerCoordinates
        self.init(coordinates: coordinates, count: coordinates.count)
    }
}

extension MKCoordinateRegion {
    public var cornerCoordinates: [CLLocationCoordinate2D] {
        var points: [CLLocationCoordinate2D] = []

        let sw = CLLocationCoordinate2D(
            latitude: center.latitude - (span.latitudeDelta / 2.0),
            longitude: center.longitude - (span.longitudeDelta / 2.0)
        )
        points.append(sw)

        let nw = CLLocationCoordinate2D(
            latitude: center.latitude + (span.latitudeDelta / 2.0),
            longitude: center.longitude - (span.longitudeDelta / 2.0)
        )
        points.append(nw)

        let ne = CLLocationCoordinate2D(
            latitude: center.latitude + (span.latitudeDelta / 2.0),
            longitude: center.longitude + (span.longitudeDelta / 2.0)
        )
        points.append(ne)

        let se = CLLocationCoordinate2D(
            latitude: center.latitude - (span.latitudeDelta / 2.0),
            longitude: center.longitude + (span.longitudeDelta / 2.0)
        )
        points.append(se)

        return points
    }
}
