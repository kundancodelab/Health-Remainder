//
//  HistoryViews.swift
//  My Supplement
//
//  History views for supplements and quizzes
//

import SwiftUI
import SwiftData

// MARK: - Supplement History View
struct SupplementHistoryView: View {
    @State private var records: [DailyRecord] = []
    private var dataManager: DataManager { DataManager.shared }
    
    var body: some View {
        List {
            if records.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your supplement history will appear here")
                )
            } else {
                ForEach(groupedRecords.keys.sorted().reversed(), id: \.self) { date in
                    Section(header: Text(dateFormatter.string(from: date))) {
                        ForEach(groupedRecords[date] ?? []) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.supplementName)
                                        .font(.subheadline.weight(.medium))
                                    if let takenAt = record.takenAt {
                                        Text("Taken at \(timeFormatter.string(from: takenAt))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if record.isTaken {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("+\(record.coinsAwarded)")
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .onAppear {
            loadRecords()
        }
    }
    
    private var groupedRecords: [Date: [DailyRecord]] {
        Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private func loadRecords() {
        // Load last 30 days of records
        let calendar = Calendar.current
        for dayOffset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let dayRecords = dataManager.getDailyRecords(for: date)
                records.append(contentsOf: dayRecords.filter { $0.isTaken })
            }
        }
    }
}

// MARK: - Quiz History View
struct QuizHistoryView: View {
    @State private var quizHistory: [QuizHistoryRecord] = []
    private var dataManager: DataManager { DataManager.shared }
    
    var body: some View {
        List {
            if quizHistory.isEmpty {
                ContentUnavailableView(
                    "No Quiz History",
                    systemImage: "list.clipboard",
                    description: Text("Complete quizzes to see your history")
                )
            } else {
                ForEach(quizHistory) { record in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(dateFormatter.string(from: record.attemptDate))
                                .font(.subheadline.weight(.medium))
                            
                            Spacer()
                            
                            if let difficulty = record.difficulty {
                                Text(difficulty)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(difficultyColor(difficulty))
                                    .cornerRadius(8)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Label("\(record.correctCount)/\(record.totalQuestions)", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Label(String(format: "%.0f%%", record.percentage), systemImage: "percent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("+\(record.coinsEarned)")
                                    .font(.caption.weight(.bold))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Quiz History")
        .onAppear {
            quizHistory = dataManager.getQuizHistory(limit: 50)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .gray
        }
    }
}

#Preview("Supplement History") {
    NavigationStack {
        SupplementHistoryView()
    }
}

#Preview("Quiz History") {
    NavigationStack {
        QuizHistoryView()
    }
}
