//
//  APIController.swift
//  RxCocoa-RxSwift-WunderCast
//
//  Created by ahmed mostafa on 1/7/21.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

class APIController {
    
    struct Weather: Decodable {
      let cityName: String
      let temperature: Int
      let humidity: Int
      let icon: String

      static let empty = Weather(
        cityName: "Unknown",
        temperature: -10,
        humidity: 0,
        icon: iconNameToChar(icon: "e")
      )

      init(cityName: String,
           temperature: Int,
           humidity: Int,
           icon: String) {
        self.cityName = cityName
        self.temperature = temperature
        self.humidity = humidity
        self.icon = icon
      }

      init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cityName = try values.decode(String.self, forKey: .cityName)
        let info = try values.decode([AdditionalInfo].self, forKey: .weather)
        icon = iconNameToChar(icon: info.first?.icon ?? "")
        
        let mainInfo = try values.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        temperature = Int(try mainInfo.decode(Double.self, forKey: .temp))
        humidity = try mainInfo.decode(Int.self, forKey: .humidity)
      }

      enum CodingKeys: String, CodingKey {
        case cityName = "name"
        case main
        case weather
      }

      enum MainKeys: String, CodingKey {
        case temp
        case humidity
      }

      private struct AdditionalInfo: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
      }
    }

  static var shared = APIController()
  let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!

  private let apiKey = "07dbf28ab9d4ba21f08b4196ad031d63"

  init() {
    Logging.URLRequests = { request in
      return true
    }
  }
    
    func currentWeather(city: String) -> Observable<Weather> {
        
        return buildRequest(pathComponent: "weather", params: [("q", city)])
            .map({data in
                let decoder = JSONDecoder()
                return try decoder.decode(Weather.self, from: data)
            })
    }
 
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
      let url = baseURL.appendingPathComponent(pathComponent)
      var request = URLRequest(url: url)
      let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
      let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
      let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

      if method == "GET" {
        var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
        queryItems.append(keyQueryItem)
        queryItems.append(unitsQueryItem)
        urlComponents.queryItems = queryItems
      } else {
        urlComponents.queryItems = [keyQueryItem, unitsQueryItem]

        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.httpBody = jsonData
      }

      request.url = urlComponents.url!
      request.httpMethod = method

      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      let session = URLSession.shared

      return session.rx.data(request: request)
    }

}


public func iconNameToChar(icon: String) -> String {
  switch icon {
  case "01d":
    return "\u{f11b}"
  case "01n":
    return "\u{f110}"
  case "02d":
    return "\u{f112}"
  case "02n":
    return "\u{f104}"
  case "03d", "03n":
    return "\u{f111}"
  case "04d", "04n":
    return "\u{f111}"
  case "09d", "09n":
    return "\u{f116}"
  case "10d", "10n":
    return "\u{f113}"
  case "11d", "11n":
    return "\u{f10d}"
  case "13d", "13n":
    return "\u{f119}"
  case "50d", "50n":
    return "\u{f10e}"
  default:
    return "E"
  }
}

