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
    @State var favoritesExist = Bool()
    
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
            Section(footer: Text("Made using the Product Hunt API ❤️")){
                //Toggle("Dark Mode", isOn: $darkMode)
                
                
                
                NavigationLink("Favorites", destination: ({

                    List{
                        ForEach(0..<favProducts.count){ index in
                            Link(favProducts[index]["titleName"]!, destination: URL(string: favProducts[index]["link"]!)!)
                            
                        }
                    }
                    .onAppear(perform: {
                        if isKeyPresentInUserDefaults(key: "favProducts"){
                            //Key exists so get array that is currently available
                            favoritesExist = true
                            
                            //Add to dictionary
                            //favoriteProducts?.updateValue(link, forKey: titleName)
                            
                            //Update key
                            //UserDefaults.standard.set(favoriteProducts, forKey: "favoriteProducts")
                            
                            
                            //print(UserDefaults.standard.array(forKey: "favProducts")![0])
                            
                            
                            
                            
//                            print(UserDefaults.standard.array(forKey: "favProducts")![0] as! [String: String])
//
//                            let firstElement = (UserDefaults.standard.array(forKey: "favProducts")?[0] as? [String: String])
//                            let title = firstElement?["titleName"]
//                            let link = firstElement?["link"]
//
//                            print(firstElement)

                        }
                        else{
                            favoritesExist = false
                            print("no favorites")
                            
                            

                        }
                        
                        
                    })
                    
                    
                    .navigationBarTitle("Favorites")
                    
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
