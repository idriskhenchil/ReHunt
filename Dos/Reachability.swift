//
//  Reachability.swift
//  Dos
//
//  Created by Idris Khenchil on 10/22/21.
//

import Foundation
import Alamofire

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
