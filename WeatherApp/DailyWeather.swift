//
//  DailyWeather.swift
//  WeatherApp
//
//  Created by Mansoor Ali on 12/01/2022.
//

import Foundation

struct DailyWeatherData: Codable {
    let lat, lon: Double
    let timezone: String
    let timezone_offset: Int
    let daily: [DailyWeather]
}

struct DailyWeather: Codable {
    let dt: Int
    let temp: Temp
    let feels_like: FeelsLike
    let humidity: Int
    let weather: [Weather]
    let clouds: Int
}

struct FeelsLike: Codable {
    let day, night, eve, morn: Double
}

struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}
