import Foundation
import CoreData

/// Репозиторий для работы со списком покупок в Core Data.
final class ShoppingListRepository {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD операции
    
    /// Добавляет новый элемент в список покупок.
    func addItem(_ item: ShoppingItem) throws {
        let entity = ShoppingItemEntity(context: context)
        entity.update(from: item)
        try context.save()
    }
    
    /// Добавляет все ингредиенты рецепта в список покупок.
    func addIngredients(from recipe: RecipeEntity, category: String? = nil) throws {
        let ingredients = recipe.ingredients
        for ingredient in ingredients {
            let shoppingItem = ShoppingItem(from: ingredient, category: category)
            try addItem(shoppingItem)
        }
    }
    
    /// Обновляет существующий элемент.
    func updateItem(_ item: ShoppingItem) throws {
        let fetchRequest: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        guard let entity = results.first else {
            throw NSError(domain: "ShoppingListRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Элемент не найден"])
        }
        
        entity.update(from: item)
        try context.save()
    }
    
    /// Удаляет элемент по идентификатору.
    func deleteItem(withID id: UUID) throws {
        let fetchRequest: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        if let entity = results.first {
            context.delete(entity)
            try context.save()
        }
    }
    
    /// Удаляет все элементы списка покупок.
    func deleteAllItems() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ShoppingItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
    }
    
    /// Переключает статус покупки элемента.
    func togglePurchased(for item: ShoppingItem) throws -> ShoppingItem {
        var updated = item
        updated.isPurchased.toggle()
        try updateItem(updated)
        return updated
    }
    
    // MARK: - Запросы
    
    /// Возвращает все элементы списка покупок.
    func fetchAllItems() throws -> [ShoppingItem] {
        let fetchRequest: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \ShoppingItemEntity.isPurchased, ascending: true),
            NSSortDescriptor(keyPath: \ShoppingItemEntity.name, ascending: true)
        ]
        
        let entities = try context.fetch(fetchRequest)
        return entities.compactMap { $0.toShoppingItem }
    }
    
    /// Возвращает элементы, сгруппированные по категориям.
    func fetchItemsGroupedByCategory() throws -> [String: [ShoppingItem]] {
        let items = try fetchAllItems()
        var grouped: [String: [ShoppingItem]] = [:]
        
        for item in items {
            let category = item.category ?? IngredientCategory.other.rawValue
            grouped[category, default: []].append(item)
        }
        
        return grouped
    }
    
    /// Объединяет дублирующиеся элементы (одинаковое название и единица измерения).
    func mergeDuplicateItems() throws {
        let items = try fetchAllItems()
        var mergedMap: [String: ShoppingItem] = [:] // ключ: "name|unit"
        
        for item in items {
            let key = "\(item.name.lowercased())|\(item.unit.rawValue)"
            if let existing = mergedMap[key] {
                // Объединяем количество
                let merged = ShoppingItem(
                    id: existing.id,
                    name: existing.name,
                    quantity: existing.quantity + item.quantity,
                    unit: existing.unit,
                    isPurchased: existing.isPurchased && item.isPurchased,
                    category: existing.category
                )
                mergedMap[key] = merged
                // Удаляем старый элемент из Core Data
                try deleteItem(withID: item.id)
            } else {
                mergedMap[key] = item
            }
        }
        
        // Обновляем оставшиеся элементы
        for (_, item) in mergedMap {
            try updateItem(item)
        }
    }
}