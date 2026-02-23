//
//  ContentView.swift
//  ShortKit
//
//  Created by 심재빈 on 11/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var beaconManager = BeaconManager.shared

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // App Title
                        Text("ShortKit")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 12)
                        
                        // Beacon Automation Entry
                        NavigationLink {
                            BeaconAutomationView(beaconManager: beaconManager)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .font(.system(size: 28))
                                    Spacer()
                                }
                                
                                Text("비콘 자동화 만들기")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("거리 기반 조건으로 단축어·URL 자동 실행")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
//                        NavigationLink {
////                            BeaconAutomationView(beaconManager: beaconManager)
//                        } label: {
//                            VStack(alignment: .leading, spacing: 10) {
//                                
//                                HStack {
//                                    Image(systemName: "dot.radiowaves.left.and.right")
//                                        .font(.system(size: 28))
//                                    Spacer()
//                                }
//                                
//                                Text("IoT 서버 만들기")
//                                    .font(.title3)
//                                    .fontWeight(.semibold)
//                                
//                                Text("IoT 서버 구축 및 설정")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(
//                                RoundedRectangle(cornerRadius: 18)
//                                    .fill(Color(.secondarySystemBackground))
//                            )
//                        }
//                        NavigationLink {
////                            BeaconAutomationView(beaconManager: beaconManager)
//                        } label: {
//                            VStack(alignment: .leading, spacing: 10) {
//                                
//                                HStack {
//                                    Image(systemName: "dot.radiowaves.left.and.right")
//                                        .font(.system(size: 28))
//                                    Spacer()
//                                }
//                                
//                                Text("Siri 단축어 만들기")
//                                    .font(.title3)
//                                    .fontWeight(.semibold)
//                                
//                                Text("IoT 장비 제어 가능한 Siri 단축어 만들기")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(
//                                RoundedRectangle(cornerRadius: 18)
//                                    .fill(Color(.secondarySystemBackground))
//                            )
//                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("ShortKit")
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
