//
//  HomeRoutesFlow.swift
//  My Supplement
//
//  Home feature navigation routes
//

import Foundation
import SwiftUI

enum HomeFlow: NavigationDestination, Hashable {
    case supplementDetail(Supplement)
    case supplementList
    case allSupplements
    
    var title: String {
        switch self {
        case .supplementDetail(let supplement):
            return supplement.name
        case .supplementList:
            return "Supplements"
        case .allSupplements:
            return "All Supplements"
        }
    }
    
    var destinationView: some View {
        switch self {
        case .supplementDetail(let supplement):
            SupplementDetailView(supplement: supplement)
        case .supplementList:
            SupplementListView()
        case .allSupplements:
            SupplementListView()
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        switch self {
        case .supplementDetail(let supplement):
            hasher.combine("supplementDetail")
            hasher.combine(supplement.id)
        case .supplementList:
            hasher.combine("supplementList")
        case .allSupplements:
            hasher.combine("allSupplements")
        }
    }
    
    static func == (lhs: HomeFlow, rhs: HomeFlow) -> Bool {
        switch (lhs, rhs) {
        case (.supplementDetail(let l), .supplementDetail(let r)):
            return l.id == r.id
        case (.supplementList, .supplementList):
            return true
        case (.allSupplements, .allSupplements):
            return true
        default:
            return false
        }
    }
}

typealias HomeRouterFlow = Router<HomeFlow>
