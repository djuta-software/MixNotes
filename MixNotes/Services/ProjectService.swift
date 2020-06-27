import Foundation
import Combine

enum TrackDownloadStatus {
    case downloaded, notDownloaded, error, stale
}

protocol ProjectServiceProtocol {
    func getProjects() throws -> [Project]
    func getTracks(for project: Project) throws -> [Track]
    func getTrackDownloadStatus(_ track: Track) -> TrackDownloadStatus
    func downloadTrack(_ track: Track) -> AnyPublisher<URL, Error>
    func evictTrack(_ track: Track) -> AnyPublisher<URL, Error>
}

class ProjectService: ProjectServiceProtocol {

    let fileService: FileServiceProtocol

    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }
    
    func getProjects() throws -> [Project] {
        let items = try fileService.readDir("", onlyDirectories: true)
        return items.map { item in
            Project(id: item, title: item)
        }
    }
    
    func getTracks(for project: Project) throws -> [Track] {
        let items = try fileService.readDir(project.title)
        return items.enumerated().map { (index, item) in
            let url = fileService.getItemUrl(project.title, item)
            let version = NSFileVersion.currentVersionOfItem(at: url)
            return Track(
                id: "\(project.title)-\(item)",
                title: item,
                lastModified: version?.modificationDate,
                url: url
            )
        }
    }
    
    func downloadTrack(_ track: Track) -> AnyPublisher<URL, Error> {
        return fileService.downloadItem(at: track.url)
    }
    
    func evictTrack(_ track: Track) -> AnyPublisher<URL, Error> {
        return fileService.evictItem(at: track.url)
    }
    
    func getTrackDownloadStatus(_ track: Track) -> TrackDownloadStatus {
        do {
            let status = try fileService.getDownloadStatus(for: track.url)
            switch status {
            case .current:
                return .downloaded
            case .downloaded:
                return .stale
            default:
                return .notDownloaded
            }
        } catch {
            return .error
        }
    }
}
