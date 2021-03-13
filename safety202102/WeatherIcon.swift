//
//  WeatherIcon.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/13.
//

import Foundation
import UIKit

class WeatherIcon {
    
    func selectIcon(icon: String, main: String) -> UIImage?{
        switch icon {
        case "01d", "01n" :
            return UIImage(systemName: "sun.max.fill")
        case "02d", "02n" :
            return UIImage(systemName: "cloud.sun.fill")
        case "03d", "03n" :
            return UIImage(systemName: "cloud.fill")
        case "04d", "04n" :
            return UIImage(systemName: "cloud.fill")
        case "09d", "09n" :
            return UIImage(systemName: "cloud.rain.fill")
        case "10d", "10n" :
            return UIImage(systemName: "cloud.sun.rain.fill")
        case "11d", "11n" :
            return UIImage(systemName: "cloud.bolt.rain.fill")
        case "13d", "13n" :
            return UIImage(systemName: "snow")
        case "50d", "50n" :
            switch main {
            case "Mist":
                return UIImage(systemName: "cloud.fog.fill")
            case "Smoke":
                return UIImage(systemName: "smoke.fill")
            case "Haze":
                return UIImage(systemName: "sun.haze.fill")
            case "Dust":
                return UIImage(systemName: "sun.dust.fill")
            case "Fog":
                return UIImage(systemName: "cloud.fog.fill")
            case "Sand":
                return UIImage(systemName: "")
            case "Ash":
                return UIImage(systemName: "")
            case "Squall":
                return UIImage(systemName: "cloud.heavyrain.fill")
            case "Tornado":
                return UIImage(systemName: "tornado")
            default:
                return UIImage(systemName: "")
            }

        default:
            return UIImage(systemName: "")
        }
    }
    
    
    func selectIconColor(icon: String) -> UIColor {
        switch icon {
        case "01d", "01n" :
            return UIColor.orange
        case "02d", "02n", "03d", "03n":
            return UIColor.lightGray
        case "04d", "04n" :
            return UIColor.darkGray
        case "09d", "09n" :
            return UIColor.blue
        case "10d", "10n" :
            return UIColor.lightGray
        case "11d", "11n" :
            return UIColor.darkGray
        case "13d", "13n" :
            return UIColor.blue
        case "50d", "50n" :
            return UIColor.lightGray
        default:
            return UIColor.lightGray
        }
    }
}
