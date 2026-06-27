import SwiftUI
import AuthenticationServices

/// Real Supabase sign-in: email/password (sign in or create account), Sign in
/// with Apple, Google, and "Explore without signing in".
struct SignInScreen: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.colorScheme) private var colorScheme

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var notice: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    brand
                    form
                    Button("Explore without signing in") {
                        auth.continueAsGuest()
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var brand: some View {
        VStack(spacing: 8) {
            Image(systemName: "bolt.circle.fill")
                .resizable().scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(Color.accentColor)
            Text("ECEUH").font(.largeTitle.weight(.bold)).foregroundStyle(Color.accentColor)
            Text("ECE Coursework Archive")
                .font(.caption.weight(.semibold)).textCase(.uppercase).kerning(0.7)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 32)
    }

    private var form: some View {
        VStack(spacing: 12) {
            TextField("Institutional Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let notice {
                Text(notice).font(.footnote).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let error = auth.errorMessage {
                Text(error).font(.footnote).foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task { await submit() }
            } label: {
                if auth.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text(isSignUp ? "Create Account" : "Sign In").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.isEmpty || password.isEmpty || auth.isLoading)

            Button(isSignUp ? "Have an account? Sign in" : "New here? Create an account") {
                isSignUp.toggle()
                notice = nil
            }
            .font(.footnote)

            labeledDivider("Or continue with")

            SignInWithAppleButton(.continue) { request in
                auth.prepareAppleRequest(request)
            } onCompletion: { result in
                Task { await auth.completeAppleSignIn(result) }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 48)
            .clipShape(Capsule())

            Button {
                Task { await auth.signInWithGoogle() }
            } label: {
                Label("Continue with Google", systemImage: "globe").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private func submit() async {
        notice = isSignUp
            ? await auth.signUp(email: email, password: password)
            : await auth.signIn(email: email, password: password)
    }

    private func labeledDivider(_ text: String) -> some View {
        HStack {
            VStack { Divider() }
            Text(text)
                .font(.caption2.weight(.semibold)).textCase(.uppercase)
                .foregroundStyle(.secondary).fixedSize()
            VStack { Divider() }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SignInScreen().environment(AuthService())
}
