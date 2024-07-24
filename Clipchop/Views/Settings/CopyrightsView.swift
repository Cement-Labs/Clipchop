//
//  CopyrightsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/13.
//

import SwiftUI

var copyrights: String {
    .init(
        format: .init(localized: "Copyrights", defaultValue: "%@ Cement Labs"),
        appDevelopmentTime
    )
}

var appDevelopmentTime: String {
    let onStreamYear = Calendar.current.component(.year, from: onStreamTime)
    let currentYear = Calendar.current.component(.year, from: .now)
    
    if onStreamYear == currentYear {
        return String(onStreamYear)
    } else {
        return .init(
            format: .init(localized: "App Development Time", defaultValue: "%1$@-%2$@"),
            onStreamYear, currentYear
        )
    }
}

struct CopyrightsView: View {
    var body: some View {
        Label {
            Text(copyrights)
        } icon: {
            Image(systemSymbol: .cCircle)
        }
        .monospaced()
    }
}
