import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var userData: UserData
    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack
        {
            Spacer()
            
            TextField("Username", text: $username)// .pretty()
            TextField("E-mail", text: $email)
            SecureField("Password", text: $password)
            Button("Sign Up", action: {
                userData.signUp(username: username, email: email, password: password)
            })
            
            Spacer()
            Button("Already have an account? Log in ", action: {
                userData.setAuthToLogin()
            })
        }.padding()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
