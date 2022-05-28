import UIKit
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "scene-delegate")

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
        let viewController: UIViewController
        do {
            viewController = try makeViewController()
        }
        catch {
            logger.critical("Cannot instantiate initial application view controller. \(error.localizedDescription)")
            return
        }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        logger.debug("App initialized")
        return
    }

    private func makeViewController() throws -> UIViewController {
        let environment: Environment
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("test") {
            // Unit or UI test. Set up a blank view controller.
            logger.warning("Running test")
            environment = TestEnvironmentBuilder().build()
        }
        else {
            // Standalone app.
            #if DEBUG
            let configurationURL = Bundle.main.url(forResource: "Configuration-debug", withExtension: "plist")!
            logger.warning("Running debug standalone")
            #else
            let configurationURL = Bundle.main.url(forResource: "Configuration-release", withExtension: "plist")!
            logger.warning("Running release standalone")
            #endif
            let builder = EnvironmentBuilder(configurationURL: configurationURL)
            environment = try builder.build()
        }
        let builder = ApplicationModuleBuilder(
            content: LoadingModuleBuilder(
                module: ReportModuleBuilder(
                    modules: [
                        ScoreModuleBuilder(),
                        ShortTermCreditInfoModuleBuilder(),
                        LongTermCreditInfoModuleBuilder(),
                    ]
                )
            )
        )
        let viewController = try builder.build(environment: environment)
        return viewController
    }
}
