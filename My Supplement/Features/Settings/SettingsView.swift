//
//  SettingsView.swift
//  My Supplement
//
//  App settings and profile
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = true
    @State private var dailyReminderTime = Date()
    @State private var selectedLanguage = "English"
    @State private var showLogoutAlert = false
    
    var body: some View {
        List {
            // Profile Section
            Section {
                ProfileRow()
            }
            
            // Notifications
            Section("Notifications") {
                Toggle("Daily Reminders", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $dailyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            
            // Preferences
            Section("Preferences") {
                Picker("Language", selection: $selectedLanguage) {
                    Text("English").tag("English")
                    Text("German").tag("German")
                    Text("Spanish").tag("Spanish")
                }
                
                NavigationLink {
                    LifeStageSettingsView()
                } label: {
                    HStack {
                        Text("Life Stage")
                        Spacer()
                        Text("Adult")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Data
            Section("Data") {
                NavigationLink {
                    Text("Supplement History")
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                
                NavigationLink {
                    Text("Quiz Attempts")
                } label: {
                    Label("Quiz History", systemImage: "list.clipboard")
                }
                
                Button {
                    // Export data
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
            }
            
            // About
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink {
                    Text("Privacy Policy")
                } label: {
                    Text("Privacy Policy")
                }
                
                NavigationLink {
                    Text("Terms of Service")
                } label: {
                    Text("Terms of Service")
                }
                
                Link(destination: URL(string: "mailto:support@supplementapp.com")!) {
                    HStack {
                        Text("Contact Support")
                        Spacer()
                        Image(systemName: "envelope")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Account
            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Log Out")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "uid")
        appState.isAuthenticated = false
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.appPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("User Name")
                    .font(.headline)
                Text("user@email.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            NavigationLink {
                EditProfileView()
            } label: {
                Text("Edit")
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Life Stage Settings
struct LifeStageSettingsView: View {
    @State private var selectedStage: LifeStage = .adult
    @State private var age: String = ""
    @State private var gender: Gender = .male
    
    var body: some View {
        Form {
            Section("Life Stage") {
                Picker("Stage", selection: $selectedStage) {
                    ForEach(LifeStage.allCases, id: \.self) { stage in
                        Text(stage.rawValue).tag(stage)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(selectedStage.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Demographics") {
                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { g in
                        Text(g.rawValue).tag(g)
                    }
                }
            }
            
            Section {
                Text("Your life stage affects recommended dosages for supplements. Our recommendations are tailored to your profile.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Life Stage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Edit Profile
struct EditProfileView: View {
    @State private var name = "User Name"
    @State private var email = "user@email.com"
    
    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }
            
            Section("Profile Photo") {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.2))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.appPrimary)
                    }
                    
                    Spacer()
                    
                    Button("Change Photo") {
                        // Photo picker
                    }
                }
            }
            
            Section {
                Button("Save Changes") {
                    // Save
                }
                .buttonStyle(PrimaryButtonStyle())
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
