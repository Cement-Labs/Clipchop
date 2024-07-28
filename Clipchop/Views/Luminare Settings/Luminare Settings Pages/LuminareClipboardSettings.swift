//
//  LuminareClipboardSettings.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/27.
//

import SwiftUI
import Luminare
import Defaults
import KeyboardShortcuts

struct LuminareClipboardSettings: View {
    
    @Default(.historyPreservationPeriod) private var historyPreservationPeriod
    @Default(.historyPreservationTime) private var historyPreservationTime
    @Default(.timerInterval) private var timerInterval
    @Default(.pasteToFrontmostEnabled) private var paste
    @Default(.removeFormatting) private var removeFormatting
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
        LuminareSection("Keyboard Shortcuts") {
            HStack {
                withCaption {
                    Text("Show \(Bundle.main.appName)")
                } caption: {
                    Text("Call up the clip history window.")
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 42)
                
                Spacer()
                
                KeyboardShortcuts.Recorder(for: .window) { }
                    .padding(.horizontal, 8)
                    .padding(.trailing, 2)
                    .frame(minHeight: 42)
                    .controlSize(.large)
            }
            
            HStack {
                withCaption {
                    Text("Clipboard Monitoring")
                } caption: {
                    Text("Enable or disable monitoring of your clipboard history.")
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 42)
                
                Spacer()
                
                KeyboardShortcuts.Recorder(for: .start) { }
                    .padding(.horizontal, 8)
                    .padding(.trailing, 2)
                    .frame(minHeight: 42)
                    .controlSize(.large)
                
            }
        }
        LuminareSection("Clipboard Behaviors") {
            HStack {
                withCaption {
                    HStack(spacing: 0) {
                        Text("Clipboard Monitoring")
                        LuminareInfoView("When enabled, this feature allows \(Bundle.main.appName) to track changes in the system clipboard, offering clipboard history", .orange)
                    }
                    .fixedSize()
                } caption: {
                    Text("""
        Enable or disable monitoring of your clipboard history.
        """)
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 42)
                
                Spacer()
                
                Toggle("", isOn: $clipboardController.started)
                    .labelsHidden()
                    .controlSize(.small)
                    .toggleStyle(.switch)
                    .padding(.horizontal, 8)
                    .padding(.trailing, 2)
                    .frame(minHeight: 42)
            }
            
            HStack {
                withCaption {
                    Text("Remove format")
                } caption: {
                    Text("""
    When enabled, strips all font formatting from pasted text.
    """)
                }
                Spacer()
                Toggle("", isOn: $removeFormatting)
                    .labelsHidden()
                    .controlSize(.small)
                    .toggleStyle(.switch)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 42)
            
            HStack {
                withCaption {
                    Text("Paste to active application")
                } caption: {
                    Text("""
    When enabled, directly paste the selected item into the application you are currently using.
    """)
                }
                Spacer()
                Toggle("", isOn: $paste)
                    .labelsHidden()
                    .controlSize(.small)
                    .toggleStyle(.switch)
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 58)
        }
        
        LuminareSection {
            VStack {
                HStack {
                    Text("Preservation time")
                    
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
                    
                    Spacer()
                    
                    CustomLuminarePicker(
                        selection: $historyPreservationPeriod,
                        items: HistoryPreservationPeriod.allCases
                    ) { period in
                        periodDisplayText(for: period, with: Int(historyPreservationTime))
                    }
                    .frame(width: 80, height: 24, alignment: .trailing)
                }
                
                Slider(value: $historyPreservationTime, in: 1...30, step: 1)
                
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
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 70)
            
            VStack {
                LuminareValueAdjuster(
                    "Update interval",
                    value: $timerInterval,
                    sliderRange: 0.25...1,
                    suffix: "s",
                    step: 0.25,
                    lowerClamp: true
                )
            }
        }
        
        LuminareSection {
            Button {
                isDeleteHistoryAlertPresented = true
            } label: {
                Text("Clear Clipboard History")
            }
            .padding(.horizontal, 8)
            .padding(.trailing, 2)
            .frame(minHeight: 34)
            .buttonStyle(.plain)
            .controlSize(.large)
            .alert("Clear Clipboard History", isPresented: $isDeleteHistoryAlertPresented) {
                Button("Delete", role: .destructive) {
                    try? clipboardModelEditor.deleteAll()
                    MetadataCache.shared.clearAllCaches()
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
    
    func periodDisplayText(for period: HistoryPreservationPeriod, with time: Int) -> String {
        switch period {
        case .forever:
            return String.localizedStringWithFormat(NSLocalizedString("Forever", comment: "Forever"))
        case .minute:
            return String.localizedStringWithFormat(NSLocalizedString("%d Minutes", comment: "Minutes"), time)
        case .hour:
            return String.localizedStringWithFormat(NSLocalizedString("%d Hours", comment: "Hours"), time)
        case .day:
            return String.localizedStringWithFormat(NSLocalizedString("%d Days", comment: "Days"), time)
        case .month:
            return String.localizedStringWithFormat(NSLocalizedString("%d Months", comment: "Months"), time)
        case .year:
            return String.localizedStringWithFormat(NSLocalizedString("%d Years", comment: "Years"), time)
        }
    }
}
