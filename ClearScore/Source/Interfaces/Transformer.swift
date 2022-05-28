import Foundation


///
/// Interface for converting one type of object to another.
///
protocol Transformer {
    associatedtype Input
    associatedtype Output
    
    ///
    /// Transforms the input value to the output value.
    ///
    func transform(input: Input) -> Output
    
    ///
    /// Erases the specific instance type of the transformer and returns an `AnyTransformer` type so that the instance can be used generically.
    ///
    func eraseToAnyTransformer() -> AnyTransformer<Input, Output>
}

extension Transformer {
    func eraseToAnyTransformer() -> AnyTransformer<Input, Output> {
        AnyTransformer(self)
    }
}


///
/// Type-erased transformer.
///
struct AnyTransformer<Input, Output>: Transformer {
    
    private let _transform: (Input) -> Output
    
    init<T>(_ transformer: T) where T: Transformer, T.Input == Input, T.Output == Output {
        self._transform = transformer.transform
    }
    
    func transform(input: Input) -> Output {
        _transform(input)
    }
    
    func eraseToAnyTransformer() -> AnyTransformer<Input, Output> {
        self
    }
}
