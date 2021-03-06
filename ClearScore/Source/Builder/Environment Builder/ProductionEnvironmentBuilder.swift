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
        let endpoints = ConfigurationEndpointProvider(
            configuration: configuration
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
                // We are using a hard-coded currency for the demo. In a real world application the currency would
                // be specified in the data received from the backend.
                currency: .zar,
                scoreRepository: ScoreWebRepository(
                    endpoints: endpoints,
                    transport: jsonTransport
                )
            )
        )
        return environment
    }
}
