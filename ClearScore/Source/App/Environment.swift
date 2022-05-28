import Foundation
import Combine

///
/// Encapsulates global dependencies used by the application.
///
struct Environment {
    
    /// Model of the credit score for the user
    let scoreModel: ScoreModel
    
    /// Publishes user messages displayed in the app.
    let userMessageSubject = PassthroughSubject<UserMessage, Never>()
}
