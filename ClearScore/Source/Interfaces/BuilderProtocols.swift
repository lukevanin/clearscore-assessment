import UIKit

///
/// Interface for objects that construct view controllers.
///
protocol ModuleBuilderProtocol {
    
    ///
    /// Creates and returns a view controller using the dependencies from the provided environment.
    ///
    /// - Parameter environment: Global dependencies.
    /// - Returns: View controller for the module.
    ///
    func build(environment: Environment) throws -> UIViewController
}
