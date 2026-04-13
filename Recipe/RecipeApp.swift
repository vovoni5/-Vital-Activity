import SwiftUI
import CoreData

@main
struct RecipeApp: App {
    // Зависимости
    let persistenceController = PersistenceController.shared
    @StateObject private var timerManager = TimerManager.shared

    init() {
        // Настройка акцентного цвета (фиолетовый)
        let accent = UIColor(red: 0.47, green: 0.20, blue: 0.95, alpha: 1.0)
        UIView.appearance().tintColor = accent
        UINavigationBar.appearance().tintColor = accent
        UIBarButtonItem.appearance().tintColor = accent
        UITextField.appearance().tintColor = accent
        UITextView.appearance().tintColor = accent
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(timerManager)
        }
    }
}
