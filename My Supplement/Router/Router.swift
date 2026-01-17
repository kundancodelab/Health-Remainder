//
//  Router.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation
import SwiftUI
import Combine


protocol NavigationDestination {
    associatedtype Destination:View
    var title:String { get }
    
    @ViewBuilder
    var destinationView:Destination { get }
}

enum RootFLow {
    case auth
    case home
}





final class Router<Destination:NavigationDestination>: ObservableObject {
    @Published var navPaths:[Destination] = []
    
    func navigate(_ destination:Destination) {
        navPaths.append(destination)
    }
    
    func navigateBack() {
        guard !navPaths.isEmpty else { return }
        navPaths.removeLast()
    }
    
    func navigateToRoot() {
        navPaths.removeLast(navPaths.count)
    }
    
}
