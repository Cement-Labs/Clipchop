//
//  ClipboardHistorySection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import Defaults

struct ClipboardHistorySection: View {
    @Default(.historyPreservationPeriod) var historyPreservationPeriod
    @Default(.historyPreservationTime) var historyPreservationTime
    @Default(.timerInterval) var timerInterval
    
    @State var isDeleteHistoryAlertPresented = false
    @State var isApplyPreservationTimeAlertPresented = false
    
    @State var cachedPreservationPeriod: HistoryPreservationPeriod = .forever
    @State var cachedPreservationTime: Double = 1
    
    @Environment(\.hasTitle) var hasTitle
    
    func cache() {
        cachedPreservationPeriod = historyPreservationPeriod
        cachedPreservationTime = historyPreservationTime
        
        DefaultsStack.shared.markDirty(.historyPreservation)
    }
    
    func applyCache() {
        historyPreservationPeriod = cachedPreservationPeriod
        historyPreservationTime = cachedPreservationTime
    }
    
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
                .animation(.default, value: DefaultsStack.Group.historyPreservation.isUnchanged)
                
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
                        .contentTransition(.numericText(value: Double(timerInterval)))
                        .animation(.snappy(duration: 0.5), value: timerInterval)
                        .monospaced()
                }
                
                Slider(value: $timerInterval, in: 0.01...1) {
                    
                } minimumValueLabel: {
                    Text("0.01")
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
}

#Preview {
    previewSection {
        ClipboardHistorySection()
    }
}
