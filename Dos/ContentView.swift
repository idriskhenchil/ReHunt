//
//  ContentView.swift
//  Dos
//
//  Created by Idris Khenchil on 10/20/21.
//

import SwiftUI
import StoreKit
import Alamofire
import SwiftyJSON
import Kingfisher
import Foundation
import ProgressHUD

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL

    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Catamaran-Bold", size: 20)!]
    }
    
    @State var titleName = " "
    @State var caption = " "
    @State var date = " "
    @State var description = " "
    @State var link = "https://producthunt.com"
    @State var imageURL = "https://producthunt.com"
    @State var darkMode = Bool()
    @State var votes = "0"
    @State var imageURLS: [String] = []
    @State private var showingActionSheet = false

    var body: some View {
        NavigationView{
            VStack{
                VStack{
                    Text(titleName).lineLimit(nil).frame(width: UIScreen.main.bounds.width / 1.15, alignment: .leading).font(Font.custom("Catamaran-ExtraBold", size: 32))
                        .foregroundColor(colorScheme == .dark ? Color.white : .black)
                    
                    Text(caption)
                        .frame(width: UIScreen.main.bounds.width / 1.15, alignment: .leading)
                        .foregroundColor(.gray)
                    
                }.padding(.top, 30.0).font(Font.custom("Catamaran-Bold", size: 16))
                
                ScrollView(.horizontal, showsIndicators: false){
                    
                    HStack{
                        if Connectivity.isConnectedToInternet{
                            
                            ForEach(imageURLS, id: \.self){ links in
                                KFImage(URL(string: links)!)
                                    .placeholder{
                                        ProgressView()
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width)
                            }
                            
                        }
                        
                    }
                }
                
                VStack{
                    ScrollView{
                        
                        
                        Text("\(votes) UPVOTES")
                            .frame(width: UIScreen.main.bounds.width / 1.15, alignment: .trailing)
                            .foregroundColor(.gray)
                            .font(Font.custom("Catamaran-Bold", size: 14))
                        
                        Text(description)
                            .frame(width: UIScreen.main.bounds.width / 1.15)
                            .font(Font.custom("Catamaran-Medium", size: 16))
                            .foregroundColor(colorScheme == .dark ? Color.white : .black)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                }
                
                //Link("NEXT PRODUCT ", destination: URL(string: link)!)

                Button(action: {
                    //Animate refresh?
                    if Connectivity.isConnectedToInternet{
                        imageURLS.removeAll()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            
                            // Change `2.0` to the desired number of seconds.

                            //self.disabled(true)
                            getData()
                        }
                        
                        
                    }
                    else{
                        print("No connection")
                        ProgressHUD.showFailed("No Connection")
                        
                    }
                }, label: {Text("NEXT PRODUCT")})
                    .frame(minWidth: UIScreen.screenWidth / 1.1, maxWidth: UIScreen.screenWidth / 1.1, minHeight:65, maxHeight: 65, alignment: .center)
                    .font(Font.custom("Catamaran-ExtraBold", size: 18))
                    .background(Color(#colorLiteral(red: 0.85, green: 0.33, blue: 0.18, alpha: 1.00)))
                    .foregroundColor(Color.white)
                    .cornerRadius(15).padding(.bottom, 15)
                    .font(.system(size: 18, weight: .bold))
                    .contentShape(Rectangle())

            }.navigationTitle(date)
                .navigationBarTitleDisplayMode(.inline)
                .font(Font.custom("Catamaran-Regular", size: 17))
            
                .navigationBarItems(
                    leading:
                        NavigationLink(destination: SettingsView(), label: {
                            Image(systemName: "gearshape")
                        }),
                    trailing:
                        Button(action: {
                            //Animate refresh?
                            if Connectivity.isConnectedToInternet{

                                self.showingActionSheet = true
                                
                                
                            }
                            else{
                                print("No connection")
                                ProgressHUD.showFailed("No Connection")
                                
                            }
                            
                        }) {
                            Image(systemName: "ellipsis")
                        }
                )
                .foregroundColor(colorScheme == .dark ? Color.white : .black)
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text(titleName), buttons: [
                        .default(Text("View on Product Hunt")) {
                            openURL(URL(string: link)!)

                        },
                        .default(Text("Save to Favorites")){
                            //Add link and title to favoirtes
    
                            //Add to list
                            //var dict = [titleName: link]
                            
                            //Get old dictionary
                            var savedHunts =                             UserDefaults.standard.dictionary(forKey: "SavedHunts")
                            
                            //Update old dictionary
                            savedHunts![titleName] = link
                            
                            
                        },
                        .cancel()
                    ])
                    
                    
                    
                }
            
                
            
        }.navigationViewStyle(.stack)
            .accentColor(Color(#colorLiteral(red: 0.85, green: 0.33, blue: 0.18, alpha: 1.00)))
            .onAppear(perform: {
                if Connectivity.isConnectedToInternet{
                    imageURLS.removeAll()

                    getData()
                }
                else{
                    print("No connection")
                    
                    ProgressHUD.showFailed("No Connection")
                    
                }
            })
    }
    
    func getData(){
        description = " "
        
        imageURLS.removeAll()
        
        //Get random date
        let year = Int.random(in: 2015...2020)
        let day = Int.random(in: 1...28)
        let month = Int.random(in: 1...12)
        
        var day1 = String()
        var month1 = String()
        
        if day < 10 {
            //Format
            day1 = String(format: "%02d", day)
        }
        else{
            day1 = String(day)
        }
        
        if month < 10 {
            //Format
            month1 = String(format: "%02d", month)
        }
        else{
            month1 = String(month)
        }
        
        //Make request
        let headers: HTTPHeaders = [
            "Authorization": "Bearer GTlJZtmYnOTrlYOTtjrVCCq7FyN4HJ9aiuV7BCZGXAg"]
        
        
        let url = "https://api.producthunt.com/v1/posts"
        let date1 = "\(year)-\(month1)-\(day1)"
        var postID = Int()
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        
        if let date2 = dateFormatterGet.date(from: date1) {
            //print(dateFormatterPrint.string(from: date2))
            
            date = dateFormatterPrint.string(from: date2)
        } else {
            print("There was an error decoding the string")
        }
        
        let param = ["day": date1, "Connection": "close"]
        
        
        ProgressHUD.show()
        
        
        AF.request(url, parameters: param, headers: headers).validate()
            .responseJSON{ response in
                
                switch (response.result) {
                case .success:
                    firstLoad()
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        print("Request timeout!")
                    }
                }
                
                
                func firstLoad(){
                    ProgressHUD.dismiss()
                    
                    if response.value == nil {
                        //Display error
                        
                        ProgressHUD.showFailed("No Connection")
                    }
                    else{
                        
                        titleName = JSON(response.value!)["posts"][0]["name"].string ?? "Error"
                        
                        caption = JSON(response.value!)["posts"][0]["tagline"].string ?? "Error"
                        
                        link = JSON(response.value!)["posts"][0]["discussion_url"].string ?? "Error"
                        
                        votes = JSON(response.value!)["posts"][0]["votes_count"].rawString() ?? "Error"
                        
                        //Get post ID
                        postID = JSON(response.value!)["posts"][0]["id"].int ?? 0
                        
                        
                        AF.request("https://api.producthunt.com/v1/posts/\(postID)", headers: headers).validate()
                            .responseJSON{ response in
                                //print(JSON(response.value))
                                //print("https://api.producthunt.com/v1/posts/\(postID)")
                                
                                switch (response.result) {
                                case .success:
                                    secondLoad()
                                case .failure(let error):
                                    if error._code == NSURLErrorTimedOut {
                                        print("Request timeout!")
                                    }
                                }
                                
                                
                                func secondLoad(){
                                //print(postID)
                                if response.value == nil {
                                    //Display error
                                    
                                    ProgressHUD.showFailed("Try again")
                                }
                                else{
                                    
                                    
                                    
                                    if (((JSON(response.value!)["post"]["media"][0]["image_url"].string)?.contains(".gif")) != nil){
                                        //try another
                                        if(((JSON(response.value!)["post"]["media"][1]["image_url"].string)?.contains(".gif")) != nil){
                                            imageURL = JSON(response.value!)["post"]["media"][2]["image_url"].string ?? "Error"
                                            
                                        }
                                        else{
                                            imageURL = JSON(response.value!)["post"]["media"][1]["image_url"].string ?? "Error"
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    for image in JSON(response.value!)["post"]["media"].arrayValue {
                                        
                                        
                                        if image["image_url"].stringValue.contains(".gif"){
                                            //Omit
                                        }
                                        else{
                                            imageURLS.append(image["image_url"].stringValue)
                                        }
                                    }
                                    
                                    description = JSON(response.value!)["post"]["description"].string ?? "This product does not have a description."
                                }
                                    
                                }
                            }
                    }
                    
                }
            }
        
    }
    
}

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

                        let savedHunts =                             UserDefaults.standard.dictionary(forKey: "SavedHunts")

                        Button(action: {
                            for (title, link) in savedHunts! {
                                    print(title)
                                    print(link)

                            }
                        }, label: {
                            Text("Loop Test")
                        })
                        
                        Button(action: {
                            print(savedHunts)
                        }, label: {
                            Text("Defaults")
                        })
                        
                        
                        
                        Link(destination: URL(string: "https://www.producthunt.com")!, label: {
                            HStack{
                                Text("Product Hunt Website")
                                
                            }
                            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
