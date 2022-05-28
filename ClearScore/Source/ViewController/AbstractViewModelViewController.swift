import UIKit
import Combine

protocol ViewModelControllerProtocol: UIViewController {
    associatedtype ViewModel
}

///
/// Updates a view using a view model.
///
/// To use this view controller:
///
/// 1. Define a custom view controller that inherits from `AbstractViewModelViewController`.
/// 2. Define a View Model for the custom sub-class.
/// 3. Override the `updateViewModel()` method to update the view when the view model changes.
///
/// - Warning:Only uses sub-classes of this class. Do not instantiate this view controller directly.
///
class AbstractViewModelViewController<ViewModel>: UIViewController, ViewModelControllerProtocol {

    var viewModelPublisher: AnyPublisher<ViewModel, Never>?

    var viewModelCancellable: AnyCancellable!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connectViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnectViewModel()
    }
     
    private func connectViewModel() {
        viewModelCancellable = viewModelPublisher?
            .receive(on: RunLoop.main)
            .sink { [weak self] viewModel in
                self?.updateViewModel(viewModel)
            }
    }
    
    private func disconnectViewModel() {
        viewModelCancellable.cancel()
        viewModelCancellable = nil
    }
    
    func updateViewModel(_ viewModel: ViewModel) {
        
    }
}
