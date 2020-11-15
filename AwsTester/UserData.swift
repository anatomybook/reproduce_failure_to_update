import SwiftUI
import Combine
import Amplify

final class UserData : ObservableObject
{
    // MARK: Auth stuff
   
    enum AuthState
    {
        case sign_up
        case login
        case confirm_code(username: String)
        case session(user: AuthUser)
    }
    
    @Published var auth_state: AuthState = .login
    
    func loadCurrentAuthUser()
    {
        if let user = Amplify.Auth.getCurrentUser()
        {
            auth_state = .session(user: user)
        }
        else
        {
            auth_state = .login
        }
    }
    
    func setAuthToSignUp()
    {
        auth_state = .sign_up
    }
    
    func setAuthToLogin()
    {
        auth_state = .login
    }
    
    func signUp(username: String, email: String, password: String)
    {
        let attributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        
        _ = Amplify.Auth.signUp(username: username, password: password, options: options)
        {
            [weak self] result in
            switch result
            {
            case .success(let sign_up_result):
                print("Sign up result success: \(sign_up_result)")
                print("Complete: \(sign_up_result.isSignupComplete)")
                switch sign_up_result.nextStep
                {
                case .done:
                    print("Finished signing up")
                case .confirmUser(let details, _):
                    print(details ?? "no details")
                    DispatchQueue.main.async
                    {
                        self?.auth_state = .confirm_code(username: username)
                    }
                }
            case .failure(let error):
                print("Sign up failures: \(error)")
            }
        }
    }
    
    func confirmSignUp(username: String, code: String)
    {
        _ = Amplify.Auth.confirmSignUp(for: username, confirmationCode: code)
        {
            [weak self] result in
            switch result
            {
            case .success(let confirmation_result):
                print("Confirmation result: \(confirmation_result)")
                if confirmation_result.isSignupComplete
                {
                    DispatchQueue.main.async
                    {
                        self?.setAuthToLogin()
                    }
                }
            case .failure(let error):
                print("Failed to confirm code: \(error)")
            }
        }
    }
    
    func login(username: String, password: String)
    {
        _ = Amplify.Auth.signIn(username: username, password: password)
        {
            [weak self]
            result in
            switch result
            {
            case .success(let sign_in_result):
                print(sign_in_result)
                if sign_in_result.isSignedIn
                {
                    DispatchQueue.main.async
                    {
                        self?.loadCurrentAuthUser()
                    }
                }
            case .failure(let error):
                print("Login error:", error)
            }
        }
    }
    
    func signOut()
    {
        _ = Amplify.Auth.signOut
        {
            [weak self]
            result in
            switch result
            {
            case .success:
                DispatchQueue.main.async {
                    self?.buyer = nil
                    self?.loadCurrentAuthUser()
                }
            case .failure(let error):
                print("Cant sign out:", error)
            }
        }
    }
    
    // MARK: DataStore stuff
    @Published var buyer : BuyerZ?
    
    private var subBuyerZ : AnyCancellable?
    
    func updateBuyer(buyer : BuyerZ)
    {
        print("Updating Buyer id: \(buyer.id)")
        Amplify.DataStore.query(BuyerZ.self, byId: buyer.id)
        {
            switch $0 {
            case .success(let result):
                if result != nil
                {
                    Amplify.DataStore.save(buyer)
                    {
                        switch $0 {
                        case .success:
                            print("Saved update of buyer \(buyer.name ?? "NONAME")")
                        case .failure(let error):
                            print("Error saving update of group - \(error.localizedDescription)")
                        }
                    }
                }
                else
                {
                    print("\(#function) Got a request to update an unknown ID (\(buyer.id)) -> bad!")
                }
            case .failure(let error):
                print("Error listing group - \(error.localizedDescription)")
            }
        }
    }
    
    func updateBuyerRemarks(buyer : BuyerZ, remarks : String)
    {
        print("Updating Buyer id: \(buyer.id)")
        Amplify.DataStore.query(BuyerZ.self, byId: buyer.id)
        {
            switch $0 {
            case .success(let result):
                if var update_me = result
                {
                    update_me.remarks = remarks
                    Amplify.DataStore.save(update_me)
                    {
                        switch $0 {
                        case .success:
                            print("Saved update of update_me \(update_me.name ?? "NONAME")")
                        case .failure(let error):
                            print("Error saving update of group - \(error.localizedDescription)")
                        }
                    }
                }
                else
                {
                    print("\(#function) Got a request to update an unknown ID (\(buyer.id)) -> bad!")
                }
            case .failure(let error):
                print("Error listing group - \(error.localizedDescription)")
            }
        }
    }
    
    func deleteBuyer(buyer : BuyerZ)
    {
        print("Deleting Buyer id: \(buyer.id)")
        Amplify.DataStore.delete(buyer)
        {
            switch $0 {
            case .success:
                print("Deleted buyer")
            case .failure(let error):
                print("Error deleting buyer - \(error.localizedDescription)")
            }
        }
        //Amplify.DataStore.delete(GroupZ.self, withId: group.id)
    }
 
    func loadBuyer()
    {
        Amplify.DataStore.query(BuyerZ.self)
        {
            switch $0 {
            case .success(let result):
                if result.count > 1
                {
                    print("This is bad, I've more than one buyer")
                    for (ndx, buyer) in result.enumerated()
                    {
                        print("Buyer #\(ndx) has ID \(buyer.id)")
                    }
                }
                if let result = result.first
                {
                    print("Buyer ID is \(result.id)")
                    self.buyer = result
                }
                else
                {
                    print("Ohh no, I found no buyer")
                }
            case .failure(let error):
                print("Error listing buyer - \(error.localizedDescription)")
            }
        }
    }
    
    func clearDataStore()
    {
        Amplify.DataStore.clear()
        {
            switch $0 {
            case .success:
                print("clear successful")
            case .failure(let error):
                print("Error clearing - \(error.localizedDescription)")
            }
        }
    }
    
    private func triggerBuyerRefresh()
    {
        guard let buyerId = buyer?.id else
        {
            print("I cant refresh, since I have no buyer")
            return
        }
        Amplify.DataStore.query(BuyerZ.self, byId: buyerId)
        {
            switch $0 {
            case .success(let result):
                if let result = result
                {
                    print("Buyer ID is \(result.id), finished refresh!!!, main thread \(Thread.isMainThread)")
                    self.buyer = result
                    print("Buyer object was written to!")
                }
            case .failure(let error):
                print("Error listing buyer - \(error.localizedDescription)")
            }
        }
    }
    
    func refreshBuyer()
    {
        print("Triggering buyer refresh, provided it has been scheduled")
        DispatchQueue.main.async {
            print("Buyer needs a refresh ... executing")
            self.triggerBuyerRefresh()
        }
    }
    
    // MARK: functions to be called from GUI
    
    
    func createBuyer(buyer : BuyerZ)
    {
        print("Buyer id is \(buyer.id), creating")
        
        Amplify.DataStore.save(buyer)
        {
            switch $0 {
            case .success:
                print("Added buyer")
                self.buyer = buyer
            case .failure(let error):
                print("Error adding buyer - \(error.localizedDescription)")
            }
        }
    }

    private func onReceiveBuyerMutationEvent(mutationEvent : MutationEvent)
    {
        if buyer == nil {
            print("I have no buyer, hence I don't care about events")
            return
        }
        
        DispatchQueue.main.async {
            print("Trigger GUI stuff")
        }
    }
    
    init() {
        // subscribe()
    }
    
    func unsubscribeAll()
    {
        unsubscribeBuyerZ()
    }
    
    private func unsubscribeBuyerZ()
    {
        subBuyerZ?.cancel()
        subBuyerZ = nil
    }
    
    private func subscribeBuyerZ()
    {
        if subBuyerZ == nil
        {
            print("subBuyerZ is null, renewing...")
            let pubBuyerZ = Amplify.DataStore.publisher(for: BuyerZ.self)
            subBuyerZ = pubBuyerZ.sink(receiveCompletion: {
                print("Received BuyerZ completion: \($0)")
            }, receiveValue: {
                pVal in
                if Thread.isMainThread { return }
                print("Received BuyerZ \(pVal.mutationType) \(pVal.modelId), main thread \(Thread.isMainThread)")
                self.onReceiveBuyerMutationEvent(mutationEvent: pVal)
            })
        }
        else
        {
            print("subBuyerZ subscription in place...")
        }
    }
    
}

