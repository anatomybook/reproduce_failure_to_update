import SwiftUI

// import Combine
import Amplify

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    func fetch_id()
    {
        let buyerZ = BuyerZ(remarks: "Some remark", name: "Buyers name")
        userData.createBuyer(buyer: buyerZ)
    }
    
    var body: some View {
        Group
        {
           switch userData.auth_state
           {
           case .sign_up:
               SignUpView()
           case .confirm_code(let username):
               ConfirmationView(username: username)
           case .session(let user):
        NavigationView
            {
                Form {
                    SessionView(user: user)
                    
                    Section(header: Text("aws stuff")){
                        Button(action: {
                            self.userData.clearDataStore()
                        }) {
                            Text("clear DataStore")
                        }
                    }
                    
                    Section(header: Text("buyer details")){
                        Text("ID: \(self.userData.buyer?.id ?? "N/A")")
                        Text("Name: \(self.userData.buyer?.name ?? "N/A")")
                        Text("Remarks: \(self.userData.buyer?.remarks ?? "N/A")")
                    }
                    
                    Section(header: Text("buyer stuff")){
                        Button(action: {
                            self.userData.loadBuyer()
                        }) {
                            Text("load buyer into user data")
                        }
                        
                        Button(action: {
                            self.userData.buyer = nil
                            print("Buyer object set to nil")
                        }) {
                            Text("set buyer object to nil")
                        }
                        
                        Button(action: fetch_id) {
                            HStack{
                                Image(systemName: "signature")
                                Text("create buyer")
                            }
                        }
                        
                        Button(action: {
                            if let current_buyer = self.userData.buyer
                            {
                                var edited_buyer = current_buyer
                                edited_buyer.name = "Updated name"
                                edited_buyer.remarks = "Updated remarks"
                                self.userData.updateBuyer(buyer: edited_buyer)
                            }
                            else
                            {
                                print("Don't have a buyer to update")
                            }
                        })
                        {
                            Text("update buyer")
                        }
                        
                        Button(action: {
                            if let current_buyer = self.userData.buyer
                            {
                                self.userData.updateBuyerRemarks(buyer: current_buyer, remarks: "Just remarks")
                            }
                            else
                            {
                                print("Don't have a buyer to update remarks")
                            }
                        })
                        {
                            Text("update buyer remarks")
                        }
                        
                        Button(action: {
                            if let current_buyer = self.userData.buyer
                            {
                                self.userData.deleteBuyer(buyer: current_buyer)
                            }
                            else
                            {
                                print("Don't have a buyer to update")
                            }
                        })
                        {
                            Text("delete buyer")
                        }
                        
                        Button(action: {
                            print("Refreshing buyer")
                            self.userData.refreshBuyer()
                        })
                        {
                            Text("refresh buyer")
                        }
                    }
                    
                }.navigationBarTitle(Text("AWS Tester"))
        }
           default:
               LoginView()
           }
        }
    }
}

