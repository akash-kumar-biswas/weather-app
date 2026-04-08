//
//  Weather_AppApp.swift
//  Weather-App
//
import SwiftUI
import Firebase

@main
struct Weather_AppApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
