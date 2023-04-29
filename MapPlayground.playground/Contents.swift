//: A MapKit based Playground

import MapKit
import PlaygroundSupport
import GeohashKit

// MARK: - Boilerplate for MapView delegate
class PlaygroundMapViewDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? GeohashPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = .black
            renderer.lineWidth = 3.0
            renderer.fillColor = UIColor.purple.withAlphaComponent(0.5)

            return renderer
        }

        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = .black
            renderer.lineWidth = 1.5
            renderer.fillColor = UIColor.green.withAlphaComponent(0.3)

            return renderer
        }

        fatalError()
    }
}

class GeohashPolygon: MKPolygon {
    var geohash: Geohash!

    static func create(_ geohash: Geohash) -> GeohashPolygon {
        let instance = GeohashPolygon(coordinateRegion: geohash.region)
        instance.geohash = geohash
        return instance
    }
}

// MARK: - Playground Code

// Create a MKMapView
let mapViewDelegate = PlaygroundMapViewDelegate()
let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))
mapView.delegate = mapViewDelegate

// Add Seattle Capitol Hill overlay
let capitolHill = MKMapRect(
    x: 43000993.632010244,
    y: 93716493.6709905,
    width: 15247.761742688715,
    height: 24753.363981068134
)

let capitolHillRegion = MKCoordinateRegion(capitolHill)
let capitolHillPolygon = MKPolygon(coordinateRegion: capitolHillRegion)

mapView.setRegion(capitolHillRegion, animated: true)
mapView.addOverlay(capitolHillPolygon, level: .aboveRoads)

let regions = capitolHillRegion.geohashes(precision: 7)
mapView.addOverlays(regions.map(GeohashPolygon.create), level: .aboveLabels)

// Add the created mapView to our Playground Live View
PlaygroundPage.current.liveView = mapView
