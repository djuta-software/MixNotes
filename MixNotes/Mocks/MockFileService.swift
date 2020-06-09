import Foundation
import Combine

enum MockFileServiceError: Error {
    case downloadItemError, evictItemError, downloadStatusError, readError
}

class MockFileService: FileServiceProtocol {
    let basePath = URL(fileURLWithPath: "/remote")
    var isInErrorState = false
    var downloadStatus: URLUbiquitousItemDownloadingStatus = .notDownloaded
    
    func getItemUrl(_ pathComponents: String...) -> URL {
        var url = basePath
        for component in pathComponents {
            url = url.appendingPathComponent(component)
        }
        return url
    }
    
    func readDir(_ path: String, onlyDirectories: Bool = false) throws -> [String] {
        print(isInErrorState)
        if isInErrorState {
            throw MockFileServiceError.readError
        }
        var files: [String] = []
        let prefix = onlyDirectories ? "Project" : "Track"
        for index in 1...3 {
            files.append("\(prefix) \(index)")
        }
        return files
    }
    
    func downloadItem(at url: URL) -> AnyPublisher<URL, Error> {
        return Future<URL, Error> { promise in
            if self.isInErrorState {
                promise(.failure(MockFileServiceError.downloadItemError))
                return
            }
            let newUrl = URL(fileURLWithPath: url.path.replacingOccurrences(
                of: "remote",
                with: "local"
            ))
            promise(.success(newUrl))
        }
        .eraseToAnyPublisher()
    }
    
    func evictItem(at url: URL) -> AnyPublisher<URL, Error> {
        return Future<URL, Error> { promise in
            if self.isInErrorState {
                promise(.failure(MockFileServiceError.downloadItemError))
                return
            }
            let newUrl = URL(fileURLWithPath: url.path.replacingOccurrences(
                of: "local",
                with: "remote"
            ))
            promise(.success(newUrl))
        }
        .eraseToAnyPublisher()
    }
    
    func getDownloadStatus(for url: URL) throws -> URLUbiquitousItemDownloadingStatus {
        if isInErrorState {
            throw MockFileServiceError.downloadStatusError
        }
        return downloadStatus
    }
}
