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
    
    var body: some View {
        Section("Clipboard History") {
            VStack {
                Picker("Preservation time", selection: $historyPreservationPeriod) {
                    ForEach(HistoryPreservationPeriod.allCases) { period in
                        let time = Int(historyPreservationTime)
                        
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
                }
                
                Slider(value: $historyPreservationTime, in: 1...30, step: 1)
                    .disabled(historyPreservationPeriod == .forever)
            }
        }
    }
}

#Preview {
    Form {
        ClipboardHistorySection()
    }
    .formStyle(.grouped)
}
