import SwiftUI
import CoreData

struct MealPlanPickerSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MealPlanEntity.name, ascending: true)],
        animation: .default
    )
    private var plans: FetchedResults<MealPlanEntity>

    let onPick: (MealPlanEntity) -> Void

    var body: some View {
        ZStack {
            AppGradientBackground().ignoresSafeArea()

            VStack(spacing: 14) {
                Text("Выберите рацион")
                    .primaryTitle()
                    .animatedText()
                    .padding(.top, 18)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(plans, id: \.objectID) { plan in
                            Button {
                                onPick(plan)
                                dismiss()
                            } label: {
                                CardContainer {
                                    Text(plan.name ?? "")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        if plans.isEmpty {
                            CardContainer {
                                VStack(spacing: 10) {
                                    Text("Рационов нет")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Text("Создайте рацион в «Планировщик меню»")
                                        .secondaryText()
                                        .animatedText()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .screenAppear()
                }

                Button {
                    dismiss()
                } label: {
                    Text("Закрыть")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(PillButtonStyle())
                .frame(maxWidth: 220)
                .padding(.bottom, 18)
            }
        }
    }
}

