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
    @State private var cardStates: [CardState] = []
    
    var body: some View {
        VStack {
            if !viewModel.dataFlag {
                ProgressView("Loading users...") // Loading indicator while data is fetched
            } else {
                // Top Stack
                HStack {
                    Button(action: {}) {
                        Image("profile")
                    }
                    Spacer()
                    Button(action: {}) {
                        Image("appIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 45)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image("chats")
                    }
                }
                .padding(.horizontal)
                
                // List View of Cards
                List(Array(viewModel.userData.enumerated()), id: \.offset) { index, user in
                    if index < cardStates.count {
                        CardView(
                            user: user,
                            cardState: $cardStates[index],
                            onRemove: { removeUser(at: index) }
                        )
                        .padding(8)
                    }
                }
                
                // Bottom Stack
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Image("refresh")
                    }
                    Button(action: {
                        if !cardStates.isEmpty {
                            withAnimation(Animation.easeIn(duration: 0.8)) {
                                let index = 0 // Assuming you want to affect the first card
                                cardStates[index].xCoordinate = -500
                                cardStates[index].degree = -12
                                removeUser(at: index)
                            }
                        }
                    }) {
                        Image("dismiss")
                    }
                    Button(action: {}) {
                        Image("super_like")
                    }
                    Button(action: {
                        if !cardStates.isEmpty {
                            let index = 0 // Assuming you want to affect the first card
                            let likedUser = viewModel.userData[index]
                            saveLikedUser(likedUser)
                            withAnimation(Animation.easeIn(duration: 0.8)) {
                                cardStates[index].xCoordinate = 500
                                cardStates[index].degree = 12
                                removeUser(at: index)
                            }
                        }
                    }) {
                        Image("like")
                    }
                    Button(action: {}) {
                        Image("boost")
                    }
                }
            }
        }
        .onAppear {
            if viewModel.dataFlag {
                initializeCardState()
            }
        }
        .onChange(of: viewModel.userData) { newUserData in
            if !newUserData.isEmpty {
                initializeCardState()
            }
        }
    }
    
    func initializeCardState() {
        cardStates = Array(repeating: CardState(), count: viewModel.userData.count)
    }
    
    func removeUser(at index: Int) {
        if index < viewModel.userData.count {
            viewModel.userData.remove(at: index)
            cardStates.remove(at: index)
        }
    }
    
    func saveLikedUser(_ user: User) {
        var likedUsers = getLikedUsers()
        likedUsers.append(user)
        
        if let encoded = try? JSONEncoder().encode(likedUsers) {
            UserDefaults.standard.set(encoded, forKey: "LikedUsers")
        }
    }
    
    func getLikedUsers() -> [User] {
        if let data = UserDefaults.standard.data(forKey: "LikedUsers"),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            return users
        }
        return []
    }
}

struct CardState {
    var xCoordinate: CGFloat = 0
    var yCoordinate: CGFloat = 0
    var degree: CGFloat = 0
}

struct CardView: View {
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    let user: User
    @Binding var cardState: CardState
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            var imageUrl: String = user.picture.large
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.gray)
            
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 380, height: 450)
                .clipped()
            
            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)
            
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(user.name.first) \(user.name.last)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(user.dob.age)")
                            .font(.title)
                    }
                    Text(user.email)
                    Text(user.location.city)
                    Text(user.cell)
                }
                .padding()
                .foregroundColor(.white)
            }
        }
        .cornerRadius(8)
        .offset(x: cardState.xCoordinate, y: cardState.yCoordinate)
        .rotationEffect(.init(degrees: cardState.degree))

    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
