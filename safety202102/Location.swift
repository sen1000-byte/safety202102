//
//  Location.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/13.
//

import Foundation

//MARK: -JSONを変換するためのstruct
//weatherの中からmain,description,iconを取得
struct Weather: Decodable {
    let main: String
    let weatherDescription: String
    let icon: String
    enum CodingKeys: String, CodingKey {
        case main
        case weatherDescription = "description"
        case icon
    }
}

//mainの中かtempを取得
struct Main: Decodable {
    let temp: Double
    enum CodingKeys: String, CodingKey {
        case temp
    }
}

//リストの中にmainとweather(配列)が入っている
struct List: Decodable {
    let main: Main
    let weather: [Weather]
}

//全体の中にリスト(配列)が入ってる
struct weatherDecoaded: Decodable{
    let list: [List]
}



//MARK: -Location

//locationの型を作ってあげる
class Location {
    //地域の名前とURL追加するプロパティを持ちます。
        let id: Int
        let name: String

        init(cityCode:Int, cityName:String) {
            id = cityCode
            name = cityName
        }
}


//MARK: -LocationList

//locationを要素に持つ配列をもつclass、各地のデータがまとめられている
class LocationList {
    var list: [Location] = []
    
    init() {
        list.append(Location(cityCode: 2128295, cityName: "札幌市"))
        list.append(Location(cityCode: 2130658, cityName: "青森市"))
        list.append(Location(cityCode: 2111834, cityName: "盛岡市"))
        list.append(Location(cityCode: 2111149, cityName: "仙台市"))
        list.append(Location(cityCode: 2113124, cityName: "秋田市"))
        list.append(Location(cityCode: 2110556, cityName: "山形市"))
        list.append(Location(cityCode: 2112923, cityName: "福島市"))
        list.append(Location(cityCode: 2111901, cityName: "水戸市"))
        list.append(Location(cityCode: 1849053, cityName: "宇都宮市"))
        list.append(Location(cityCode: 1857843, cityName: "前橋"))
        list.append(Location(cityCode: 6940394, cityName: "さいたま市"))
        list.append(Location(cityCode: 2113015, cityName: "千葉市"))
        list.append(Location(cityCode: 1850147, cityName: "東京"))
        list.append(Location(cityCode: 1848354, cityName: "横浜市"))
        list.append(Location(cityCode: 1855431, cityName: "新潟市"))
        list.append(Location(cityCode: 1849876, cityName: "富山市"))
        list.append(Location(cityCode: 1860243, cityName: "金沢市"))
        list.append(Location(cityCode: 1863985, cityName: "福井市"))
        list.append(Location(cityCode: 1848649, cityName: "甲府市"))
        list.append(Location(cityCode: 1856215, cityName: "長野市"))
        list.append(Location(cityCode: 1863641, cityName: "岐阜市"))
        list.append(Location(cityCode: 1851717, cityName: "静岡市"))
        list.append(Location(cityCode: 1856057, cityName: "名古屋市"))
        list.append(Location(cityCode: 1849796, cityName: "津市"))
        list.append(Location(cityCode: 1852553, cityName: "大津市"))
        list.append(Location(cityCode: 1857910, cityName: "京都市"))
        list.append(Location(cityCode: 1853909, cityName: "大阪市"))
        list.append(Location(cityCode: 1859171, cityName: "神戸市"))
        list.append(Location(cityCode: 1855612, cityName: "奈良市"))
        list.append(Location(cityCode: 1926004, cityName: "和歌山市"))
        list.append(Location(cityCode: 1849892, cityName: "鳥取市"))
        list.append(Location(cityCode: 1857550, cityName: "松江市"))
        list.append(Location(cityCode: 1854383, cityName: "岡山市"))
        list.append(Location(cityCode: 1862415, cityName: "広島市"))
        list.append(Location(cityCode: 1848689, cityName: "山口市"))
        list.append(Location(cityCode: 1850158, cityName: "徳島市"))
        list.append(Location(cityCode: 1851100, cityName: "高松市"))
        list.append(Location(cityCode: 1926099, cityName: "松山市"))
        list.append(Location(cityCode: 1859133, cityName: "高知市"))
        list.append(Location(cityCode: 1863967, cityName: "福岡市"))
        list.append(Location(cityCode: 1853303, cityName: "佐賀市"))
        list.append(Location(cityCode: 1856177, cityName: "長崎市"))
        list.append(Location(cityCode: 1858421, cityName: "熊本市"))
        list.append(Location(cityCode: 1854484, cityName: "大分市"))
        list.append(Location(cityCode: 1856710, cityName: "宮崎市"))
        list.append(Location(cityCode: 1860825, cityName: "鹿児島市"))
        list.append(Location(cityCode: 1856035, cityName: "那覇市"))
        
    }
    
}
