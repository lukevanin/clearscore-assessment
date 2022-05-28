import UIKit
import OSLog

///
/// Constructs the ClearScore application dependencies.
///
struct EnvironmentBuilder {
    
    let configurationURL: URL
    
    ///
    /// Creates the dependencies used by the application.
    ///
    /// - Returns: Environment containing all app dependencies
    ///
    func build() throws -> Environment {
        let configuration = try ApplicationConfiguration(
            withPropertyList: configurationURL
        )
        let jsonTransport = JSONHTTPCodableTransport(
            encoder: JSONEncoder(),
            decoder: JSONDecoder(),
            transport: PassthroughHTTPDataTransport(
                session: .shared
            )
        )
        let environment = Environment(
            scoreModel: ScoreModel(
                currency: .zar,
                scoreRepository: ScoreWebRepository(
                    creditScoreURL: try configuration.url(for: .creditScore),
                    transport: jsonTransport
                )
            )
        )
        return environment
    }
}
