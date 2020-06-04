import XCTest
import Combine
@testable import MixNotes

class GlobalMessageServiceTests: XCTestCase {
    
    var globalMessageService: GlobalMessageService?
    
    override func setUp() {
        globalMessageService = GlobalMessageService()
    }
    
    private func assertMessageState(expectedMessage: String?, expectedType: GlobalMessageType) {
        XCTAssert(globalMessageService?.currentMessage == expectedMessage)
        XCTAssert(globalMessageService?.currentType == expectedType)
    }
    
    func testInit() {
        assertMessageState(expectedMessage: nil, expectedType: .info)
    }
    
    func testSetErrorMessage() {
        let message = "This is an error message"
        globalMessageService?.setErrorMessage(message)
        assertMessageState(expectedMessage: message, expectedType: .error)
    }
    
    func testSetSuccessMessage() {
        let message = "This is a success message"
        globalMessageService?.setSuccessMessage(message)
        assertMessageState(expectedMessage: message, expectedType: .success)
    }
    
    func setInfoMessage() {
        let message = "This is an info message"
        globalMessageService?.setSuccessMessage(message)
        assertMessageState(expectedMessage: message, expectedType: .info)
    }
}
