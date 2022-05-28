import Foundation

struct Percentage: Equatable {
    let value: Int
    
    func unity() -> Double {
        Double(value) / 100.0
    }
    
    func formatted() -> String {
        value.formatted(.percent)
    }
}
