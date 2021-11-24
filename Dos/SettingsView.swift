//
//  SettingsView.swift
//  Dos
//
//  Created by Idris Khenchil on 11/24/21.
//

import SwiftUI
import StoreKit


struct SettingsView: View{
    @Environment(\.colorScheme) var colorScheme
    
    @State var darkMode = true
    
    init(){
        if colorScheme  == .dark {
            //Dark mode active
            //print("dark mode")
            darkMode = true
        }
        else{
            //Not active
            //print("light mode")
            darkMode = false
        }
    }
    
    var body: some View {
        
        
        List{
            Section(footer: Text("Made using the Product Hunt API ❤️")){
                //Toggle("Dark Mode", isOn: $darkMode)
                NavigationLink("Favorites", destination: ({
                    List{

                        Button(action: {
                            //Get favorites
                            
                            
                            
                            
                        }, label: {
                            Text("Get data")
                        })
                        
                        
                        
                        
                        
                    }.navigationBarTitle("Favorites")
                    
                }))
                
                Link(destination: URL(string: "https://www.producthunt.com")!, label: {
                    HStack{
                        Text("Product Hunt Website")
                        
                    }
                    
                })
                
                
                Button("Like the app? Rate it!", action: {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                })
                

                
                Link(destination: URL(string: "https://twitter.com/idriskhenchil")!, label: {
                    Text("Twitter")
                })
            }
        }.navigationTitle("Settings")
    }
}
