import Foundation
import CoreData
import Combine

/// ViewModel для экрана списка покупок.
final class ShoppingListViewModel: ObservableObject {
    
    @Published private(set) var items: [ShoppingItem] = []
    @Published var groupedItems: [String: [ShoppingItem]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ShoppingListRepository
    private var cancellables: Set<AnyCancellable> = []
    
    init(context: NSManagedObjectContext) {
        self.repository = ShoppingListRepository(context: context)
        loadItems()
    }
    
    // MARK: - Загрузка данных
    
    /// Загружает все элементы списка покупок.
    func loadItems() {
        isLoading = true
        errorMessage = nil
        
        do {
            items = try repository.fetchAllItems()
            groupedItems = try repository.fetchItemsGroupedByCategory()
            isLoading = false
        } catch {
            errorMessage = "Не удалось загрузить список покупок"
            isLoading = false
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    // MARK: - Управление элементами
    
    /// Добавляет новый элемент.
    func addItem(name: String, quantity: Double, unit: QuantityUnit, category: String? = nil) {
        let newItem = ShoppingItem(name: name, quantity: quantity, unit: unit, category: category)
        do {
            try repository.addItem(newItem)
            loadItems()
        } catch {
            errorMessage = "Не удалось добавить элемент"
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    /// Добавляет ингредиенты рецепта в список покупок.
    func addIngredients(from recipe: RecipeEntity, category: String? = nil) {
        do {
            try repository.addIngredients(from: recipe, category: category)
            loadItems()
        } catch {
            errorMessage = "Не удалось добавить ингредиенты"
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    /// Удаляет элемент.
    func deleteItem(_ item: ShoppingItem) {
        do {
            try repository.deleteItem(withID: item.id)
            loadItems()
        } catch {
            errorMessage = "Не удалось удалить элемент"
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    /// Удаляет все элементы.
    func deleteAllItems() {
        do {
            try repository.deleteAllItems()
            loadItems()
        } catch {
            errorMessage = "Не удалось очистить список"
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    /// Переключает статус покупки элемента.
    func togglePurchased(for item: ShoppingItem) {
        do {
            _ = try repository.togglePurchased(for: item)
            loadItems()
        } catch {
            errorMessage = "Не удалось обновить элемент"
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    /// Объединяет дублирующиеся элементы.
    func mergeDuplicates() {
        do {
            try repository.mergeDuplicateItems()
            loadItems()
        } catch {
            errorMessage = "Не удалось объединить дубликаты"
            ErrorHandler.handleCoreDataError(error, message: errorMessage ?? "")
        }
    }
    
    // MARK: - Вспомогательные методы
    
    /// Возвращает категории, отсортированные по алфавиту.
    var sortedCategories: [String] {
        groupedItems.keys.sorted()
    }
    
    /// Возвращает элементы для конкретной категории.
    func items(for category: String) -> [ShoppingItem] {
        groupedItems[category] ?? []
    }
    
    /// Возвращает общее количество непокупных элементов.
    var totalUnpurchasedCount: Int {
        items.filter { !$0.isPurchased }.count
    }
}