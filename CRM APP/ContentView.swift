//
//  ContentView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingQuickAdd = false
    
    var body: some View {
        ZStack {
            TabView {
                DashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Dashboard")
                    }
                
                LeadsView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Prospects")
                    }
                
                PropertiesView()
                    .tabItem {
                        Image(systemName: "building.2.fill")
                        Text("Warehouses")
                    }
                
                DealsView()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Leases")
                    }
            }
            .environmentObject(dataManager)
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { 
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showingQuickAdd = true 
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100) // Above tab bar
                }
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddProspectView()
        }
    }
}

#Preview {
    ContentView()
}
