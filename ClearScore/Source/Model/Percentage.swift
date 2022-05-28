import Foundation

struct Percentage {
    let value: Int
    
    func unity() -> Double {
        Double(value) / 100.0
    }
    
    func formatted() -> String {
        value.formatted(.percent)
    }
}
