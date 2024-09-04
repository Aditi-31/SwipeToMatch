//
//  ContentView.swift
//  SwipeToMatch
//
//  Created by Aditi Jain on 03/09/24.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI
struct ContentView: View {
    @ObservedObject var viewModel = UserService()
    @State private var xCoordinate: CGFloat = 0
    @State private var yCoordinate: CGFloat = 0
    var body: some View {
        VStack {
            // Top Stack
            HStack {
                Button(action: {}) {
                    Image("profile")
                }
                Spacer()
                Button(action: {}) {
                    Image("appIcon")
                        .resizable().aspectRatio(contentMode: .fit).frame(height: 45)
                }
                Spacer()
                Button(action: {}) {
                    Image("chats")
                }
            }.padding(.horizontal)
            
            // Image Card View
            ZStack {
                ForEach(viewModel.userData.indices, id: \.self) { index in
                    CardView(user: viewModel.userData[index])
                        .padding(8)
                }
            }
            .zIndex(1.0)
            
            // Bottom Stack
            HStack(spacing: 0) {
                Button(action: {}) {
                    Image("refresh")
                }
                Button(action: {
                    withAnimation(Animation.easeIn(duration: 0.8)){
                        
                    }
                }) {
                    Image("dismiss")
                }
                Button(action: {}) {
                    Image("super_like")
                }
                Button(action: {
                    
                }) {
                    Image("like")
                }
                Button(action: {}) {
                    Image("boost")
                }
            }
        }
    }
    

    
    enum SwipeDirection {
        case left, right
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

struct CardView: View {
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    let user: User


    @State private var xCoordinate: CGFloat = 0
    @State private var yCoordinate: CGFloat = 0
    @State private var degree: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topLeading) {
            var imageUrl: String = user.picture.large
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.gray)
            
            // Actual image
            WebImage(url: URL(string: imageUrl))
                .resizable()
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(user.name.first) \(user.name.last)").font(.largeTitle).fontWeight(.bold)
                        Text("\(user.dob.age)").font(.title)
                    }
                    Text(user.email)
                    Text(user.location.city)
                    Text(user.cell)
                }
            }
            .padding()
            .foregroundColor(.white)
            
            HStack {
                Image("yes")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .opacity(Double(xCoordinate / 10 - 1))
                Spacer()
                Image("nope")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .opacity(Double((xCoordinate / 10 * -1) - 1))
            }
        }
        .cornerRadius(8)
        .offset(x: xCoordinate, y: yCoordinate)
        .rotationEffect(.init(degrees: degree))
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.default) {
                        xCoordinate = value.translation.width
                        yCoordinate = value.translation.height
                        degree = 7 * (value.translation.width > 0 ? 1 : -1)
                    }
                }
                .onEnded { value in
                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                        switch value.translation.width {
                        case 0...100:
                            xCoordinate = 0
                            yCoordinate = 0
                            degree = 0
                        case let x where x > 100:
                            xCoordinate = 500
                            degree = 12
                        case (-100)...(-1):
                            xCoordinate = 0
                            yCoordinate = 0
                            degree = 0
                        case let x where x < -100:
                            xCoordinate = -500
                            degree = -12
                        default:
                            xCoordinate = 0
                            yCoordinate = 0
                        }
                    }
                }
        )
        
    }
}
