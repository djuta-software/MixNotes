import XCTest
import Combine
@testable import MixNotes

class ProjectServiceTests: XCTestCase {

    var fileService: MockFileService?
    var projectService: ProjectService?

    override func setUp() {
        fileService = MockFileService()
        projectService = ProjectService(fileService: fileService!)
    }
    
    func testGetProjects() throws {
        let projects = try projectService!.getProjects()
        for (index, project) in projects.enumerated() {
            let expectedTitle = "Project \(index + 1)"
            XCTAssert(project.id == expectedTitle)
            XCTAssert(project.title == expectedTitle)
        }
    }
    
    func testGetProjectsThrows() {
        fileService!.isInErrorState = true
        XCTAssertThrowsError(try projectService!.getProjects())
    }

    func testGetTracks() throws {
        let project = Project(id: "Project 1", title: "Project 1")
        let tracks = try projectService!.getTracks(for: project)
        for (index, track) in tracks.enumerated() {
            let expectedTitle = "Track \(index + 1)"
            XCTAssert(track.id == "Project 1-\(expectedTitle)")
            XCTAssert(track.title == expectedTitle)
            XCTAssert(track.url == URL(fileURLWithPath: "/remote/Project 1/\(expectedTitle)"))
        }
    }
    
    func testGetTracksThrows() {
        fileService!.isInErrorState = true
        let project = Project(id: "Project 1", title: "Project 1")
        XCTAssertThrowsError(try projectService!.getTracks(for: project))
    }
        
    func testDownloadTrack() {
        let url = URL(fileURLWithPath: "/remote/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        let expectation = XCTestExpectation(description: "Track download should succeed")
        let publisher = projectService!.downloadTrack(track)
        MixNotes_XCTAssertPublisherFinishes(
            expectation: expectation,
            publisher: publisher
        ) {
            XCTAssert($0.path == "/local/Project 1/Track 1")
        }
    }
    
    func testDownloadTrackErrors() {
        fileService!.isInErrorState = true
        let url = URL(fileURLWithPath: "/remote/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        let expectation = XCTestExpectation(description: "Track download should error")
        let publisher = projectService!.downloadTrack(track)
        MixNotes_XCTAssertPublisherErrors(
            expectation: expectation,
            publisher: publisher
        )
    }
    
    func testEvictTrack() {
        let url = URL(fileURLWithPath: "/local/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        let expectation = XCTestExpectation(description: "Track eviction should succeed")
        let publisher = projectService!.evictTrack(track)
        MixNotes_XCTAssertPublisherFinishes(
            expectation: expectation,
            publisher: publisher
        ) {
            print($0.path)
            XCTAssert($0.path == "/remote/Project 1/Track 1")
        }
    }
    
    func testEvictTrackErrors() {
        fileService!.isInErrorState = true
        let url = URL(fileURLWithPath: "/local/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        let expectation = XCTestExpectation(description: "Track eviction should fail")
        let publisher = projectService!.evictTrack(track)
        MixNotes_XCTAssertPublisherErrors(
            expectation: expectation,
            publisher: publisher
        )
    }
    
    func testDownloadTrackStatusDownloaded() {
        let url = URL(fileURLWithPath: "/remote/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        fileService?.downloadStatus = .current
        let status = projectService!.getTrackDownloadStatus(track)
        XCTAssert(status == .downloaded)
    }
    
    func testDownloadTrackStatusStale() {
        let url = URL(fileURLWithPath: "/remote/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        fileService?.downloadStatus = .downloaded
        let status = projectService!.getTrackDownloadStatus(track)
        XCTAssert(status == .stale)
    }
    
    func testDownloadTrackStatusNotDownloaded() {
        let url = URL(fileURLWithPath: "/remote/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        fileService?.downloadStatus = .notDownloaded
        let status = projectService!.getTrackDownloadStatus(track)
        XCTAssert(status == .notDownloaded)
    }
    
    func testDownloadTrackStatusError() {
        let url = URL(fileURLWithPath: "/remote/Project 1/Track 1")
        let track = Track(id: "Project 1-Track 1", title: "Track 1", lastModified: Date(), url: url)
        fileService?.isInErrorState = true
        let status = projectService!.getTrackDownloadStatus(track)
        XCTAssert(status == .error)
    }
}
