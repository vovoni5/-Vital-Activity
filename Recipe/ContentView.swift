import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showSplash: Bool = true
    @State private var showMain: Bool = false
    @State private var pendingRecipeObjectID: NSManagedObjectID?

    var body: some View {
        ZStack {
            AppGradientBackground()

            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale))
            }

            if showMain {
                NavigationStack {
                    MainMenuView()
                        .navigationDestination(
                            isPresented: Binding(
                                get: { pendingRecipeObjectID != nil },
                                set: { isActive in
                                    if !isActive { pendingRecipeObjectID = nil }
                                }
                            )
                        ) {
                            destinationTimerView()
                        }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(\.managedObjectContext, viewContext)
        .ignoresSafeArea()
        .onAppear {
            // Анимация появления сплеш-экрана
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = true
            }

            // Через 2 секунды скрываем сплеш и показываем главное меню
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                }
                withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                    showMain = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openRecipeTimer)) { notif in
            // Обработка уведомления для открытия таймера рецепта
            if let id = notif.userInfo?["recipeObjectID"] as? NSManagedObjectID {
                pendingRecipeObjectID = id
            }
        }
    }

    @ViewBuilder
    private func destinationTimerView() -> some View {
        if let objectID = pendingRecipeObjectID,
           let recipe = try? viewContext.existingObject(with: objectID) as? RecipeEntity {
            CookingTimerRecipeView(recipe: recipe)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
