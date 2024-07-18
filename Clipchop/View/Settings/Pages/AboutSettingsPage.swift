//
//  AboutSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI
import SFSafeSymbols

struct AboutSettingsPage: View {
    @State private var isSourcePresented = false
    @State private var isAcknowledgementsPresented = false
    
    var body: some View {
        GeometryReader { geometryProxy in
            ListEmbeddedForm(formStyle: .columns) {
                HStack {
                    Spacer()
                    
                    Image(nsImage: AppIcon.currentAppIcon.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(Bundle.main.appName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            AppVersionView()
                            CopyrightsView()
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(height: geometryProxy.size.height - geometryProxy.safeAreaInsets.top)
            }
        }
        .scrollDisabled(true)
        .toolbar {
            // Place them to the left of the quit button
            ToolbarItemGroup(placement: .cancellationAction) {
                
                Button {
                    isSourcePresented = true
                } label: {
                    Group {
                        Image(systemSymbol: .curlybraces)
                        Text("GPL-3.0")
                    }
                    .imageScale(.small)
                    .padding(2)
                }
                .popover(isPresented: $isSourcePresented, arrowEdge: .bottom) {
                    VStack {
                        Text("\(Bundle.main.appName) is open source.")
                            .foregroundStyle(.placeholder)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemSymbol: .curlybraces)
                                    .frame(width: 16)
                                
                                Button {
                                    
                                } label: {
                                    Text("Source Code")
                                    
                                    Image(systemSymbol: .arrowUpRight)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            HStack {
                                Image(systemSymbol: .docText)
                                    .frame(width: 16)
                                
                                Button {
                                    
                                } label: {
                                    Text("Licenced Under GPL-3.0")
                                    
                                    Image(systemSymbol: .arrowUpRight)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .imageScale(.small)
                        .buttonStyle(.accessoryBar)
                    }
                    .padding()
                }
                
                Button {
                    isAcknowledgementsPresented = true
                } label: {
                    Group {
                        Image(systemSymbol: .aqiMedium)
                        Text("Acknowledgements")
                    }
                    .imageScale(.small)
                    .padding(2)
                }
                .popover(isPresented: $isAcknowledgementsPresented, arrowEdge: .bottom) {
                    AcknowledgementsView()
                }
            }
        }
    }
}

#Preview {
    previewPage {
        AboutSettingsPage()
    }
}
