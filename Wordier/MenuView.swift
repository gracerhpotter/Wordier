//
//  ContentView.swift
//  WordFinder
//
//  Created by Grace Potter on 10/14/24.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack {
                // App title
                Text("My App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                // Graphic (use any image from your assets)
                Image(systemName: "gamecontroller.fill") // Replace with your image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.vertical, 50)
                
                Text("High Score")
                    .font(.title)
                Text("Timed")
                    .font(.title3)
                Text("Untimed")
                    .font(.title3)
                Spacer()
                
                // Start Button (Navigates to NewView)
                NavigationLink(destination: RoundView()) {
                    Text("Timed")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
                
                // Start Button (Navigates to NewView)
                NavigationLink(destination: RoundView()) {
                    Text("Untimed")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)

                // Info Link
                Button(action: {
                    print("Info link pressed!")
                }) {
                    Text("Info")
                        .font(.body)
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
