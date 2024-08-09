//
//  MapView.swift
//  
//
//  Created by Alessio Rubicini on 13/08/21.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        if #available(iOS 17.0, *) {
            mapView.showsUserTrackingButton = true
        }
        
        debugPrint("Check makeUIView")
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        debugPrint("Check updateUIView")
        
        let region = MKCoordinateRegion(
            center: self.centerCoordinate,
            span: MKCoordinateSpan(
                latitudeDelta: selectedCoordinate != nil ? 0.001 : 100,
                longitudeDelta: selectedCoordinate != nil ? 0.001 : 100
            )
        )
        
        withAnimation {
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            mapView.centerCoordinate = self.centerCoordinate
        }
        
        if let selectedCoordinate = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedCoordinate
            
            withAnimation {
                view.removeAnnotations(view.annotations)
                view.addAnnotation(annotation)
            }
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView

        var gRecognizer = UILongPressGestureRecognizer()

        init(_ parent: MapView) {
            self.parent = parent
            super.init()
            self.gRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
            self.gRecognizer.delegate = self
            self.gRecognizer.minimumPressDuration = 1
            self.gRecognizer.delaysTouchesBegan = true
            self.parent.mapView.addGestureRecognizer(gRecognizer)
        }

        @objc func tapHandler(_ gesture: UILongPressGestureRecognizer) {
            
            let location = gRecognizer.location(in: self.parent.mapView)
            let coordinate = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)
            
            // Set the selected coordinates
            let clObject = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            parent.selectedCoordinate = clObject
            
            // Place the pin on the map
           
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            parent.selectedCoordinate = annotation.coordinate
        }
        
    }
}
