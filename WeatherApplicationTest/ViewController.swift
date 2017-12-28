//
//  ViewController.swift
//  WeatherApplicationTest
//
//  Created by Apit on 12/28/17.
//  Copyright © 2017 Apit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getWeather()
    }

    func getWeather() {
        let parameter: [String : String] = ["q" : "London,uk",
                                         "appid" : "b6907d289e10d714a6e88b30761fae22"]
        WebService.GET(url: WebService.GET_WEATHER, param: parameter, headers: [:]) { (json) in
            print(json)
        }
    }


}

