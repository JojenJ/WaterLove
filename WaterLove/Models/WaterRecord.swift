import Foundation

struct WaterRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let amountML: Int
    let createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amountML: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.amountML = amountML
        self.createdAt = createdAt
    }
}
