//
//  ClipboardHistorySection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import SFSafeSymbols
import Defaults

struct ClipboardHistorySection: View {
    @Default(.historyPreservationPeriod) private var historyPreservationPeriod
    @Default(.historyPreservationTime) private var historyPreservationTime
    @Default(.timerInterval) private var timerInterval
    
    @State private var isDeleteHistoryAlertPresented = false
    @State private var isApplyPreservationTimeAlertPresented = false
    
    @State private var cachedPreservationPeriod: HistoryPreservationPeriod = .forever
    @State private var cachedPreservationTime: Double = 1
    
    @Environment(\.hasTitle) private var hasTitle
    
    var body: some View {
        Section {
            VStack {
                Picker("Preservation time", selection: $historyPreservationPeriod) {
                    ForEach(HistoryPreservationPeriod.allCases) { period in
                        period.withTime(Int(historyPreservationTime))
                    }
                }

                Slider(value: $historyPreservationTime, in: 1...30, step: 1) {
                    if !DefaultsStack.Group.historyPreservation.isUnchanged {
                        HStack {
                            Button {
                                applyCache()
                            } label: {
                                Image(systemSymbol: .clockArrowCirclepath)
                                Text("Restore")
                            }
                            .tint(.secondary)
                            
                            Button {
                                isApplyPreservationTimeAlertPresented = true
                            } label: {
                                Image(systemSymbol: .checkmarkCircleFill)
                                Text("Apply")
                            }
                            .tint(.accent)
                        }
                        .monospaced(false)
                        .buttonStyle(.borderless)
                    }
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("30")
                }
                .frame(height: 24)
                .monospaced()
                .disabled(historyPreservationPeriod == .forever && DefaultsStack.Group.historyPreservation.isUnchanged)
                .animation(.easeInOut, value: DefaultsStack.Group.historyPreservation.isUnchanged)
                
                .onAppear {
                    cache()
                }
                .alert("Apply Preservation Time", isPresented: $isApplyPreservationTimeAlertPresented) {
                    Button("Apply", role: .destructive) {
                        // TODO: Apply
                        cache()
                    }
                } message: {
                    Text("Applying a new preservation time clears all the outdated clipboard history except your pins.")
                }
            }
            
            VStack {
                HStack {
                    Text("Update interval")
                    Spacer()
                    Text("\(timerInterval, specifier: "%.2f")s")
                        .monospaced()
                }
                
                Slider(value: $timerInterval, in: 0.01...1) {
                    
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }
                .monospaced()
            }
        } header: {
            if hasTitle {
                Text("Clipboard History")
            }
        }
        
        Section {
            Button {
                isDeleteHistoryAlertPresented = true
            } label: {
                Text("Clear clipboard history")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .controlSize(.large)
            .alert("Clear Clipboard History", isPresented: $isDeleteHistoryAlertPresented) {
                Button("Delete", role: .destructive) {
                    // TODO: Delete
                }
            } message: {
                Text("This action clears all your clipboard history unrestorably, including pins.")
            }
            .padding(-5)
        }
        .foregroundStyle(.red)
    }
    
    private func cache() {
        cachedPreservationPeriod = historyPreservationPeriod
        cachedPreservationTime = historyPreservationTime
        
        DefaultsStack.shared.markDirty(.historyPreservation)
    }
    
    private func applyCache() {
        historyPreservationPeriod = cachedPreservationPeriod
        historyPreservationTime = cachedPreservationTime
    }
}

#Preview {
    previewSection {
        ClipboardHistorySection()
    }
}
