import Foundation

enum GlobalMessageType {
    case info, success, error
}

protocol GlobalMessageServiceProtocol {
    func setErrorMessage(_ errorMessage: String)
    func setSuccessMessage(_ successMessage: String)
    func setInfoMessage(_ infoMessage: String)
}

class GlobalMessageService: ObservableObject, GlobalMessageServiceProtocol {

    @Published private(set) var currentMessage: String? = nil
    @Published private(set) var currentType: GlobalMessageType = .info
    private let clearTime = 3.0

    func setErrorMessage(_ errorMessage: String) {
        currentMessage = errorMessage
        currentType = .error
        clear()
    }

    func setSuccessMessage(_ successMessage: String) {
        currentMessage = successMessage
        currentType = .success
        clear()
    }

    func setInfoMessage(_ infoMessage: String) {
        currentMessage = infoMessage
        currentType = .info
        clear()
    }
    
    private func clear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + clearTime) {
            self.currentMessage = nil
            self.currentType = .info
        }
    }
}
