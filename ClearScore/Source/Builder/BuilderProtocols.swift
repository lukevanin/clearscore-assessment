import UIKit

protocol ModuleBuilderProtocol {
    func build(environment: Environment) throws -> UIViewController
}
