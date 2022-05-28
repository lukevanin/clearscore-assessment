import Foundation

///
/// A recognized value of currency of monetary value.
///
enum Currency: String, Equatable {
    case zar = "ZAR"
}

///
/// A monetary value in a specific currency.
///
struct Money: Equatable {
    
    /// Currency of the monetary amount.
    let currency: Currency
    
    /// Amount of value in the given currency. The amount is given in the lowest denomination in the currency.
    let amount: Int
    
    init(currency: Currency, amount: Int, denomination: UInt) {
        self.currency = currency
        self.amount = amount * Int(denomination)
    }
    
    func formatted(denomination: UInt) -> String {
        let value = Double(amount) / Double(denomination)
        let roundedValue = value.rounded(.toNearestOrEven)
        return roundedValue.formatted(.currency(code: currency.rawValue).precision(.fractionLength(0)))
    }
}
