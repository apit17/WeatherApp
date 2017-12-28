//
//  WebService.swift
//  WeatherApplicationTest
//
//  Created by Apit on 12/28/17.
//  Copyright © 2017 Apit. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class WebService: NSObject {
    static var manager: SessionManager!
    static let GET_WEATHER = "http://samples.openweathermap.org/data/2.5/weather"
    
    
    /// Function for get json from service using get method
    ///
    /// - Parameters:
    ///   - url: service url
    ///   - param: parameter url
    ///   - headers: for header html
    ///   - success: success function
    class func GET(url:String, param:[String: String], headers:[String:String], success: @escaping (JSON) -> Void) {
        if manager == nil{
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 30
            manager = SessionManager(configuration: configuration)
        }
        
        let req = manager.request(url, method: HTTPMethod.get, parameters: param, encoding: URLEncoding.default, headers: headers)
        
        req.responseJSON { (response) -> Void in
            switch response.result {
            case .success(let json) :
                let jObject = JSON(json)
                success(jObject)
            case .failure(_): break
                
            }
        }
    }
}
