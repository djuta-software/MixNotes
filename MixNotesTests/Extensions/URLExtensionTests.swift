import XCTest
import Foundation

@testable import MixNotes

class URLExtensionTests: XCTestCase {
    func testIsRemote() {
        let url = URL(fileURLWithPath: "/filesystem/.file.wav.icloud")
        XCTAssert(url.isRemote())
    }
    func testGetDisplayNameRemote() {
        let url = URL(fileURLWithPath: "/filesystem/.file.wav.icloud")
        XCTAssert(url.getDisplayName() == "file.wav")
    }
    
    func testGetDisplayNameLocal() {
        let url = URL(fileURLWithPath: "/filesystem/file.wav")
        XCTAssert(url.getDisplayName() == "file.wav")
    }
    func testGetLocalURL() {
        let url = URL(fileURLWithPath: "/filesystem/.file.wav.icloud")
        let localUrl = url.getLocalURL()
        XCTAssert(localUrl.path == "/filesystem/file.wav")
    }
    func testGetRemoteURL() {
        let url = URL(fileURLWithPath: "/filesystem/file.wav")
        let localUrl = url.getRemoteURL()
        XCTAssert(localUrl.path == "/filesystem/.file.wav.icloud")
    }
}
    
