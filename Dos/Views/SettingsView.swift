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
    
    @State var favoritesExist = Bool()
    @State var darkMode = true
    @State var enableHaptic = true
    @State var appear: Int = 1

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
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    struct SiteDetail{
        var website:String?
        var link:String?
    }
    
    var body: some View {
        let favProducts = UserDefaults.standard.array(forKey: "favProducts") as? [[String:String]] ?? [[:]]
        
        
        List{
            Section(){
                
                NavigationLink(favoritesExist ? "Favorites" : "No Favorites Yet", destination: ({
                    
                    List{
                        ForEach(0..<favProducts.count){ index in
                            Link(favProducts[index]["titleName"]!, destination: URL(string: favProducts[index]["link"]!)!)
                            
                        }
                    }
                    .navigationBarTitle("Favorites")
                    
                })).disabled(!favoritesExist)
                

            }
            
            Section(){
                Picker(selection: $appear, label: Text("Appearance"), content: {
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                    Text("System").tag(3)
                }).pickerStyle(DefaultPickerStyle())
                
                Toggle("Enable vibrations", isOn: $enableHaptic)
            }
            
            
            Section(footer: Text("Made using the Product Hunt API")){

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
            
        }
        .onAppear(perform: {
            if isKeyPresentInUserDefaults(key: "favProducts"){
                //Key exists so get array that is currently available
                favoritesExist = true
                
            }
            else{
                favoritesExist = false
                print("no favorites")
            }
        })
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
    }
}
