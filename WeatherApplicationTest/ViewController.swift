//
//  ViewController.swift
//  WeatherApplicationTest
//
//  Created by Apit on 12/28/17.
//  Copyright © 2017 Apit. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var iconWeather: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var weatherTitleLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseCityTF: UITextField!
    var pickerView: UIPickerView!
    var weather = [Weather]()
    var city = [String]()
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
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resumeView))
        toolBar.setItems([barButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        chooseCityTF.inputView = pickerView
        chooseCityTF.inputAccessoryView = toolBar
        collectionView.backgroundColor = UIColor.clear
        getWeather(city: "Bandung")
        loadCity()
    }

    func getWeather(city: String) {
        let url = "http://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=ffe9d09a23f978799dd456f513e282fd"
        let parameter: [String : String] = ["q" : "London,uk",
                                         "appid" : "b7e392e48e61eb72270e9ab4c387448a"]
        WebService.GET(url: url, param: [:], headers: [:]) { (json) in
            print(json)
            let listWeather = json["list"].arrayValue
            for list in listWeather {
                let weather = Weather()
                weather.mainTemperature = self.getCelcius(kelvin: list["main"]["temp"].doubleValue)
                weather.minTemperature = self.getCelcius(kelvin: list["main"]["temp_min"].doubleValue)
                weather.maxTemperature = self.getCelcius(kelvin: list["main"]["temp_max"].doubleValue)
                weather.date = list["dt"].doubleValue
                let weatherArray = list["weather"].arrayValue
                var iconWeather = ""
                var weatherTitle = ""
                var weatherDescription = ""
                var weatherId = 0
                for weather in weatherArray {
                    weatherId = weather["id"].intValue
                    iconWeather = weather["icon"].stringValue
                    weatherTitle = weather["main"].stringValue
                    weatherDescription = weather["description"].stringValue
                }
                weather.weatherId = weatherId
                weather.iconWeather = iconWeather
                weather.weatherTitle = weatherTitle
                weather.weatherDescription = weatherDescription
                self.weather.append(weather)
            }
            let city = json["city"]["name"].stringValue
            let country = json["city"]["country"].stringValue
            self.cityLabel.text = "\(city), \(country)".uppercased()
            self.loadLayout(index: 0)
            self.collectionView.reloadData()
        }
    }
    
    func loadCity() {
        let path = Bundle.main.path(forResource: "city.list", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        let json = JSON(jsonData!)
        let arrayOfCity = json.arrayValue
        for cities in arrayOfCity {
            let city = cities["name"].stringValue
            self.city.append(city)
        }
        pickerView.reloadAllComponents()
    }
    
    @objc func resumeView() {
        self.view.endEditing(true)
        getWeather(city: chooseCityTF.text!)
    }
    
    func loadLayout(index: Int) {
        let weather = self.weather[index]
        let url = URL(string: WebService.GET_ICON + weather.iconWeather + ".png")
        iconWeather.sd_setImage(with: url!)
        temperatureLabel.text = degreeFormatter(degree: weather.mainTemperature)
        minTemperatureLabel.text = degreeFormatter(degree: weather.minTemperature)
        maxTemperatureLabel.text = degreeFormatter(degree: weather.maxTemperature)
        let resultDate = Date(timeIntervalSince1970: weather.date)
        dateLabel.text = dateFormatter(date: resultDate, source: "main")
        weatherTitleLabel.text = weather.weatherTitle.uppercased()
        weatherDescriptionLabel.text = dateFormatter(date: resultDate, source: "view").uppercased()
        changeBackground(weatherCode: weather.weatherId)
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
    
    func dateFormatter(date: Date, source: String) -> String {
        if source == "view" {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE dd MMMM"
            let result = formatter.string(from: date)
            return result
        }else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let result = formatter.string(from: date)
            return result
        }
    }
    
    func changeBackground(weatherCode: Int) {
        switch weatherCode {
        case 300...321:
            self.view.backgroundColor = self.hexStringToUIColor(hex: "#2EBFBF")
        case 500...531:
            self.view.backgroundColor = self.hexStringToUIColor(hex: "#01A3DE")
        case 600...622:
            self.view.backgroundColor = self.hexStringToUIColor(hex: "#A6EBF5")
        case 800:
            self.view.backgroundColor = self.hexStringToUIColor(hex: "#FE9802")
        case 801...804:
            self.view.backgroundColor = self.hexStringToUIColor(hex: "#AAAAAA")
        default:
            break
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weather.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WeatherCollectionViewCell
        let weather = self.weather[indexPath.item]
        let url = URL(string: WebService.GET_ICON + weather.iconWeather + ".png")
        cell.iconWeather.sd_setImage(with: url)
        let resultDate = Date(timeIntervalSince1970: weather.date)
        cell.hourLabel.text = self.dateFormatter(date: resultDate, source: "collectionView")
        cell.backgroundColor = UIColor.clear
        cell.transparentView.layer.cornerRadius = 10
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadLayout(index: indexPath.item)
    }
}
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return city.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x:0,y:0, width:pickerView.frame.width-20,height:50))
        label.text = city[row]
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = NSTextAlignment.center
        return label
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chooseCityTF.text = city[row]
    }
}

