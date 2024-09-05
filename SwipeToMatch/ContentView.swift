
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
                            cardState: $cardStates[index]
                        )
                        .padding(8)
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

//    func saveLikedUser(_ user: User) {
//        let context = PersistenceController.shared.container.viewContext
//        let profile = SaveUserData(context: context)
//        profile.name = user.name.first + " " + user.name.last
//        profile.email = user.email
//        profile.city = user.location.city
//        profile.isAccepted = true
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save user: \(error.localizedDescription)")
//        }
//    }

}

struct CardView: View {
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])
    let user: User
    @Binding var cardState: CardState
    
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
                
                HStack(alignment: .center) {
                    Spacer()
                    Button(action: {
                       print("dismiss selected")
                        handleButtonPress(.rejected)
                    }) {
                        Image("dismiss")
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button(action: {
                        print("accepted selected")

                        handleButtonPress(.accepted)
                    }) {
                        Image("like")
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(.bottom, 20)
                .opacity(cardState.action == .none ? 1 : 0) // Hide buttons after selection
                
                if cardState.action == .accepted {
                    Text("Accepted")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 350, height: 60, alignment: .center)
                        .background(.green)
                        .padding(.bottom, 15)
                } else if cardState.action == .rejected {
                    Text("Rejected")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 350, height: 60, alignment: .center)
                        .background(.red) // Optional background for visibility
                        .padding(.bottom, 15)
                }
            }
        }
        .frame(width: 380, height: 450)
        .cornerRadius(8)
        .offset(x: cardState.xCoordinate, y: cardState.yCoordinate)
        .rotationEffect(.init(degrees: cardState.degree))
    }
    
    func handleButtonPress(_ action: CardAction) {
        guard cardState.action == .none else { return } // Ensure only one action happens
        cardState.action = action
    }
}

struct CardState {
    var xCoordinate: CGFloat = 0
    var yCoordinate: CGFloat = 0
    var degree: CGFloat = 0
    var action: CardAction = .none // Add a default action
}

enum CardAction {
    case none, accepted, rejected
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
