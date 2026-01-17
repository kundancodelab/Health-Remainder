//
//  Supplement.swift
//  My Supplement
//
//  Core supplement data model for SwiftUI
//

import Foundation

// MARK: - Supplement Model
struct Supplement: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var description: String
    var dosage: String
    var benefits: [String]
    var specialNotes: String
    var synergies: [String]
    var incompatibleWith: [String]
    var sideEffects: [String]
    var foodSources: [String]
    var foodImages: [[String]]
    
    // Tracking properties
    var isFavorite: Bool = false
    var isTaken: Bool = false
    
    // Timing properties
    var isMorning: Bool = false
    var isMidday: Bool = false
    var isEvening: Bool = false
    var mealTiming: String = "with_meal"
    
    // Dosage by demographics
    var maxDosageMale: Int = 0
    var maxDosageFemale: Int = 0
    var maxDosageTeenager: Int = 0
    var maxDosageChild: Int = 0
    var unit: String = "mg"
    
    // Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, dosage, benefits
        case specialNotes, synergies, incompatibleWith, sideEffects
        case foodSources, foodImages
        case isMorning, isMidday, isEvening
        case mealTiming = "meal_timing"
        case maxDosageMale = "max_dosage_male"
        case maxDosageFemale = "max_dosage_female"
        case maxDosageTeenager = "max_dosage_teenager"
        case maxDosageChild = "max_dosage_child"
        case unit
    }
    
    // Category based on supplement type
    var category: SupplementCategory {
        let name = self.name.lowercased()
        if name.contains("vitamin") {
            return .vitamin
        } else if ["zinc", "magnesium", "iron", "calcium", "selenium"].contains(where: { name.contains($0) }) {
            return .mineral
        } else if ["triphala", "mumijo", "shilajit"].contains(where: { name.contains($0) }) {
            return .herbal
        } else {
            return .specialty
        }
    }
    
    // Get timing display string
    var timingDisplay: String {
        var times: [String] = []
        if isMorning { times.append("Morning") }
        if isMidday { times.append("Midday") }
        if isEvening { times.append("Evening") }
        return times.isEmpty ? "Anytime" : times.joined(separator: ", ")
    }
    
    // Get meal timing display
    var mealTimingDisplay: String {
        switch mealTiming {
        case "before_meal": return "Before meal"
        case "after_meal": return "After meal"
        case "with_meal": return "With meal"
        case "empty_stomach": return "Empty stomach"
        default: return "With meal"
        }
    }
}

// MARK: - Supplement Category
enum SupplementCategory: String, CaseIterable {
    case vitamin = "Vitamins"
    case mineral = "Minerals"
    case herbal = "Herbal"
    case specialty = "Specialty"
    
    var icon: String {
        switch self {
        case .vitamin: return "sun.max.fill"
        case .mineral: return "diamond.fill"
        case .herbal: return "leaf.fill"
        case .specialty: return "sparkles"
        }
    }
    
    var color: String {
        switch self {
        case .vitamin: return "FF6B6B"
        case .mineral: return "4ECDC4"
        case .herbal: return "95E1D3"
        case .specialty: return "DDA0DD"
        }
    }
}

// MARK: - Food Image
struct FoodImage: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var imageName: String
    var foodName: String
    
    init(from array: [String]) {
        self.imageName = array.first ?? ""
        self.foodName = array.count > 1 ? array[1] : ""
    }
}

// MARK: - Date Specific Supplement
struct DateSpecificSupplement: Identifiable, Codable {
    var id: String = UUID().uuidString
    var supplementId: String
    var date: Date
    var isFavorite: Bool
    var isTaken: Bool
    var userId: String?
    var coins: Int?
}

// MARK: - Supplement History
struct SupplementHistory: Identifiable, Codable {
    var id: String = UUID().uuidString
    var supplementId: String
    var date: Date
    var isTaken: Bool
    var userId: String?
    var coinsAwarded: Int = 0
}
