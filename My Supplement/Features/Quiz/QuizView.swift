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
                emptyState
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadQuestions()
        }
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
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No quiz questions available")
                .font(.headline)
            Button("Reload") {
                loadQuestions()
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    private func loadQuestions() {
        // Sample questions
        questions = [
            QuizQuestion(
                question: "Which vitamin is primarily synthesized in the skin through sun exposure?",
                options: ["Vitamin A", "Vitamin C", "Vitamin D", "Vitamin E"],
                correctAnswer: "Vitamin D",
                explanation: "Vitamin D is synthesized when UVB rays from sunlight interact with cholesterol in skin cells.",
                difficulty: .easy
            ),
            QuizQuestion(
                question: "What mineral is best known for supporting immune function and wound healing?",
                options: ["Calcium", "Zinc", "Iron", "Potassium"],
                correctAnswer: "Zinc",
                explanation: "Zinc plays a crucial role in immune cell function and the body's healing processes.",
                difficulty: .easy
            ),
            QuizQuestion(
                question: "Which vitamin enhances the absorption of iron from plant-based foods?",
                options: ["Vitamin A", "Vitamin B12", "Vitamin C", "Vitamin K"],
                correctAnswer: "Vitamin C",
                explanation: "Vitamin C converts non-heme iron into a form that's easier for the body to absorb.",
                difficulty: .medium
            ),
            QuizQuestion(
                question: "Vitamin K2 helps direct calcium to which part of the body?",
                options: ["Muscles", "Brain", "Bones", "Liver"],
                correctAnswer: "Bones",
                explanation: "Vitamin K2 activates proteins that help deposit calcium in bones and teeth.",
                difficulty: .medium
            ),
            QuizQuestion(
                question: "What can high doses of Vitamin C cause?",
                options: ["Hair loss", "Digestive upset", "Vision problems", "Muscle weakness"],
                correctAnswer: "Digestive upset",
                explanation: "High doses of Vitamin C (>2000mg/day) may cause diarrhea or stomach discomfort.",
                difficulty: .hard
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
        loadQuestions()
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
