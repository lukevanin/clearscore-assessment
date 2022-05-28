import Foundation

enum Currency: String, Equatable {
    case zar = "ZAR"
}

struct Money: Equatable {
    let currency: Currency
    let amount: Int
    
    func formatted() -> String {
        return amount.formatted(.currency(code: currency.rawValue).precision(.fractionLength(0)))
    }
}
