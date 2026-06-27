import SwiftUI

/// Sign-in. Phase 4 is a mock that lands in the app (all paths). Phase 6 replaces
/// the actions with real Supabase auth (email/password, Sign in with Apple,
/// Google) and the "Explore without signing in" guest path.
struct SignInScreen: View {
    @Environment(SessionStore.self) private var session
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.circle.fill")
                            .resizable().scaledToFit()
                            .frame(width: 72, height: 72)
                            .foregroundStyle(Color.accentColor)
                        Text("ECEUH").font(.largeTitle.weight(.bold)).foregroundStyle(Color.accentColor)
                        Text("ECE Coursework Archive")
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .kerning(0.7)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 12) {
                        TextField("Institutional Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            session.mockSignIn()
                        } label: {
                            Text("Sign In").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        labeledDivider("Or continue with")

                        Button {
                            session.mockSignIn()
                        } label: {
                            Label("Continue with Apple", systemImage: "apple.logo").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        Button {
                            session.mockSignIn()
                        } label: {
                            Label("Continue with Google", systemImage: "globe").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }

                    Button("Explore without signing in") {
                        session.continueAsGuest()
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

    private func labeledDivider(_ text: String) -> some View {
        HStack {
            VStack { Divider() }
            Text(text)
                .font(.caption2.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
                .fixedSize()
            VStack { Divider() }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SignInScreen()
        .environment(SessionStore())
}
