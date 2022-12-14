//
//  ContentModel.swift
//  City Sights App
//
//  Created by Pouria Tolouei on 10/08/2022.
//

import Foundation
import CoreLocation
import SwiftUI

class ContentModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    var locationManager = CLLocationManager()
    
    @Published var authorizationState = CLAuthorizationStatus.notDetermined
    
    @Published var restaurants = [Business]()
    @Published var sights = [Business]()
    
    @Published var placemark: CLPlacemark?
    
    let blue = Color(red: 0/255, green: 130/255, blue: 167/255)
    let turquiose = Color(red: 55/255, green: 197/255, blue: 192/255)
    
    override init() {
        
        // Init method of NSObject
        super.init()
        
        // Set content model as the delegate of the location manager
        locationManager.delegate = self
    }
    
    func requestGeoLocationPermission() {
        
        // Request permission from the user
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK - Location Manager Delegate Mehods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        // Update the authorizationState property
        authorizationState = locationManager.authorizationStatus
        
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            
            // We have permission
            // Start geolocating the user after we get permission
            locationManager.startUpdatingLocation()
        }
        else if locationManager.authorizationStatus == .denied {
            
            // We don't have permission
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Gives us the location of the user
        let userLocation = locations.first
       
        if userLocation != nil {
            
            // We have a location
            // Stop requesting tthe location after we get it once
            locationManager.stopUpdatingLocation()
            
            // Get the placemark of the user
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(userLocation!) { placemarks, error in
                
                // Check that there aren't errors
                if error == nil && placemarks != nil {
                    
                    // Take the first placemark
                    self.placemark = placemarks?.first
                    
                }
                
            }
            
            // if we have the coordinates of the user, send into Yelp API
            getBusinessrd(category: Constants.restaurantsKey, location: userLocation!)
            getBusinessrd(category: Constants.sightsKey, location: userLocation!)
        }
    }
    
    // MARK: - Yelp API methods
    
    func getBusinessrd(category: String, location: CLLocation) {
        
        // Create URL
        /*
        let urlString = "https://api.yelp.com/v3/businesses/search?latitude=\(location.coordinate.latitude)&longitide=\(location.coordinate.longitude)&categories=\(category)&limit=6"
        let url = URL(string: urlString)
         */
        var urlComponents = URLComponents(string: Constants.apiUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "categories", value: String(category)),
            URLQueryItem(name: "limit", value: "6")
        ]
        let url = urlComponents?.url
        
        if let url = url {
            
            // Create URL Request
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.addValue("Bearer \(Constants.apiKey)", forHTTPHeaderField: "Authorization")
            
            // Get URL Session
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { data, response, error in
                
                // Check that there isn't an error
                if error == nil {
                    
                    do {
                        // Parse json
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(BusinessSearch.self, from: data!)
                        
                        // Sort businesses
                        var businesses = result.businesses
                        businesses.sort { b1, b2 in
                            return b1.distance ?? 0 < b2.distance ?? 0
                        }

                        // Call the get image function of the businesses
                        for business in businesses {
                            business.getImageData()
                        }
                        
                        DispatchQueue.main.async {
                            
                            // Assign results to the appropriate property
                            switch category {
                            case Constants.sightsKey:
                                self.sights = businesses
                            case Constants.restaurantsKey:
                                self.restaurants = businesses
                            default:
                                break
                            }
                            
                        }
                    }
                    catch {
                        print(error)
                    }   
                }
            }
            
            // Start the Data Task
            dataTask.resume()
        }
    }
}
