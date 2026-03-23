import Foundation
import SwiftUI

/// Централизованный обработчик ошибок для приложения.
enum ErrorHandler {
    /// Обрабатывает ошибку Core Data и показывает пользователю сообщение.
    /// В продакшене можно интегрировать с системой логирования (например, Crashlytics).
    static func handleCoreDataError(_ error: Error, message: String = "Не удалось сохранить данные") {
        // Логируем ошибку
        print("[CoreData Error] \(message): \(error)")
        
        // В будущем можно отправить в аналитику
        // Analytics.logError(error)
        
        // Показываем пользователю уведомление (можно использовать Alert или Toast)
        // Для простоты сейчас просто логируем, но можно добавить механизм показа алертов.
        DispatchQueue.main.async {
            // Можно использовать NotificationCenter для показа алерта в любом view
            NotificationCenter.default.post(
                name: .coreDataSaveError,
                object: nil,
                userInfo: ["message": message, "error": error]
            )
        }
    }
    
    /// Показывает алерт с ошибкой в переданном View.
    @MainActor
    static func showAlert(error: Error, in viewController: UIViewController?) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController?.present(alert, animated: true)
    }
}

extension Notification.Name {
    static let coreDataSaveError = Notification.Name("coreDataSaveError")
}

/// Модификатор для отлова ошибок Core Data и показа алерта.
/// Можно использовать в корневом View для глобальной обработки.
struct CoreDataErrorAlertModifier: ViewModifier {
    @State private var showAlert = false
    @State private var errorMessage: String?
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .coreDataSaveError)) { notification in
                if let message = notification.userInfo?["message"] as? String {
                    errorMessage = message
                    showAlert = true
                }
            }
            .alert("Ошибка сохранения", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "Произошла неизвестная ошибка.")
            }
    }
}

extension View {
    /// Добавляет обработку ошибок Core Data через алерт.
    func withCoreDataErrorHandling() -> some View {
        modifier(CoreDataErrorAlertModifier())
    }
}