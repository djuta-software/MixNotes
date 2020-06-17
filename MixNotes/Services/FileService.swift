import Foundation
import Combine

protocol FileServiceProtocol {
    func readDir(_ path: String, onlyDirectories: Bool) throws -> [String]
    func getItemUrl(_ pathComponents: String...) -> URL
    func downloadItem(at url: URL) -> AnyPublisher<URL, Error>
    func evictItem(at url: URL) -> AnyPublisher<URL, Error>
    func getDownloadStatus(for url: URL) throws -> URLUbiquitousItemDownloadingStatus
}

extension FileServiceProtocol {
    func readDir(_ path: String, onlyDirectories: Bool = false) throws -> [String] {
        return try readDir(path, onlyDirectories: onlyDirectories)
    }
}

class FileService: FileServiceProtocol {
    let fileManager = FileManager.default
    
    init() throws {
        guard let url = containerUrl else { return }
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let message = "Hello World"
        print(url.path)
        let readmeUrl = url.appendingPathComponent("README.txt")
        try message.write(to: readmeUrl, atomically: true, encoding: .utf8)
    }

    func readDir(_ path: String, onlyDirectories: Bool = false) throws -> [String] {
        guard let basePath = containerUrl else {
            return []
        }
        
        let options: FileManager.DirectoryEnumerationOptions = onlyDirectories
            ? .skipsHiddenFiles
            : []
        
        let urls = try fileManager.contentsOfDirectory(
            at: basePath.appendingPathComponent(path),
            includingPropertiesForKeys: [
                URLResourceKey.isDirectoryKey
            ],
            options: options
        )
        return urls
            .filter { !onlyDirectories || $0.hasDirectoryPath }
            .map { $0.getDisplayName() }

    }
    
    func getItemUrl(_ pathComponents: String...) -> URL {
        guard let basePath = containerUrl else {
            // TODO throw error
            return URL(fileURLWithPath: "")
        }
        var url = basePath
        for component in pathComponents {
            url = url.appendingPathComponent(component)
        }
        return url
    }
    
    func downloadItem(at url: URL) -> AnyPublisher<URL, Error> {
        do {
            try fileManager.startDownloadingUbiquitousItem(at: url)
            return onDownloadStatusChange(for: url, when: .current)
                .map { $0.getLocalURL() }
                .eraseToAnyPublisher()
        } catch {
            return createFailedPublisher(error: error)
        }
    }

    func evictItem(at url: URL) -> AnyPublisher<URL, Error> {
        do {
            try fileManager.evictUbiquitousItem(at: url)
            return onDownloadStatusChange(for: url, when: .notDownloaded)
                .map { $0.getRemoteURL() }
                .eraseToAnyPublisher()
        } catch {
            return createFailedPublisher(error: error)
        }
    }
    
    func getDownloadStatus(for url: URL) throws -> URLUbiquitousItemDownloadingStatus {
        guard let status = try url.resourceValues(
            forKeys: [.ubiquitousItemDownloadingStatusKey]
        ).ubiquitousItemDownloadingStatus else {
            return .current
        }
        return status
    }
    
    // TODO: there has to be a better way to do this
    private func onDownloadStatusChange(
        for url: URL,
        when desiredStatus: URLUbiquitousItemDownloadingStatus
    ) -> Future<URL, Error> {
        return Future<URL, Error> { promise in
            weak var timer: Timer?
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                do {
                    let status = try self?.getDownloadStatus(for: url)
                    if(status == desiredStatus) {
                        promise(.success(url))
                        timer?.invalidate()
                    }
                } catch {
                    promise(.failure(error))
                    timer?.invalidate()
                }
            }
        }
    }
    
    private func createFailedPublisher(error: Error) -> AnyPublisher<URL, Error> {
        return Future<URL, Error> {
            promise in promise(.failure(error))
        }.eraseToAnyPublisher()
    }
    
    private var containerUrl: URL? {
        let url = fileManager.url(
            forUbiquityContainerIdentifier: nil
        )
        return url?.appendingPathComponent("Documents")
    }
}
