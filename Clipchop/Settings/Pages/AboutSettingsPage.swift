//
//  AboutSettingsPage.swift
//  Clipchop
//
//  Created by KrLite on 2024/4/27.
//

import SwiftUI

struct AboutSettingsPage: View {
    @State var isSourcePresented = false
    @State var isAcknowledgementsPresented = false
    
    var body: some View {
        HStack {
            Spacer()
            
            Image(nsImage: Icon.currentAppIcon.image)
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
        .padding()
        .toolbar {
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

#Preview {
    AboutSettingsPage()
}
