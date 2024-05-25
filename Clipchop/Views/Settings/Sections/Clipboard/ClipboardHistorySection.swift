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
    @State var preservationPeriod: HistoryPreservationPeriod = .forever
    @State var preservationTime: Double = 1
    
    @Environment(\.hasTitle) var hasTitle
    
    var isDefaultsIdentical: Bool {
        DefaultsStack.Group.historyPreservation.isIdentical(comparedTo: [
            preservationPeriod, preservationTime
        ])
    }
    
    @ViewBuilder
    func periodWithTime(_ time: Int, period: HistoryPreservationPeriod) -> some View {
        switch period {
        case .forever: Text("Forever")
        case .minute:
            Text("\(time) Minutes")
        case .hour:
            Text("\(time) Hours")
        case .day:
            Text("\(time) Days")
        case .month:
            Text("\(time) Months")
        case .year:
            Text("\(time) Years")
        }
    }
    
    var body: some View {
        Section {
            VStack {
                Picker("Preservation time", selection: $preservationPeriod) {
                    ForEach(HistoryPreservationPeriod.allCases) { period in
                        periodWithTime(Int(preservationTime), period: period)
                    }
                }
                
                Slider(value: $preservationTime, in: 1...30, step: 1) {
                    if !isDefaultsIdentical {
                        HStack {
                            Button {
                                
                            } label: {
                                Image(systemSymbol: .clockArrowCirclepath)
                                Text("Restore")
                            }
                            
                            Button {
                                
                            } label: {
                                Image(systemSymbol: .checkmark)
                                Text("Apply")
                            }
                        }
                        .monospaced(false)
                    }
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("30")
                }
                .monospaced()
                .disabled(preservationPeriod == .forever)
            }
            .onAppear {
                preservationPeriod = historyPreservationPeriod
                preservationTime = historyPreservationTime
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
