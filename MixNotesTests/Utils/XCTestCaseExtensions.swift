import Foundation
import Combine
import XCTest

extension XCTestCase {
    func MixNotes_XCTAssertPublisherFinishes<T, E>(
        expectation: XCTestExpectation,
        publisher: AnyPublisher<T, E>,
        valueAssertations: @escaping (T) -> Void
    ) {
        _ = publisher
            .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }, receiveValue: valueAssertations)

       wait(for: [expectation], timeout: 5)
    }
    
    func MixNotes_XCTAssertPublisherErrors<T, E>(
        expectation: XCTestExpectation,
        publisher: AnyPublisher<T, E>
    ) {
        _ = publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail()
                case .failure:
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
    }
    
    func MixNotes_XCTAssertWithDelay(
        expectation: XCTestExpectation,
        delay: Int = 1,
        assertations: @escaping () -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            assertations()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
