import Foundation

class UserService: ObservableObject {

    // Singleton instance
    static let shared = UserService()
    @Published var userData: [User] = []
    @Published var dataFlag: Bool = false
    
    init() {
        fetchRandomUsers()
    }
    
    // Function to fetch random users
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
            
            // Ensure data is not nil
            guard let data = data else {
                let error = NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                print("\(error)")
                return
            }
            
            // Decode the data
            do {
                let decoder = JSONDecoder()
                let userResponse = try decoder.decode(UserResponse.self, from: data)
                
                // Ensure UI updates are on the main thread
                DispatchQueue.main.async {
                    self.dataFlag = true
                    self.userData = userResponse.results
                }
                
            } catch {
                print("\(error)")
            }
        }
        task.resume()
    }
}

