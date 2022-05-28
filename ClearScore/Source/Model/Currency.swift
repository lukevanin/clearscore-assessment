import Foundation

enum Currency: String {
    case zar = "ZAR"
}

struct Money {
    let currency: Currency
    let amount: Int
    
    func formatted() -> String {
        return amount.formatted(.currency(code: currency.rawValue).precision(.fractionLength(0)))
    }
}
