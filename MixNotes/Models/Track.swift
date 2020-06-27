import Foundation

struct Track: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let lastModified: Date?
    var url: URL
}
