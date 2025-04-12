//
//  ContentView.swift
//  BreakReminder
//
//  Created by Muhammad Haseeb on 12/04/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var reminder: BreakReminder
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye")
                .imageScale(.large)
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            
            Text("Break Reminder")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Remember to rest your eyes every \(Int(reminder.interval / 60)) minutes")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    ContentView()
        .environmentObject(BreakReminder.shared)
}
