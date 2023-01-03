import Foundation

struct HotelAddress: Decodable {
    
    let Results:[Result]?
    
}

struct Result: Decodable {

    let address:String

}
