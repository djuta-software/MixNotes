import XCTest
import Foundation

@testable import MixNotes

class URLExtensionTests: XCTestCase {
    
    let fileName = "file.wav"
    let remotePath = "/filesystem/.file.wav.icloud"
    let localPath = "/filesystem/file.wav"
    
    func testIsRemote() {
        let url = URL(fileURLWithPath: remotePath)
        XCTAssert(url.isRemote())
    }
    func testGetDisplayNameRemote() {
        let url = URL(fileURLWithPath: remotePath)
        XCTAssert(url.getDisplayName() == fileName)
    }
    
    func testGetDisplayNameLocal() {
        let url = URL(fileURLWithPath: localPath)
        XCTAssert(url.getDisplayName() == fileName)
    }
    func testGetLocalURL() {
        let url = URL(fileURLWithPath: remotePath)
        let localUrl = url.getLocalURL()
        XCTAssert(localUrl.path == localPath)
    }
    func testGetRemoteURL() {
        let url = URL(fileURLWithPath: localPath)
        let localUrl = url.getRemoteURL()
        XCTAssert(localUrl.path == remotePath)
    }
}
    
