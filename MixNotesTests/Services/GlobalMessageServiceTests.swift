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
    
    private func assertInitialState() {
        assertMessageState(expectedMessage: nil, expectedType: .info)
    }
    
    private func assertClearsToInitialState(expectation: XCTestExpectation) {
        MixNotes_XCTAssertWithDelay(expectation: expectation, delay: 4) {
            self.assertInitialState()
        }
    }
    
    func testInit() {
        assertInitialState()
    }
    
    func testSetErrorMessage() {
        let expectation = XCTestExpectation(description: "Should set error message")
        let message = "This is an error message"
        globalMessageService?.setErrorMessage(message)
        assertMessageState(expectedMessage: message, expectedType: .error)
        assertClearsToInitialState(expectation: expectation)
    }
    
    func testSetSuccessMessage() {
        let expectation = XCTestExpectation(description: "Should set success message")
        let message = "This is a success message"
        globalMessageService?.setSuccessMessage(message)
        assertMessageState(expectedMessage: message, expectedType: .success)
        assertClearsToInitialState(expectation: expectation)
    }
    
    func testSetInfoMessage() {
        let expectation = XCTestExpectation(description: "Should set info message")
        let message = "This is an info message"
        globalMessageService?.setInfoMessage(message)
        assertMessageState(expectedMessage: message, expectedType: .info)
        assertClearsToInitialState(expectation: expectation)
    }
}
