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
    @State private var showNewLead = false
    @State private var showNewProperty = false
    @State private var showNewDeal = false
    @State private var showQuickAddDialog = false
    @AppStorage("defaultQuickAdd") private var defaultQuickAdd = "Property"
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            TabView {
                DashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("Dashboard")
                    }
                
                LeadsView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("Prospects")
                    }
                
                PropertiesView()
                    .tabItem {
                        Image(systemName: "building.2.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("Warehouses")
                    }
                
                DealsView()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                            .symbolRenderingMode(.hierarchical)
                        Text("Leases")
                    }
            }
            .environmentObject(dataManager)
            .tint(.accentColor)
            
            // Global Quick Add Button
            if !anySheetIsPresented && keyboardHeight == 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        QuickAddButton(
                            onTap: handleQuickAddTap,
                            onLongPress: { showQuickAddDialog = true }
                        )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddProspectView()
        }
        .sheet(isPresented: $showNewLead) {
            AddEditLeadView(lead: nil)
        }
        .sheet(isPresented: $showNewProperty) {
            AddEditPropertyView(property: nil)
        }
        .sheet(isPresented: $showNewDeal) {
            AddEditDealView(deal: nil)
        }
        .confirmationDialog("Quick Add", isPresented: $showQuickAddDialog) {
            Button("New Prospect") {
                showNewLead = true
            }
            Button("New Warehouse") {
                showNewProperty = true
            }
            Button("New Lease") {
                showNewDeal = true
            }
            Button("Set Default") {
                // Opens submenu
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose what to add")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
    
    // MARK: - Computed Properties
    private var anySheetIsPresented: Bool {
        showingQuickAdd || showNewLead || showNewProperty || showNewDeal || showQuickAddDialog
    }
    
    // MARK: - Quick Add Helpers
    private func handleQuickAddTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        switch defaultQuickAdd {
        case "Lead":
            showNewLead = true
        case "Property":
            showNewProperty = true
        case "Deal":
            showNewDeal = true
        default:
            showNewProperty = true
        }
    }
}

// MARK: - Quick Add Button
private struct QuickAddButton: View {
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .contentShape(Circle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onLongPress()
                }
        )
        .accessibilityLabel("Quick Add")
        .accessibilityHint("Tap to add new item, long press for options")
    }
}

#Preview {
    ContentView()
}
