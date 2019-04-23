//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON



class WeatherViewController: UIViewController ,CLLocationManagerDelegate,changeCityDelegate{

    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherData = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String,parameters:[String:String]){
        Alamofire.request(url , method: .get , parameters:parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Got Weather Data")
                print(response.result.value!)
                let weatherJSON:JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                print("error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        if let tempResult = json["main"]["temp"].double{
        weatherData.temprature = Int(tempResult - 273.15)
        weatherData.condition = json["weather"][0]["id"].intValue
        weatherData.city = json["name"].stringValue
        weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
        updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherData.city
        temperatureLabel.text = String(weatherData.temprature)
        print(weatherData.weatherIconName)
        weatherIcon.image = UIImage(named:weatherData.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("location Coordinates is \n lat \(location.coordinate.latitude)\n lon \(location.coordinate.longitude)")
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let param:[String:String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]
            
            getWeatherData(url:WEATHER_URL,parameters:param)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let param:[String:String] = ["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: param)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    

   
    
}


