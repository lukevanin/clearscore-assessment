import Foundation

///
/// A value which is a percentage of a whole. E.g a literal value of `27` indicates a percentage of `27%`.
///
struct Percentage: Equatable {
    let value: Int
    
    func unity() -> Double {
        Double(value) / 100.0
    }
    
    func formatted() -> String {
        value.formatted(.percent)
    }
}
