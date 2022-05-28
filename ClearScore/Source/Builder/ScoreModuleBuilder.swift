import UIKit

struct ScoreModuleBuilder: ModuleBuilderProtocol {

    func build(environment: Environment) throws -> UIViewController {
        return ScoreViewController(scoreModel: environment.scoreModel)
    }
}
