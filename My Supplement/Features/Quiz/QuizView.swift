//
//  QuizView.swift
//  My Supplement
//
//  Interactive quiz about supplements
//

import SwiftUI

struct QuizView: View {
    @State private var questions: [QuizQuestion] = []
    @State private var state = QuizState()
    @State private var showResult = false
    @State private var shakeAnswer = false
    @State private var selectedDifficulty: QuizDifficulty? = nil
    
    private var dataManager: DataManager { DataManager.shared }
    
    var currentQuestion: QuizQuestion? {
        guard state.currentQuestionIndex < questions.count else { return nil }
        return questions[state.currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if state.isCompleted {
                QuizResultView(result: QuizResult(
                    correct: state.correctCount,
                    incorrect: state.incorrectCount,
                    coinsEarned: state.coinsEarned,
                    date: Date()
                )) {
                    resetQuiz()
                }
            } else if let question = currentQuestion {
                // Progress Header
                progressHeader
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Question
                        questionCard(question)
                        
                        // Options
                        optionsGrid(question)
                        
                        // Navigation
                        navigationButtons
                    }
                    .padding()
                }
            } else {
                // Start screen with difficulty selection
                startScreen
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadQuestionsFromJSON()
        }
    }
    
    // MARK: - Start Screen
    private var startScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.appPrimary)
            
            Text("Test Your Knowledge")
                .font(.title.weight(.bold))
            
            Text("Answer questions about supplements and earn coins!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("Select Difficulty")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                        Button {
                            selectedDifficulty = difficulty
                        } label: {
                            VStack(spacing: 4) {
                                Text(difficulty.rawValue)
                                    .font(.subheadline.weight(.medium))
                                Text("+\(difficulty.coinsReward) coins")
                                    .font(.caption2)
                            }
                            .foregroundColor(selectedDifficulty == difficulty ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedDifficulty == difficulty ? Color(hex: difficulty.color) : Color.appCardBackground)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            
            Button("Start Quiz") {
                startQuiz()
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: selectedDifficulty == nil))
            .disabled(selectedDifficulty == nil)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(state.currentQuestionIndex + 1) of \(questions.count)")
                    .font(.subheadline.weight(.medium))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(state.coinsEarned)")
                        .font(.subheadline.weight(.bold))
                }
            }
            
            ProgressView(value: Double(state.currentQuestionIndex + 1), total: Double(questions.count))
                .tint(.appPrimary)
        }
        .padding()
        .background(Color.appCardBackground)
    }
    
    // MARK: - Question Card
    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(question.difficulty.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: question.difficulty.color))
                    .cornerRadius(12)
                
                Spacer()
            }
            
            Text(question.question)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
    }
    
    // MARK: - Options
    private func optionsGrid(_ question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options, id: \.self) { option in
                QuizOptionButton(
                    text: option,
                    isSelected: state.selectedAnswer == option,
                    state: optionState(for: option, question: question)
                ) {
                    selectAnswer(option, question: question)
                }
                .disabled(state.isAnswerRevealed)
            }
        }
    }
    
    private func optionState(for option: String, question: QuizQuestion) -> QuizOptionState {
        guard state.isAnswerRevealed else {
            return state.selectedAnswer == option ? .selected : .normal
        }
        
        if option == question.correctAnswer {
            return .correct
        } else if option == state.selectedAnswer {
            return .incorrect
        }
        return .normal
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if state.currentQuestionIndex > 0 {
                Button {
                    previousQuestion()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Button {
                if state.isAnswerRevealed {
                    nextQuestion()
                } else if state.selectedAnswer != nil {
                    revealAnswer()
                }
            } label: {
                Text(state.isAnswerRevealed ? "Next" : "Check Answer")
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: state.selectedAnswer == nil && !state.isAnswerRevealed))
            .disabled(state.selectedAnswer == nil && !state.isAnswerRevealed)
        }
    }
    
    // MARK: - Actions
    private func loadQuestionsFromJSON() {
        // Load from bundled JSON file
        if let url = Bundle.main.url(forResource: "QuizQuestions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let loaded = try decoder.decode([QuizQuestion].self, from: data)
                print("✅ Loaded \(loaded.count) quiz questions from JSON")
                // Don't filter yet - wait for difficulty selection
            } catch {
                print("❌ Error loading quiz questions: \(error)")
                loadSampleQuestions()
            }
        } else {
            print("⚠️ QuizQuestions.json not found, using sample data")
            loadSampleQuestions()
        }
    }
    
    private func startQuiz() {
        guard let difficulty = selectedDifficulty else { return }
        
        // Load and filter questions
        if let url = Bundle.main.url(forResource: "QuizQuestions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let allQuestions = try? JSONDecoder().decode([QuizQuestion].self, from: data) {
            
            // Filter by difficulty and shuffle
            let filtered = allQuestions.filter { 
                $0.difficulty.rawValue.lowercased() == difficulty.rawValue.lowercased() 
            }
            questions = Array(filtered.shuffled().prefix(5))
            
            if questions.isEmpty {
                // If no questions for this difficulty, use any 5
                questions = Array(allQuestions.shuffled().prefix(5))
            }
        } else {
            loadSampleQuestions()
        }
    }
    
    private func loadSampleQuestions() {
        questions = [
            QuizQuestion(
                question: "Which vitamin is primarily synthesized in the skin through sun exposure?",
                options: ["Vitamin A", "Vitamin C", "Vitamin D", "Vitamin E"],
                correctAnswer: "Vitamin D",
                explanation: "Vitamin D is synthesized when UVB rays from sunlight interact with cholesterol in skin cells.",
                difficulty: selectedDifficulty ?? .easy
            ),
            QuizQuestion(
                question: "What mineral is best known for supporting immune function and wound healing?",
                options: ["Calcium", "Zinc", "Iron", "Potassium"],
                correctAnswer: "Zinc",
                explanation: "Zinc plays a crucial role in immune cell function and the body's healing processes.",
                difficulty: selectedDifficulty ?? .easy
            ),
            QuizQuestion(
                question: "Which vitamin enhances the absorption of iron from plant-based foods?",
                options: ["Vitamin A", "Vitamin B12", "Vitamin C", "Vitamin K"],
                correctAnswer: "Vitamin C",
                explanation: "Vitamin C converts non-heme iron into a form that's easier for the body to absorb.",
                difficulty: selectedDifficulty ?? .medium
            ),
            QuizQuestion(
                question: "Vitamin K2 helps direct calcium to which part of the body?",
                options: ["Muscles", "Brain", "Bones", "Liver"],
                correctAnswer: "Bones",
                explanation: "Vitamin K2 activates proteins that help deposit calcium in bones and teeth.",
                difficulty: selectedDifficulty ?? .medium
            ),
            QuizQuestion(
                question: "What can high doses of Vitamin C cause?",
                options: ["Hair loss", "Digestive upset", "Vision problems", "Muscle weakness"],
                correctAnswer: "Digestive upset",
                explanation: "High doses of Vitamin C (>2000mg/day) may cause diarrhea or stomach discomfort.",
                difficulty: selectedDifficulty ?? .hard
            )
        ]
    }
    
    private func selectAnswer(_ answer: String, question: QuizQuestion) {
        state.selectedAnswer = answer
    }
    
    private func revealAnswer() {
        guard let question = currentQuestion, let selected = state.selectedAnswer else { return }
        
        state.isAnswerRevealed = true
        
        if selected == question.correctAnswer {
            state.correctCount += 1
            state.coinsEarned += question.difficulty.coinsReward
        } else {
            state.incorrectCount += 1
            shakeAnswer = true
        }
    }
    
    private func nextQuestion() {
        if state.currentQuestionIndex < questions.count - 1 {
            state.currentQuestionIndex += 1
            state.selectedAnswer = nil
            state.isAnswerRevealed = false
        } else {
            // Quiz completed - save results
            dataManager.saveQuizResult(
                totalQuestions: state.correctCount + state.incorrectCount,
                correctCount: state.correctCount,
                incorrectCount: state.incorrectCount,
                coinsEarned: state.coinsEarned,
                difficulty: selectedDifficulty?.rawValue
            )
            state.isCompleted = true
        }
    }
    
    private func previousQuestion() {
        if state.currentQuestionIndex > 0 {
            state.currentQuestionIndex -= 1
            state.selectedAnswer = nil
            state.isAnswerRevealed = false
        }
    }
    
    private func resetQuiz() {
        state.reset()
        selectedDifficulty = nil
        questions = []
    }
}

// MARK: - Quiz Option State
enum QuizOptionState {
    case normal, selected, correct, incorrect
}

// MARK: - Quiz Option Button
struct QuizOptionButton: View {
    let text: String
    let isSelected: Bool
    let state: QuizOptionState
    let action: () -> Void
    
    var backgroundColor: Color {
        switch state {
        case .normal: return Color.appCardBackground
        case .selected: return Color.appPrimary.opacity(0.15)
        case .correct: return Color.green.opacity(0.2)
        case .incorrect: return Color.red.opacity(0.2)
        }
    }
    
    var borderColor: Color {
        switch state {
        case .normal: return Color.clear
        case .selected: return Color.appPrimary
        case .correct: return Color.green
        case .incorrect: return Color.red
        }
    }
    
    var iconName: String? {
        switch state {
        case .correct: return "checkmark.circle.fill"
        case .incorrect: return "xmark.circle.fill"
        default: return nil
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let icon = iconName {
                    Image(systemName: icon)
                        .foregroundColor(state == .correct ? .green : .red)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quiz Result View
struct QuizResultView: View {
    let result: QuizResult
    let onRetake: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Result Icon
            ZStack {
                Circle()
                    .fill(result.percentage >= 70 ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                VStack {
                    Text("\(Int(result.percentage))%")
                        .font(.system(size: 36, weight: .bold))
                    Text(result.performanceLevel)
                        .font(.subheadline)
                }
            }
            
            // Stats
            VStack(spacing: 16) {
                HStack(spacing: 40) {
                    StatItem(value: "\(result.correct)", label: "Correct", color: .green)
                    StatItem(value: "\(result.incorrect)", label: "Incorrect", color: .red)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.yellow)
                    Text("Earned \(result.coinsEarned) coins!")
                        .font(.headline)
                }
                .padding()
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Button("Retake Quiz", action: onRetake)
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
        .padding()
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        QuizView()
    }
}
