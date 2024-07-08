//
//  ClipboardBehaviorsSection.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI
import SFSafeSymbols
import Defaults

struct ClipboardBehaviorsSection: View {
    @Default(.historyPreservationPeriod) private var historyPreservationPeriod
    @Default(.historyPreservationTime) private var historyPreservationTime
    @Default(.timerInterval) private var timerInterval
    @Default(.pasteToFrontmostEnabled) private var paste
    @Default(.removeFormatting) private var removeFormatting
    
    @State private var isDeleteHistoryAlertPresented = false
    @State private var isApplyPreservationTimeAlertPresented = false
    
    @State private var cachedPreservationPeriod: HistoryPreservationPeriod = .day
    @State private var cachedPreservationTime: Double = 1
    
    @Environment(\.hasTitle) private var hasTitle
    @ObservedObject private var clipboardModelManager = ClipboardModelManager()
    
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    var body: some View {
        Section {
            withCaption("When enabled, All font formats will be removed.") {
                Toggle("Remove format", isOn: $removeFormatting)
                
            }
            withCaption("When enabled, will automatically paste into the frontmost application.") {
                Toggle("Paste to active application", isOn: $paste)
                
            }
        } header: {
            if hasTitle {
                Text("Clipboard Behaviors")
            }
        }
        
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
                    try? clipboardModelEditor.deleteAll()
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
        clipboardModelManager.restartPeriodicCleanup()
        DefaultsStack.shared.markDirty(.historyPreservation)
    }
    
    private func applyCache() {
        historyPreservationPeriod = cachedPreservationPeriod
        historyPreservationTime = cachedPreservationTime
    }
}

#Preview {
    previewSection {
        ClipboardBehaviorsSection()
    }
}
