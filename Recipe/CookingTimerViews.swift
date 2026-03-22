import SwiftUI
import CoreData
import AudioToolbox
import Combine

struct CookingTimerRootView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecipeEntity.title, ascending: true)],
        animation: .default
    )
    private var recipes: FetchedResults<RecipeEntity>

    var body: some View {
        ZStack {
            AppGradientBackground().ignoresSafeArea()

            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Text("Таймер готовки")
                        .primaryTitle()
                        .animatedText()
                    Text("Выберите рецепт — откроются таймеры по действиям")
                        .secondaryText()
                        .animatedText()
                }
                .padding(.top, 18)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(recipes, id: \.objectID) { recipe in
                            NavigationLink {
                                CookingTimerRecipeView(recipe: recipe)
                            } label: {
                                CardContainer {
                                    Text(recipe.title ?? "")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        if recipes.isEmpty {
                            CardContainer {
                                VStack(spacing: 8) {
                                    Text("Нет рецептов")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Text("Сначала добавьте рецепты в базе")
                                        .secondaryText()
                                        .animatedText()
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .screenAppear()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CookingTimerRecipeView: View {
    @ObservedObject var recipe: RecipeEntity

    @State private var timers: [StepTimerState] = []

    var body: some View {
        ZStack {
            AppGradientBackground().ignoresSafeArea()

            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Text(recipe.title ?? "")
                        .primaryTitle()
                        .animatedText()
                    Text("Таймеры по действиям")
                        .secondaryText()
                        .animatedText()
                }
                .padding(.top, 18)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach($timers) { $timer in
                            StepTimerCard(timer: $timer) {
                                playTripleBeep()
                            }
                        }

                        if timers.isEmpty {
                            CardContainer {
                                VStack(spacing: 8) {
                                    Text("Шагов нет")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Text("Добавьте действия и время в рецепте")
                                        .secondaryText()
                                        .animatedText()
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .screenAppear()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resetTimers()
        }
        .onDisappear {
            resetTimers()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { now in
            _ = now
            tickTimers()
        }
    }

    private func resetTimers() {
        timers = recipe.steps.map { StepTimerState(stepID: $0.id, action: $0.action, totalSeconds: max(0, $0.minutes) * 60) }
    }

    private func tickTimers() {
        for idx in timers.indices {
            guard timers[idx].isRunning, !timers[idx].isDone else { continue }
            timers[idx].remainingSeconds = max(0, timers[idx].remainingSeconds - 1)
            if timers[idx].remainingSeconds == 0 {
                timers[idx].isRunning = false
                timers[idx].isDone = true
                timers[idx].justFinishedToken = UUID()
            }
        }
    }
}

struct StepTimerState: Identifiable, Equatable {
    let id: UUID = UUID()
    let stepID: UUID
    var action: String
    var totalSeconds: Int
    var remainingSeconds: Int
    var isRunning: Bool
    var isDone: Bool
    var justFinishedToken: UUID?

    init(stepID: UUID, action: String, totalSeconds: Int) {
        self.stepID = stepID
        self.action = action
        self.totalSeconds = totalSeconds
        self.remainingSeconds = totalSeconds
        self.isRunning = false
        self.isDone = false
        self.justFinishedToken = nil
    }
}

private struct StepTimerCard: View {
    @Binding var timer: StepTimerState
    var onFinished: () -> Void

    @State private var finishedPulse = false

    var body: some View {
        CardContainer {
            VStack(spacing: 12) {
                Text(timer.action.isEmpty ? "Действие" : timer.action)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .animatedText()

                if timer.isDone {
                    Text("Готово!")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.accentPurple)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .scaleEffect(finishedPulse ? 1.03 : 0.98)
                        .opacity(finishedPulse ? 1.0 : 0.92)
                        .animation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true), value: finishedPulse)
                        .onAppear { finishedPulse = true }
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Text(timeString(timer.remainingSeconds))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .scale))
                }

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                        if timer.isDone {
                            reset()
                        } else {
                            timer.isRunning.toggle()
                        }
                    }
                } label: {
                    Text(buttonTitle)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(PillButtonStyle())
            }
            .onChange(of: timer.justFinishedToken) { _, newValue in
                if newValue != nil {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        // переход в состояние "Готово!" уже произошёл в родителе
                    }
                    onFinished()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var buttonTitle: String {
        if timer.isDone { return "Сброс" }
        return timer.isRunning ? "Пауза" : "Начать"
    }

    private func reset() {
        timer.remainingSeconds = timer.totalSeconds
        timer.isRunning = false
        timer.isDone = false
        timer.justFinishedToken = nil
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private func playTripleBeep() {
    let soundID: SystemSoundID = 1057
    AudioServicesPlaySystemSound(soundID)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        AudioServicesPlaySystemSound(soundID)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        AudioServicesPlaySystemSound(soundID)
    }
}

#Preview {
    NavigationStack {
        CookingTimerRootView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

