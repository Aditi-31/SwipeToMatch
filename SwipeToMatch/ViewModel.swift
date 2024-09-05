
import Foundation
import Combine
import CoreData

class UserService: ObservableObject {

    // Singleton instance
    static let shared = UserService()
    @Published var userData: [User] = []
    @Published var dataFlag: Bool = false
    
    private let persistenceController = PersistenceController.shared
    private var context: NSManagedObjectContext {
        return persistenceController.container.viewContext
    }
    
    init() {
        // try fetching data from Core Data
        fetchUsersFromCoreData()
        
        // If no data in Core Data, fetch from network
        if userData.isEmpty {
            fetchRandomUsers()
        }
    }
  
    // Fetch users from Core Data
    func fetchUsersFromCoreData() {
        let fetchRequest: NSFetchRequest<SaveUserData> = SaveUserData.fetchRequest()
        
        do {
            let savedUsers = try context.fetch(fetchRequest)
          //   Convert SaveUserData objects to User objects
            self.userData = savedUsers.map { savedUser in
                User(gender: "", name: Name(title: "", first: savedUser.name ?? "", last: ""), location: Location(street: Street(number: 0, name: ""), city: savedUser.city ?? "", state: "", country: "", postcode: Postcode.empty, coordinates: Coordinates(latitude: "", longitude: ""), timezone: Timezone(offset: "", description: "")), email: savedUser.email ?? "", login: Login(uuid: "", username: "", password: "", salt: "", md5: "", sha1: "", sha256: ""), dob: DOB(date: "", age: Int(savedUser.age ?? "") ?? 0), registered: Registered(date: "", age: 0), phone: "", cell: "", id: ID(name: "", value: ""), picture: Picture(large: savedUser.image ?? "", medium: "", thumbnail: ""), nat: "")
            }
            
            if !self.userData.isEmpty {
                self.dataFlag = true
            }
            
        } catch {
            print("Failed to fetch users from Core Data: \(error)")
        }
    }
    
    // Function to fetch random users from network
    func fetchRandomUsers() {
        // Define the URL
        guard let url = URL(string: "https://randomuser.me/api/?results=10") else {
            print("Invalid URL")
            return
        }

        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("\(error)")
                return
            }
                guard let data = data else {
                let error = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                print("\(error)")
                return
            }
            do {
                let decoder = JSONDecoder()
                let userResponse = try decoder.decode(UserResponse.self, from: data)
                
                // Ensure UI updates are on the main thread
                DispatchQueue.main.async {
                    self.dataFlag = true
                    self.userData = userResponse.results
                    
                    // Save fetched users to Core Data
                    self.saveUsersToCoreData(users: userResponse.results)
                }
                
            } catch {
                print("\(error)")
            }
        }
        task.resume()
    }
    
    // Save users to Core Data
    func saveUsersToCoreData(users: [User]) {
        // Remove old data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SaveUserData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete old users: \(error)")
        }

        // Save new data
        for user in users {
            let savedUser = SaveUserData(context: context)
            savedUser.name = (user.name.first + user.name.last)
            savedUser.email = user.email
            savedUser.city = user.location.city
            savedUser.age = "\(user.dob.age)"
            savedUser.image = user.picture.large
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save users to Core Data: \(error)")
        }
    }
}
