import Foundation

struct HotelAndCityInfo: Decodable {
    
    let results:result
    
}

struct result: Decodable {
    
    let hotels:[hotel]?
    let locations:[location]?
    
}

struct hotel: Decodable {
    
    let location: locationFl
    let id:String
    let locationName:String
    let locationId:Int

}

struct location: Decodable {
    
    let hotelsCount:String
    let iata:[String]?
    let location:locationStr
    
}

struct locationFl: Decodable {

    let lon:Float
    let lat:Float

}

struct locationStr: Decodable {

    let lon:String
    let lat:String

}
