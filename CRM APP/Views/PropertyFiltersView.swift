//
//  PropertyFiltersView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct PropertyFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var sizeFilter: PropertiesView.SizeRange
    @Binding var clearHeightFilter: PropertiesView.ClearHeightRange
    @Binding var railAccessOnly: Bool
    @Binding var sortBy: PropertiesView.PropertySort
    
    var body: some View {
        NavigationView {
            Form {
                Section("Size Range") {
                    Picker("Size", selection: $sizeFilter) {
                        ForEach(PropertiesView.SizeRange.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section("Clear Height") {
                    Picker("Height", selection: $clearHeightFilter) {
                        ForEach(PropertiesView.ClearHeightRange.allCases, id: \.self) { height in
                            Text(height.rawValue).tag(height)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Features") {
                    Toggle("Rail Access Only", isOn: $railAccessOnly)
                }
                
                Section("Sort By") {
                    Picker("Sort", selection: $sortBy) {
                        ForEach(PropertiesView.PropertySort.allCases, id: \.self) { sort in
                            Text(sort.rawValue).tag(sort)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section {
                    Button("Reset All Filters") {
                        sizeFilter = .all
                        clearHeightFilter = .all
                        railAccessOnly = false
                        sortBy = .dateAdded
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filter Warehouses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PropertyFiltersView(
        sizeFilter: .constant(.all),
        clearHeightFilter: .constant(.all),
        railAccessOnly: .constant(false),
        sortBy: .constant(.dateAdded)
    )
}
