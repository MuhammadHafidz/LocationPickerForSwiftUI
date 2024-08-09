//
//  LocationPicker.swift
//
//
//  Created by Alessio Rubicini on 13/08/21.
//

import SwiftUI
import MapKit
import MobileCoreServices

public struct LocationPicker: View {
    
    // MARK: - View properties
    
    @Environment(\.presentationMode) var presentationMode
    private var locationManager = LocationManager()
    
    let instructions: String
    @State var centerCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.7893, longitude: 113.9213)
    @State var coordinates: CLLocationCoordinate2D?
    @State private var alert = (false, "")
    let dismissOnSelection: Bool
    let onResult: (CLLocationCoordinate2D) -> Void
    
    
    /// Initialize LocationPicker view
    /// - Parameters:
    ///   - instructions: label to display on screen
    ///   - coordinates: binding to latitude/longitude coordinates
    ///   - dismissOnSelection: automatically dismiss the view when new coordinates are selected
    ///   - onResult: Result of picker
    public init(
        instructions: String = "",
        initCoordinates: CLLocationCoordinate2D?,
        dismissOnSelection: Bool = false,
        onResult: @escaping (CLLocationCoordinate2D) -> Void = {_ in}
    ) {
        self.instructions = instructions
        self.dismissOnSelection = dismissOnSelection
        self.onResult = onResult
        
        if let coordinates = initCoordinates {
            self._coordinates = .init(initialValue: coordinates)
            self._centerCoordinates = .init(initialValue: coordinates)
        } else {
            self.getSelfLocation()
        }
        
    }
    
    // MARK: - View body
    
    public var body: some View {
        
        NavigationView {
            ZStack {
                MapView(centerCoordinate: $centerCoordinates, selectedCoordinate: $coordinates)
                .edgesIgnoringSafeArea(.vertical)
                
                VStack(alignment: .trailing) {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        Spacer()
                        
                        Text(instructions)
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                            
                        }
                        .hidden()
                    }
                    .padding()
                    
                    
                    Spacer()
                    
                    if let coordinates = coordinates {
                        Button {
                            self.onResult(coordinates)
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Submit")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.accentColor)
                                )
                        }
                        .padding()
                    }
                    
                    
                }
                
            }
            
        }
        .onChange(of: coordinates) { newValue in
            if(dismissOnSelection) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func getSelfLocation(isSet: Bool = false) {
        let status = self.locationManager.getAuthorizationStatus()
        if status == .notDetermined {
            locationManager.clLocationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocations()
        }
        if let location = locationManager.currentLocation {
            centerCoordinates = location.coordinate
            if isSet {
                coordinates = location.coordinate
            }
        }
    }
}

struct LocationPicker_Previews: PreviewProvider {
    static var previews: some View {
        LocationPicker(instructions: "Tap to select coordinates", initCoordinates: CLLocationCoordinate2D(latitude: 37.333747, longitude: -122.011448))
    }
}
