import CoreData

// MARK: - PersistenceController
struct PersistenceController {
    // Singleton для production
    static let shared = PersistenceController()

    // Экземпляр для превью с тестовыми данными
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Примеры рецептов для превью
        let sampleRecipe = RecipeEntity(context: viewContext)
        sampleRecipe.id = UUID()
        sampleRecipe.title = "Овсяная каша с ягодами"
        sampleRecipe.category = "Завтраки"
        sampleRecipe.detailsText = "Нежная овсяная каша на молоке с сезонными ягодами."

        let sampleRecipe2 = RecipeEntity(context: viewContext)
        sampleRecipe2.id = UUID()
        sampleRecipe2.title = "Овощной крем‑суп"
        sampleRecipe2.category = "Супы"
        sampleRecipe2.detailsText = "Лёгкий и ароматный суп‑пюре для всей семьи."

        let mealPlan = MealPlanEntity(context: viewContext)
        mealPlan.id = UUID()
        mealPlan.name = "Семейный день"
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Recipe")
        
        if inMemory {
            // In-memory хранилище для тестов и превью
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Автоматическое слияние изменений из родительского контекста
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
