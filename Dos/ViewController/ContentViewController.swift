//
//  ContentViewController.swift
//  Dos
//
//  Created by Idris Khenchil on 11/27/21.
//

import Foundation
import Alamofire
import ProgressHUD
import SwiftyJSON

class ContentViewController: ObservableObject {
    @Published var posts: [Posts] = []
    @Published var description = String()
    @Published var date = String()
    @Published var imageURLS: [String] = []
    @Published var titleName = String()
    @Published var votes = String()
    @Published var caption = String()
    @Published var link = String()
    @Published var imageURL = String()
    var returnedData: [Posts] = []
    
    func getData()  {
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
                        
                        self.titleName = JSON(response.value!)["posts"][0]["name"].string ?? "Error"
                        
                        self.caption = JSON(response.value!)["posts"][0]["tagline"].string ?? "Error"
                        
                        self.link = JSON(response.value!)["posts"][0]["discussion_url"].string ?? "Error"
                        
                        self.votes = JSON(response.value!)["posts"][0]["votes_count"].rawString() ?? "Error"
                        
                        //Get post ID
                        postID = JSON(response.value!)["posts"][0]["id"].int ?? 0
                        
                        
                        AF.request("https://api.producthunt.com/v1/posts/\(postID)", headers: headers).validate()
                            .responseJSON{ response in
                                switch (response.result) {
                                case .success:
                                    secondLoad()
                                case .failure(let error):
                                    if error._code == NSURLErrorTimedOut {
                                        print("Request timeout!")
                                    }
                                }
                                
                                func secondLoad(){
                                    if response.value == nil {
                                        //Display error
                                        
                                        ProgressHUD.showFailed("Try again")
                                    }
                                    else{
                                        if (((JSON(response.value!)["post"]["media"][0]["image_url"].string)?.contains(".gif")) != nil){
                                            //try another
                                            if(((JSON(response.value!)["post"]["media"][1]["image_url"].string)?.contains(".gif")) != nil){
                                                
                                                //CHeck if url not empty
                                                self.imageURL = JSON(response.value!)["post"]["media"][2]["image_url"].string ?? "Error"

                                                if self.imageURL == "" {
                                                    print("URL EMPTY")
                                                }
                                            }
                                            else{
                                                self.imageURL = JSON(response.value!)["post"]["media"][1]["image_url"].string ?? "Error"
                                                
                                                if self.imageURL == "" {
                                                    print("URL EMPTY")
                                                }
                                                
                                                print(self.imageURL)
                                            }
                                            
                                        }
                                        
                                        for image in JSON(response.value!)["post"]["media"].arrayValue {
                                            if !image["image_url"].stringValue.contains(".gif"){
                                                self.imageURLS.append(image["image_url"].stringValue)
                                            }
                                        }
                                        
                                        self.description = JSON(response.value!)["post"]["description"].string ?? "This product does not have a description."
                                    }
                                    
                                }
                            }
                    }
                    
                }
                
            }
        
        posts = [Posts(title: titleName, caption: caption, imageLink: imageURL, description: description, productURL: link, imageURLS: self.imageURLS)]
    }
}
