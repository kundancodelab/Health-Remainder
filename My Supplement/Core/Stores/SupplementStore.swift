//
//  SupplementStore.swift
//  My Supplement
//
//  Data store for supplements with JSON loading
//

import Foundation

@MainActor
@Observable
class SupplementStore {
    var supplements: [Supplement] = []
    var dateSpecificData: [String: DateSpecificSupplement] = [:]
    var isLoading = false
    var error: Error?
    
    init() {
        loadSupplements()
    }
    
    // MARK: - Load from JSON
    func loadSupplements() {
        isLoading = true
        
        // Load from bundled JSON file
        if let url = Bundle.main.url(forResource: "SupplementInfo", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let loaded = try decoder.decode([SupplementJSON].self, from: data)
                self.supplements = loaded.map { $0.toSupplement() }
                print("✅ Loaded \(supplements.count) supplements from JSON")
            } catch {
                print("❌ Error loading supplements: \(error)")
                self.error = error
                // Load sample data as fallback
                loadSampleData()
            }
        } else {
            print("⚠️ SupplementInfo.json not found, using sample data")
            loadSampleData()
        }
        
        isLoading = false
    }
    
    // MARK: - Sample Data
    func loadSampleData() {
        supplements = [
            Supplement(
                id: "vitamin_c",
                name: "Vitamin C",
                description: "Vitamin C (ascorbic acid) is a powerful water-soluble antioxidant that supports immune function, collagen synthesis, and iron absorption.",
                dosage: "500-1000mg daily",
                benefits: ["Immune support", "Antioxidant", "Collagen production", "Iron absorption"],
                specialNotes: "Not stored in body, regular intake needed",
                synergies: ["Iron", "Zinc", "Collagen"],
                incompatibleWith: ["High alcohol intake"],
                sideEffects: ["High doses may cause digestive upset"],
                foodSources: ["Citrus fruits", "Bell peppers", "Kiwi", "Broccoli"],
                foodImages: [["vitc_1", "Oranges"], ["vitc_2", "Lemons"]],
                isMorning: true,
                mealTiming: "with_meal"
            ),
            Supplement(
                id: "vitamin_d",
                name: "Vitamin D",
                description: "Vitamin D is essential for calcium absorption, bone health, immune function, and mood regulation.",
                dosage: "1000-4000 IU daily",
                benefits: ["Bone health", "Immune support", "Mood regulation", "Muscle strength"],
                specialNotes: "Best taken with fat-containing meal",
                synergies: ["Magnesium", "Vitamin K2", "Calcium"],
                incompatibleWith: ["High doses of Vitamin A"],
                sideEffects: ["Toxicity at extremely high doses"],
                foodSources: ["Fatty fish", "Egg yolks", "Fortified milk", "Mushrooms"],
                foodImages: [["vitd_1", "Salmon"], ["vitd_2", "Eggs"]],
                isMorning: true,
                mealTiming: "with_meal"
            ),
            Supplement(
                id: "magnesium",
                name: "Magnesium",
                description: "Magnesium is involved in over 300 biochemical reactions including muscle and nerve function, energy production, and bone health.",
                dosage: "200-400mg daily",
                benefits: ["Muscle relaxation", "Sleep quality", "Stress relief", "Energy production"],
                specialNotes: "Some forms may cause loose stools",
                synergies: ["Vitamin D", "Calcium", "Vitamin B6"],
                incompatibleWith: ["Excess calcium or zinc"],
                sideEffects: ["High doses can cause diarrhea"],
                foodSources: ["Leafy greens", "Nuts", "Dark chocolate", "Legumes"],
                foodImages: [["mag1", "Spinach"], ["mag2", "Almonds"]],
                isEvening: true,
                mealTiming: "with_meal"
            ),
            Supplement(
                id: "zinc",
                name: "Zinc",
                description: "Zinc is vital for immune function, wound healing, hormone regulation, and skin health.",
                dosage: "15-30mg daily",
                benefits: ["Immune boost", "Wound healing", "Skin health", "Taste & smell"],
                specialNotes: "Best absorbed on empty stomach but may cause nausea",
                synergies: ["Vitamin C", "Quercetin", "Magnesium"],
                incompatibleWith: ["Iron", "Calcium", "Coffee"],
                sideEffects: ["High doses may cause nausea"],
                foodSources: ["Red meat", "Shellfish", "Pumpkin seeds", "Legumes"],
                foodImages: [["zin1", "Beef"], ["zin2", "Oysters"]],
                isMorning: true,
                mealTiming: "with_meal"
            ),
            Supplement(
                id: "vitamin_b12",
                name: "Vitamin B12",
                description: "Essential for red blood cell formation, nervous system function, and energy production.",
                dosage: "500-1000mcg daily",
                benefits: ["Energy", "Nerve health", "Red blood cells", "Mental clarity"],
                specialNotes: "Vegans must supplement",
                synergies: ["Folate", "Vitamin B6", "Iron"],
                incompatibleWith: ["Alcohol", "Metformin"],
                sideEffects: ["Usually very safe, excess excreted"],
                foodSources: ["Liver", "Fish", "Eggs", "Dairy"],
                foodImages: [["vitb12_1", "Salmon"], ["vitb12_2", "Eggs"]],
                isMorning: true,
                mealTiming: "with_meal"
            )
        ]
    }
    
    // MARK: - Filtering
    func supplements(for category: SupplementCategory) -> [Supplement] {
        supplements.filter { $0.category == category }
    }
    
    func supplements(for date: Date) -> [Supplement] {
        let dateKey = dateKey(for: date)
        return supplements.filter { supplement in
            if let specific = dateSpecificData["\(supplement.id)_\(dateKey)"] {
                return specific.isFavorite
            }
            return supplement.isFavorite
        }
    }
    
    func search(_ query: String) -> [Supplement] {
        guard !query.isEmpty else { return supplements }
        let lowercased = query.lowercased()
        return supplements.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.description.lowercased().contains(lowercased) ||
            $0.benefits.contains { $0.lowercased().contains(lowercased) }
        }
    }
    
    // MARK: - Actions
    func toggleFavorite(_ supplementId: String, for date: Date) {
        let dateKey = dateKey(for: date)
        let key = "\(supplementId)_\(dateKey)"
        
        if var existing = dateSpecificData[key] {
            existing.isFavorite.toggle()
            dateSpecificData[key] = existing
        } else {
            dateSpecificData[key] = DateSpecificSupplement(
                supplementId: supplementId,
                date: date,
                isFavorite: true,
                isTaken: false
            )
        }
    }
    
    func markAsTaken(_ supplementId: String, for date: Date) {
        let dateKey = dateKey(for: date)
        let key = "\(supplementId)_\(dateKey)"
        
        if var existing = dateSpecificData[key] {
            existing.isTaken = true
            dateSpecificData[key] = existing
        } else {
            dateSpecificData[key] = DateSpecificSupplement(
                supplementId: supplementId,
                date: date,
                isFavorite: true,
                isTaken: true
            )
        }
    }
    
    func isTaken(_ supplementId: String, for date: Date) -> Bool {
        let key = "\(supplementId)_\(dateKey(for: date))"
        return dateSpecificData[key]?.isTaken ?? false
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - JSON Parsing Helper
struct SupplementJSON: Codable {
    let id: String
    let favorite: Bool
    let name: String
    let description: String
    let benefits: [String]
    let specialNotes: String
    let synergies: [String]
    let incompatibleWith: [String]
    let sideEffects: [String]
    let foodSources: [String]
    let foodImages: [[String]]
    
    func toSupplement() -> Supplement {
        Supplement(
            id: id,
            name: name,
            description: description,
            dosage: "",
            benefits: benefits,
            specialNotes: specialNotes,
            synergies: synergies,
            incompatibleWith: incompatibleWith,
            sideEffects: sideEffects,
            foodSources: foodSources,
            foodImages: foodImages,
            isFavorite: favorite
        )
    }
}
