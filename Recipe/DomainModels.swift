import Foundation

enum RecipeCategory: String, CaseIterable, Identifiable {
    case all = "Все рецепты"
    case breakfast = "Завтраки"
    case soups = "Супы"
    case mains = "Основные блюда"
    case salads = "Салаты"
    case baking = "Выпечка"
    case desserts = "Десерты"
    case snakes = "Закуски"

    var id: String { rawValue }

    var storageValue: String {
        switch self {
        case .all: return "Все"
        default: return rawValue
        }
    }
}

struct Ingredient: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    /// Значение хранится в граммах (база), конвертация только для отображения.
    var grams: Double
}

struct CookingStep: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var action: String
    var minutes: Int
}

enum QuantityUnit: String, CaseIterable, Identifiable {
    case grams = "г"
    case tbsp = "ст. л."
    case pieces = "шт"

    var id: String { rawValue }
}

enum UnitConverter {
    /// Универсальная бытовая конверсия: 1 столовая ложка ≈ 15 г.
    static let gramsPerTbsp: Double = 15.0

    /// Условная бытовая конверсия для штук (например, среднего продукта) — 1 шт ≈ 50 г.
    static let gramsPerPiece: Double = 50.0

    static func gramsToTbsp(_ grams: Double) -> Double {
        grams / gramsPerTbsp
    }

    static func tbspToGrams(_ tbsp: Double) -> Double {
        tbsp * gramsPerTbsp
    }

    static func gramsToPieces(_ grams: Double) -> Double {
        grams / gramsPerPiece
    }

    static func piecesToGrams(_ pieces: Double) -> Double {
        pieces * gramsPerPiece
    }
}

