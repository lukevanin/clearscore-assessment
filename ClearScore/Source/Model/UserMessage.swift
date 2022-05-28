import Foundation

struct UserMessage {
    
    enum Style {
        /// Displays an informational message.
        case info
        
        /// Displays an error message.
        case error
    }
    
    struct Action {
        let title: String
        let block: () -> Void
    }
    
    let message: String
    let action: Action?
}
