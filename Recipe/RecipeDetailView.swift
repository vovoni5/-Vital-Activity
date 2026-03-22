import SwiftUI
import CoreData
import UIKit

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var recipe: RecipeEntity

    @State private var showEditSheet = false

    var body: some View {
        ZStack {
            AppGradientBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 8) {
                        Text(recipe.title ?? "")
                    .primaryTitle()
                    .animatedText()

                        if let desc = recipe.detailsText, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            TextWithLinks(
                                text: desc,
                                uiFont: UIFont(name: AppFonts.subtitle, size: 16) ?? UIFont.systemFont(ofSize: 16),
                                color: AppColors.textSecondary,
                                alignment: .center
                            )
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .animatedText()
                        }
                    }
                    .padding(.top, 18)

                    CardContainer {
                        VStack(spacing: 12) {
                            Text("Ингредиенты")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)

                            if recipe.ingredients.isEmpty {
                                Text("Добавьте ингредиенты в режиме редактирования")
                                    .secondaryText()
                                    .animatedText()
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(recipe.ingredients) { ing in
                                        IngredientReadOnlyRow(ingredient: ing)
                                    }
                                }
                            }
                        }
                    }

                    CardContainer {
                        VStack(spacing: 12) {
                            Text("Таймер действий")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)

                            if recipe.steps.isEmpty {
                                Text("Добавьте действия и время — тогда появятся таймеры")
                                    .secondaryText()
                                    .animatedText()
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(recipe.steps) { step in
                                        StepReadOnlyRow(step: step)
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        // Переход в таймер готовки, связанный с рецептом
                        showTimer(for: recipe)
                    } label: {
                        Text("Приготовить")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(PillButtonStyle())
                    .frame(maxWidth: 260)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .screenAppear()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showEditSheet = true
                    }
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddOrEditRecipeSheet(mode: .edit(existing: recipe)) { draft in
                recipe.title = draft.title
                recipe.detailsText = draft.detailsText
                recipe.category = draft.category.rawValue
                recipe.ingredients = draft.ingredients
                recipe.steps = draft.steps
                save()
            }
        }
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            assertionFailure("Core Data save error: \(error)")
        }
    }

    private func showTimer(for recipe: RecipeEntity) {
        // Навигация в SwiftUI: открываем через hidden NavigationLink-пуш.
        // Реализация через отдельный overlay, чтобы сохранить стиль и анимации.
        NotificationCenter.default.post(
            name: .openRecipeTimer,
            object: nil,
            userInfo: ["recipeObjectID": recipe.objectID]
        )
    }
}

private struct IngredientReadOnlyRow: View {
    let ingredient: Ingredient
    @State private var unit: QuantityUnit = .grams

    var body: some View {
        VStack(spacing: 10) {
            Text(ingredient.name)
                .recipeNameTitle()

            Text(displayQuantity)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    switch unit {
                    case .grams:
                        unit = .tbsp
                    case .tbsp:
                        unit = .pieces
                    case .pieces:
                        unit = .grams
                    }
                }
            } label: {
                Text(unit.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 90, height: 36, alignment: .center)
                    .multilineTextAlignment(.center)
                    .background(
                        LinearGradient(
                            colors: [AppColors.accentPurple, AppColors.accentPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .background(Color.white.opacity(0.45))
        .cornerRadius(18)
    }

    private var displayQuantity: String {
        let value: Double
        switch unit {
        case .grams:
            value = ingredient.grams
        case .tbsp:
            value = UnitConverter.gramsToTbsp(ingredient.grams)
        case .pieces:
            value = UnitConverter.gramsToPieces(ingredient.grams)
        }
        let rounded = (value * 10).rounded() / 10
        let str = rounded == rounded.rounded() ? "\(Int(rounded))" : "\(rounded)"
        return "\(str) \(unit.rawValue)"
    }
}

private struct StepReadOnlyRow: View {
    let step: CookingStep

    var body: some View {
        VStack(spacing: 6) {
            Text(step.action)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            Text("\(step.minutes) мин")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.45))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}

extension Notification.Name {
    static let openRecipeTimer = Notification.Name("openRecipeTimer")
}
