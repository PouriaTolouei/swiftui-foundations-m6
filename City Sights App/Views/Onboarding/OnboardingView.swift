//
//  OnboardingView.swift
//  City Sights App
//
//  Created by Pouria Tolouei on 16/08/2022.
//

import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var tabSelection = 0
    
    private let blue = Color(red: 0/255, green: 130/255, blue: 167/255)
    private let turquiose = Color(red: 55/255, green: 197/255, blue: 192/255)
    
    var body: some View {
        
        VStack {
            
            // Tab View
            TabView(selection: $tabSelection) {
                
                // First tab
                VStack(spacing: 20) {
                    
                    Image("city2")
                        .resizable()
                        .scaledToFit()
                    
                    Text("Welcome to City Sights!")
                        .bold()
                        .font(.title)
                    
                    Text("City Sights helps you find the best of the city!")
                        
                }
                .tag(0)
                
                // Second tab
                VStack(spacing: 20) {
                    
                    Image("city1")
                        .resizable()
                        .scaledToFit()
                    
                    Text("Ready to discover your city?")
                        .bold()
                        .font(.title)
                    
                    Text("We'll show you the best restaurants, venues and more, based on your location!")
                }
                
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(.white)
            
            // Button
            Button {
                
                // Detect which tab it is
                if tabSelection == 0 {
                    
                    tabSelection = 1
                }
                else {
                    // Request for geolocation permission
                    model.requestGeoLocationPermission()
                }
                
                
            } label: {
                
                ZStack {
                    
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 48)
                        .cornerRadius(10)
                    
                    Text(tabSelection == 0 ? "Next" : "Get My Location ")
                        .bold()
                        .padding()
                }
            }
            .tint(tabSelection == 0 ? blue : turquiose)
            .padding()
            
            Spacer()

        }
        .padding()
        .background(tabSelection == 0 ? blue : turquiose)
        .ignoresSafeArea()
        
        
       
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
