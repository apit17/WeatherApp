//
//  ViewController.swift
//  WeatherApplicationTest
//
//  Created by Apit on 12/28/17.
//  Copyright © 2017 Apit. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var iconWeather: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var weatherTitleLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cityLabel.text = ""
        temperatureLabel.text = ""
        minTemperatureLabel.text = ""
        maxTemperatureLabel.text = ""
        weatherTitleLabel.text = ""
        weatherDescriptionLabel.text = ""
        dateLabel.text = ""
        getWeather()
    }

    func getWeather() {
        let parameter: [String : String] = ["q" : "London,uk",
                                         "appid" : "b6907d289e10d714a6e88b30761fae22"]
        WebService.GET(url: WebService.GET_WEATHER, param: parameter, headers: [:]) { (json) in
            let temperature = self.getCelcius(kelvin: json["main"]["temp"].doubleValue)
            let minimumTemperature = self.getCelcius(kelvin: json["main"]["temp_min"].doubleValue)
            let maximumTemperature = self.getCelcius(kelvin: json["main"]["temp_max"].doubleValue)
            let city = json["name"].stringValue
            let country = json["sys"]["country"].stringValue
            let weatherArray = json["weather"].arrayValue
            let date = json["dt"].doubleValue
            let dateResult = Date(timeIntervalSince1970: date)
            var iconWeather = ""
            var weatherTitle = ""
            var weatherDescription = ""
            for weather in weatherArray {
                iconWeather = weather["icon"].stringValue
                weatherTitle = weather["main"].stringValue
                weatherDescription = weather["description"].stringValue
            }
            let url = URL(string: WebService.GET_ICON + iconWeather + ".png")
            self.iconWeather.sd_setImage(with: url!)
            self.temperatureLabel.text = self.degreeFormatter(degree: temperature)
            self.minTemperatureLabel.text = self.degreeFormatter(degree: minimumTemperature)
            self.maxTemperatureLabel.text = self.degreeFormatter(degree: maximumTemperature)
            self.cityLabel.text = "\(city), \(country)"
            self.weatherTitleLabel.text = weatherTitle
            self.weatherDescriptionLabel.text = weatherDescription
            self.dateLabel.text = self.dateFormatter(date: dateResult)
        }
    }
    
    func getCelcius(kelvin: Double) -> Int {
        let celcius = kelvin - 273.15
        return Int(celcius)
    }
    func degreeFormatter(degree: Int) -> String {
        let tempString = String(degree) + "&deg;"
        let result = tempString.replacingOccurrences(of: "&deg;", with: "\u{00B0}")
        return result
    }
    
    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM, h:mm a"
        let result = formatter.string(from: date)
        return result
    }
    
}

