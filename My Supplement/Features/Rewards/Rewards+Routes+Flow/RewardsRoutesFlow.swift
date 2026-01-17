//
//  RewardsRoutesFlow.swift
//  My Supplement
//
//  Rewards feature navigation routes
//

import Foundation
import SwiftUI

enum RewardsFlow: NavigationDestination, Hashable {
    case rewardsHome
    case transactionHistory
    case achievements
    
    var title: String {
        switch self {
        case .rewardsHome:
            return "Rewards"
        case .transactionHistory:
            return "Transaction History"
        case .achievements:
            return "Achievements"
        }
    }
    
    var destinationView: some View {
        switch self {
        case .rewardsHome:
            RewardsView()
        case .transactionHistory:
            // Could create a dedicated view
            RewardsView()
        case .achievements:
            // Could create a dedicated view
            RewardsView()
        }
    }
}

typealias RewardsRouterFlow = Router<RewardsFlow>
