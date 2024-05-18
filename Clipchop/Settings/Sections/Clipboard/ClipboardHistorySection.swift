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
    
    @ViewBuilder
    func periodWithTime(_ time: Int, period: HistoryPreservationPeriod) -> some View {
        switch period {
        case .forever: Text("Forever")
        case .minute:
            Text("\(time) Minute")
        case .hour:
            Text("\(time) Hour")
        case .day:
            Text("\(time) Day")
        case .month:
            Text("\(time) Month")
        case .year:
            Text("\(time) Year")
        }
    }
    
    var body: some View {
        Section("Clipboard History") {
            VStack {
                Picker("Preservation time", selection: $historyPreservationPeriod) {
                    ForEach(HistoryPreservationPeriod.allCases) { period in
                        periodWithTime(Int(historyPreservationTime), period: period)
                    }
                }
                
                Slider(value: $historyPreservationTime, in: 1...30, step: 1) {
                    
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("30")
                }
                .monospaced()
                .disabled(historyPreservationPeriod == .forever)
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
                Text("This window clears all your clipboard history unrestorably, including pins.")
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
