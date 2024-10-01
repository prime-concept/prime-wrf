import Foundation

struct Meta: Decodable {
    let page: Int
    private let pageSize: Int
    let total: Int

    var pages: Int {
        let divided = Double(self.total) / Double(self.pageSize)
        return Int(ceil(divided))
    }

    var hasNext: Bool {
        return (self.page + 1) <= self.pages
    }

    var next: Int {
        return self.page + 1
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.page = try container.decode(Int.self, forKey: .page)
        self.pageSize = try container.decode(Int.self, forKey: .pageSize)
        self.total = try container.decode(Int.self, forKey: .total)
    }

    enum CodingKeys: String, CodingKey {
        case page
        case pageSize
        case total
    }
}
