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
    @State private var activeCardIndex: Int? = nil
    @State private var cardStates: [CardState] = []
    @State private var i: Int = 0
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
                    if index < cardStates.count {
                        CardView(
                            user: viewModel.userData[index],
                            activeCardIndex: $activeCardIndex,
                            cardIndex: index,
                            cardState: $cardStates[index]
                        )
                        .padding(8)
                    }
                }
            }
            .zIndex(1.0)
            
            // Bottom Stack
            HStack(spacing: 0) {
                Button(action: {}) {
                    Image("refresh")
                }
                Button(action: {
                    if let index = activeCardIndex {
                        withAnimation(Animation.easeIn(duration: 0.8)) {
                            cardStates[index].xCoordinate = -500
                            cardStates[index].degree = -12
                            i = i - 1
                        }
                    }
                    
                }) {
                    Image("dismiss")
                }
                Button(action: {}) {
                    Image("super_like")
                }
                Button(action: {
                    if i >= 0 {
                        let likedUser = viewModel.userData[i]
                        saveLikedUser(likedUser)
                        withAnimation(Animation.easeIn(duration: 0.8)) {
                            cardStates[i].xCoordinate = 500
                            cardStates[i].degree = 12
                            i -= 1
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
        .onAppear {
            initializeCardState()
        }
        .onChange(of: viewModel.userData) { _ in
            initializeCardState()
        }
    }
    
    func initializeCardState() {
        cardStates = Array(repeating: CardState(), count: viewModel.userData.count)
        i = viewModel.userData.count - 1
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
    @Binding var activeCardIndex: Int?
    let cardIndex: Int
    @Binding var cardState: CardState
    
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
        }
        .cornerRadius(8)
        .offset(x: cardState.xCoordinate, y: cardState.yCoordinate)
        .rotationEffect(.init(degrees: cardState.degree))
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.default) {
                        cardState.xCoordinate = value.translation.width
                        cardState.yCoordinate = value.translation.height
                        cardState.degree = 7 * (value.translation.width > 0 ? 1 : -1)
                        activeCardIndex = cardIndex
                    }
                }
                .onEnded { value in
                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                        switch value.translation.width {
                        case 0...100:
                            cardState.xCoordinate = 0
                            cardState.yCoordinate = 0
                            cardState.degree = 0
                        case let x where x > 100:
                            cardState.xCoordinate = 500
                            cardState.degree = 12
                        case (-100)...(-1):
                            cardState.xCoordinate = -500
                            cardState.degree = -12
                        case let x where x < -100:
                            cardState.xCoordinate = -500
                            cardState.degree = -12
                        default:
                            cardState.xCoordinate = 0
                            cardState.yCoordinate = 0
                        }
                        activeCardIndex = nil
                    }
                }
        )
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
