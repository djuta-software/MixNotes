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

    func setErrorMessage(_ errorMessage: String) {
        currentMessage = errorMessage
        currentType = .error
    }

    func setSuccessMessage(_ successMessage: String) {
        currentMessage = successMessage
        currentType = .success
    }

    func setInfoMessage(_ infoMessage: String) {
        currentMessage = infoMessage
        currentType = .info
    }
}
