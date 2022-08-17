//
//  YelpAttribution.swift
//  City Sights App
//
//  Created by Pouria Tolouei on 16/08/2022.
//

import SwiftUI

struct YelpAttribution: View {
    
    var link: String
    
    var body: some View {
        
        Link(destination: URL(string: link) ?? URL(fileURLWithPath: "")) {
            
            Image("yelp")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
        }
    }
}

struct YelpAttribution_Previews: PreviewProvider {
    static var previews: some View {
        YelpAttribution(link: "https://yelp.ca")
    }
}
