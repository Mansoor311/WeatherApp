//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Mansoor Ali on 12/01/2022.
//

import Foundation
import Alamofire
import RxCocoa

class ViewModel {
    var weatherData: BehaviorRelay<WeatherData?> = BehaviorRelay(value: nil)
    var dataSource: BehaviorRelay<[DailyWeather]> = BehaviorRelay(value: [])
    
    func fetchCurrentWeather(city: String) {
        fetchWeather(city: city) { [unowned self] (data, error) in
            self.weatherData.accept(data)
        }
    }
    
    private func fetchWeather(city: String, completion:@escaping(WeatherData?, Error?) -> Void) {
        AF.request("https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=081e3649d01551ea3a65283b20a74fe8").responseDecodable(of: WeatherData.self) { response in
            if let value = response.value {
                completion(value,nil)
            }else {
                completion(nil,response.error)
            }
        }
    }
    
    var request: DataRequest?
    func fetchDailyWeather(lat: Double, long: Double) {
        request?.cancel()
        request = AF.request("https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&appid=081e3649d01551ea3a65283b20a74fe8").responseDecodable(of: DailyWeatherData.self) { [unowned self ] response in
            if let value = response.value {
                self.dataSource.accept(value.daily)
            }
        }
    }
}
