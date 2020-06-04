import Foundation

struct Track: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let version: Int
    var url: URL
}
