//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mansoor Ali on 12/01/2022.
//

import UIKit
import RxSwift
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var feelsLike: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ViewModel()
    var disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    var cityName: String?
    var dataSource = [DailyWeather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 116
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        viewModel.weatherData.subscribe (onNext: {[unowned self] (data) in
            if let value = data {
                let city = self.cityName ?? ""
                self.name.text = "\(city)"
                self.temp.text = "\(value.main.temp)° (\(value.main.temp_min)°/\(value.main.temp_max)°)"
                self.feelsLike.text = "Feels like \(value.main.feels_like)°"
                self.humidity.text = "Humidity: \(value.main.humidity)%"
            }
        }).disposed(by: disposeBag)
        
        viewModel.dataSource.subscribe(onNext: { [unowned self] (list) in
            self.dataSource = list
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        if let location = locations.first {
            getCity(location: location) { [unowned self] (city) in
                self.cityName = city
                if let cityName = city {
                    viewModel.fetchCurrentWeather(city: cityName)
                }
            }
            viewModel.fetchDailyWeather(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
    }
    
    func getCity(location: CLLocation, completion:@escaping(String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
            completion(placemark.locality)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WeatherCell
        let item = dataSource[indexPath.row]
        cell.temp.text = "\(item.temp.min)°/\(item.temp.max)°"
        cell.feelsLike.text = "Feels like \(item.feels_like.day)°"
        cell.humidity.text = "Humidity: \(item.humidity)%"

		let epochTime = TimeInterval(item.dt)
		let date = Date(timeIntervalSince1970: epochTime)
		let dateformatter = DateFormatter()
		dateformatter.dateFormat = "dd EEEE"
		cell.title.text = dateformatter.string(from: date)

		let icon = item.weather.first?.icon ?? ""
		AF.request("https://openweathermap.org/img/wn/\(icon)@2x.png").responseData { response in
			if let data = response.data,
			let image = UIImage(data: data){
				cell.icon.image = image
			}
		}
        return cell
    }
}

