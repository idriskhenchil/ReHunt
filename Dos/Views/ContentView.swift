//
//  ContentView.swift
//  Dos
//
//  Created by Idris Khenchil on 10/20/21.
//

import SwiftUI
import SwiftyJSON
import Kingfisher
import ProgressHUD

struct ContentView: View {
    @StateObject var CVC = ContentViewController()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Catamaran-Bold", size: 20)!]
    }
    
    @State private var showingActionSheet = false
    @State var isLoading = Bool()
    
    var body: some View {
        NavigationView{
            VStack{
                VStack{
                    Text(CVC.titleName)
                        .lineLimit(nil).frame(width: UIScreen.main.bounds.width / 1.15, alignment: .leading).font(Font.custom("Catamaran-ExtraBold", size: 32))
                        .foregroundColor(colorScheme == .dark ? Color.white : .black)
                    
                    Text(CVC.caption)
                        .frame(width: UIScreen.main.bounds.width / 1.15, alignment: .leading)
                        .foregroundColor(.gray)
                }.padding(.top, 30.0).font(Font.custom("Catamaran-Bold", size: 16))
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        if Connectivity.isConnectedToInternet{
                            ForEach(CVC.imageURLS, id: \.self){ links in
                                KFImage(URL(string: CVC.imageURL)!)
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
                        Text("\(CVC.votes) UPVOTES")
                            .frame(width: UIScreen.main.bounds.width / 1.15, alignment: .trailing)
                            .foregroundColor(.gray)
                            .font(Font.custom("Catamaran-Bold", size: 14))
                        
                        Text(CVC.description)
                            .frame(width: UIScreen.main.bounds.width / 1.15)
                            .font(Font.custom("Catamaran-Medium", size: 16))
                            .foregroundColor(colorScheme == .dark ? Color.white : .black)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                Button(action: {
                    //Animate refresh?
                    if Connectivity.isConnectedToInternet{
                        CVC.imageURLS.removeAll()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            CVC.getData()
                        }
                    }
                    else{
                        print("No connection")
                        ProgressHUD.showFailed("No Connection")
                    }
                }, label: {
                    Text("NEXT PRODUCT")
                        .frame(minWidth: UIScreen.screenWidth / 1.1, maxWidth: UIScreen.screenWidth / 1.1, minHeight:65, maxHeight: 65, alignment: .center)
                })
                    .font(Font.custom("Catamaran-ExtraBold", size: 18))
                    .background(Color(#colorLiteral(red: 0.85, green: 0.33, blue: 0.18, alpha: 1.00)))
                    .foregroundColor(Color.white)
                    .cornerRadius(15).padding(.bottom, 15)
                    .font(.system(size: 18, weight: .bold))
                    .contentShape(Rectangle())
            }.navigationTitle(CVC.date)
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
                    ActionSheet(title: Text(CVC.titleName), buttons: [
                        .default(Text("Share"), action: {
                            guard let urlShare = URL(string: CVC.link) else { return }
                            let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                        }),
                        
                            .default(Text("View on Product Hunt")) {
                                openURL(URL(string: CVC.link)!)
                            },
                        .default(Text("Save to Favorites")){
                            //Check to see if defaults already exists
                            if isKeyPresentInUserDefaults(key: "favProducts"){
                                var favouriteProducts = UserDefaults.standard.array(forKey: "favProducts") as? [[String:String]] ?? [[:]]
                                
                                let firstArray = ["titleName": CVC.titleName,"link": CVC.link]
                                favouriteProducts.append(firstArray)
                                
                                //Delete old array
                                UserDefaults.standard.removeObject(forKey: "favProducts")
                                UserDefaults.standard.set(favouriteProducts, forKey: "favProducts")
                                
                                UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                                
                                ProgressHUD.show("Saved", icon: .star, interaction: false)
                            }
                            else{
                                var favouriteProducts = [[String:Any]]()
                                var listOfSite = [SiteDetail]()
                                
                                let firstArray = ["titleName": CVC.titleName,"link": CVC.link]
                                
                                favouriteProducts.append(firstArray)
                                UserDefaults.standard.set(favouriteProducts, forKey: "favProducts")
                                
                                let value = UserDefaults.standard.array(forKey: "favProducts") as? [[String:String]] ?? [[:]]
                                
                                for values in value{
                                    let siteName = values["titleName"] ?? ""
                                    let link = values["link"] ?? ""
                                    let siteDetail = SiteDetail(website: siteName, link: link)
                                    listOfSite.append(siteDetail)
                                }
                                
                                ProgressHUD.show("Saved", icon: .star, interaction: false)
                            }
                        },
                        .cancel()
                    ])
                }
        }.navigationViewStyle(.stack)
            .accentColor(Color(#colorLiteral(red: 0.85, green: 0.33, blue: 0.18, alpha: 1.00)))
            .onAppear(perform: {
                if Connectivity.isConnectedToInternet{
                    CVC.imageURLS.removeAll()
                    CVC.getData()
                }
                else{
                    print("No connection")
                    
                    ProgressHUD.showFailed("No Connection")
                }
            })
    }
    
    struct SiteDetail{
        var website: String?
        var link: String?
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
