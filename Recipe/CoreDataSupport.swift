import Foundation
import CoreData

enum DataCoding {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

extension RecipeEntity {
    var ingredients: [Ingredient] {
        get { DataCoding.decode([Ingredient].self, from: ingredientsData) ?? [] }
        set { ingredientsData = DataCoding.encode(newValue) }
    }

    var steps: [CookingStep] {
        get { DataCoding.decode([CookingStep].self, from: stepsData) ?? [] }
        set { stepsData = DataCoding.encode(newValue) }
    }
}

extension MealPlanEntity {
    var recipeIDs: [UUID] {
        get { DataCoding.decode([UUID].self, from: recipeIDsData) ?? [] }
        set { recipeIDsData = DataCoding.encode(newValue) }
    }
}

