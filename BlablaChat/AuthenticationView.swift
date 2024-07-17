//
//  AuthenticationView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/04/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

struct GoggleSignInResultModel {
    let idToken: String
    let accessToken: String
}

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}


@MainActor
final class AuthenticationViewModel: NSObject, ObservableObject {
    
    private var currentNonce: String?
    @Published var didSignInWithApple: Bool = false
    
    func signInGoogle() async throws {
        
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoggleSignInResultModel.init(idToken: idToken, accessToken: accessToken)

        // Recherche du user Google dans la base "users" avec son email
        do {
            let authUser = try await AuthManager.shared.signInWithGoogle(tokens: tokens) // Renvoi user: authDataResult.user
            guard let email = authUser.email else {
                print("L'email du user Google est égal à nil")
                return
            }
             let contact_id  = try await ContactsManager.shared.searchContact(email: email)
             if contact_id == "" {
                let user = DBUser(auth: authUser) // Instanciation userId email
                try await UserManager.shared.createDbUser(user: user) // Save in Firestore sans l'image
             }
        } catch {
            print("Erreur Sign in with Google...")
        }
    }
    
    func signInApple() async throws {
        startSignInWithAppleFlow()
    }
    
    func startSignInWithAppleFlow() {
      
        guard let topVC = Utilities.shared.topViewController() else {
            return
        }
        
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = topVC
      authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

}

struct SignInWithAppleResult {
    let token: String
    let nonce: String
}

@available(iOS 13.0, *)
extension AuthenticationViewModel: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      
    guard 
        let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
        let appleIDToken = appleIDCredential.identityToken,
        let idTokenString = String(data: appleIDToken, encoding: .utf8),
        let nonce = currentNonce else {
            print("Error")
            return
        }
      
      let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)

      Task {
          do {
              try await AuthManager.shared.signInWithApple(tokens: tokens)
              didSignInWithApple = true
          } catch {
                
          }
      }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            NavigationLink {
                LoginEmailView(showSignInView: $showSignInView)
            } label: {
                Text("S'authentifié avec l'email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal))
            {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        // showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
            .frame(height: 55)
            .onChange(of: viewModel.didSignInWithApple) { newValue in
                if newValue == true {
                    showSignInView = false
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
