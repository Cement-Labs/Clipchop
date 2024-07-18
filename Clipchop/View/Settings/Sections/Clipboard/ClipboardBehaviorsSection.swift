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
    @Default(.autoCloseTimeout) private var autoCloseTimeout
    @Default(.clipboardMonitoring) private var clipboardMonitoring
    
    @State private var isDeleteHistoryAlertPresented = false
    @State private var isApplyPreservationTimeAlertPresented = false
    @State private var showPopover = false
    
    @State private var initialPreservationPeriod: HistoryPreservationPeriod = .day
    @State private var initialPreservationTime: Double = 1
    
    @Environment(\.hasTitle) private var hasTitle
    @ObservedObject private var clipboardModelManager = ClipboardModelManager()
    @ObservedObject var clipboardController: ClipboardController
    
    private let clipboardModelEditor = ClipboardModelEditor(provider: .shared)
    
    var body: some View {
        Section {
            withCaption("Enable or disable monitoring of your clipboard history.") {
                HStack {
                    Text("Clipboard Monitoring")
                    Button(action: {
                        self.showPopover.toggle()
                    }) {
                        Image(systemSymbol: .infoCircle)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showPopover, arrowEdge: .top) {
                        VStack {
                            Text("When enabled, this feature allows \(Bundle.main.appName) to track changes in the system clipboard, offering clipboard history")
                                .font(.body)
                        }
                        .frame(width: 200, height: 100)
                        .padding()
                    }
                    Spacer()
                    Toggle("", isOn: $clipboardController.started)
                }
            }
            withCaption("When enabled, strips all font formatting from pasted text.") {
                Toggle("Remove format", isOn: $removeFormatting)
            }
            withCaption("When enabled, directly paste the selected item into the application you are currently using") {
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
                                restoreInitialValues()
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
                        cacheCurrentValues()
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
                
                Slider(value: $timerInterval, in: 0.25...1) {
                    
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }
                .monospaced()
            }
            VStack {
                HStack {
                    Text("Auto Close Timeout")
                    Spacer()
                    Text("\(Int(autoCloseTimeout))s")
                        .monospaced()
                }
                Slider(value: $autoCloseTimeout, in: 5...60) {
                    
                } minimumValueLabel: {
                    Text("5")
                } maximumValueLabel: {
                    Text("60")
                }
                .monospaced()
            }
        }
        
        Section {
            Button {
                isDeleteHistoryAlertPresented = true
            } label: {
                Text("Clear Clipboard History")
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
        .onAppear {
            cacheInitialValues()
        }
    }
    
    private func cacheInitialValues() {
        initialPreservationPeriod = historyPreservationPeriod
        initialPreservationTime = historyPreservationTime
    }
    
    private func cacheCurrentValues() {
        clipboardModelManager.restartPeriodicCleanup()
        DefaultsStack.shared.markDirty(.historyPreservation)
    }
    
    private func restoreInitialValues() {
        historyPreservationPeriod = initialPreservationPeriod
        historyPreservationTime = initialPreservationTime
    }
}
