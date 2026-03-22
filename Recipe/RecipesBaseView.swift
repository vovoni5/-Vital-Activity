import SwiftUI
import CoreData

struct RecipesBaseView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecipeEntity.title, ascending: true)],
        animation: .default
    )
    private var recipes: FetchedResults<RecipeEntity>

    @State private var selectedCategory: RecipeCategory = .all
    @State private var showAddRecipeSheet = false

    @State private var pendingDelete: RecipeEntity?
    @State private var showDeleteConfirm = false

    @State private var pendingAddToPlan: RecipeEntity?
    @State private var showAddToPlanConfirm = false
    @State private var showPickMealPlan = false

    private var filtered: [RecipeEntity] {
        let allRecipes: [RecipeEntity] = recipes.map { $0 }
        if selectedCategory == .all {
            return allRecipes
        }
        let targetCategory = selectedCategory.rawValue
        let filteredRecipes = allRecipes.filter { recipe in
            let recipeCategory = recipe.category ?? ""
            return recipeCategory == targetCategory
        }
        return filteredRecipes
    }

    var body: some View {
        ZStack {
            AppGradientBackground().ignoresSafeArea()

            VStack(spacing: 14) {
                RecipesHeader()

                CategoryChips(selected: $selectedCategory)
                    .padding(.horizontal, 14)

                RecipesList(
                    recipes: filtered,
                    onDeleteRequest: { recipe in
                        pendingDelete = recipe
                        showDeleteConfirm = true
                    },
                    onAddToPlanRequest: { recipe in
                        pendingAddToPlan = recipe
                        showAddToPlanConfirm = true
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddRecipeSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showAddRecipeSheet) {
            AddOrEditRecipeSheet(mode: .create) { draft in
                let newRecipe = RecipeEntity(context: viewContext)
                newRecipe.id = UUID()
                newRecipe.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                newRecipe.detailsText = draft.detailsText.trimmingCharacters(in: .whitespacesAndNewlines)
                newRecipe.category = draft.category.rawValue
                newRecipe.ingredients = draft.ingredients
                newRecipe.steps = draft.steps
                save()
            }
        }
        .alert("Удалить рецепт?", isPresented: $showDeleteConfirm) {
            Button("Удалить", role: .destructive) {
                if let pendingDelete {
                    viewContext.delete(pendingDelete)
                    save()
                }
                self.pendingDelete = nil
            }
            Button("Отмена", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("Действие нельзя отменить.")
        }
        .alert("Добавить в рацион?", isPresented: $showAddToPlanConfirm) {
            Button("Выбрать рацион") {
                showPickMealPlan = true
            }
            Button("Отмена", role: .cancel) {
                pendingAddToPlan = nil
            }
        } message: {
            Text("Рецепт будет добавлен в выбранный дневной рацион.")
        }
        .sheet(isPresented: $showPickMealPlan) {
            MealPlanPickerSheet { plan in
                guard let recipe = pendingAddToPlan else { return }
                if let recipeID = recipe.id, !plan.recipeIDs.contains(recipeID) {
                    plan.recipeIDs = plan.recipeIDs + [recipeID]
                    save()
                }
                pendingAddToPlan = nil
            }
        }
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            // В продакшене показали бы аккуратный алерт.
            assertionFailure("Core Data save error: \(error)")
        }
    }
}

private struct RecipesList: View {
    let recipes: [RecipeEntity]
    let onDeleteRequest: (RecipeEntity) -> Void
    let onAddToPlanRequest: (RecipeEntity) -> Void

    var body: some View {
        List {
            ForEach(recipes, id: \.objectID) { recipe in
                RecipeRow(
                    recipe: recipe,
                    onDeleteRequest: { onDeleteRequest(recipe) },
                    onAddToPlanRequest: { onAddToPlanRequest(recipe) }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
            }

            if recipes.isEmpty {
                EmptyRecipesState()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .padding(.bottom, 24)
        .screenAppear()
        .background(Color.clear)
    }
}

private struct RecipeRow: View {
    let recipe: RecipeEntity
    let onDeleteRequest: () -> Void
    let onAddToPlanRequest: () -> Void

    var body: some View {
        NavigationLink {
            RecipeDetailView(recipe: recipe)
        } label: {
            CardContainer {
                Text(recipe.title ?? "")
                    .recipeNameTitle()
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onDeleteRequest()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            .tint(AppColors.accentPink)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onAddToPlanRequest()
            } label: {
                Label("В рацион", systemImage: "text.badge.plus")
            }
            .tint(AppColors.accentPurple)
        }
    }
}

private struct EmptyRecipesState: View {
    var body: some View {
        CardContainer {
            VStack(spacing: 8) {
                Text("Пока пусто")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                Text("Нажмите +, чтобы добавить первый рецепт")
                    .secondaryText()
                    .animatedText()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct RecipesHeader: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("База рецептов")
                .primaryTitle()
                .animatedText()
            Text("Выбирайте, храните и готовьте с таймером")
                .secondaryText()
                .animatedText()
        }
        .padding(.top, 18)
    }
}

private struct CategoryChips: View {
    @Binding var selected: RecipeCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RecipeCategory.allCases) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = cat
                        }
                    } label: {
                        Text(cat.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selected == cat ? .white : AppColors.textPrimary)
                            .frame(height: 34)
                            .padding(.horizontal, 14)
                            .frame(maxHeight: 34)
                            .background(
                                Group {
                                    if selected == cat {
                                        LinearGradient(
                                            colors: [AppColors.accentPurple.opacity(0.8), AppColors.accentPink.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        Color.white.opacity(0.8)
                                    }
                                }
                            )
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    NavigationStack {
        RecipesBaseView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

