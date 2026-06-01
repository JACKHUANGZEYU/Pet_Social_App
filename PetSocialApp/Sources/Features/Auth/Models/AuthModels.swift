import Foundation

enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Log In"
    case signUp = "Sign Up"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .login:
            return "Welcome back"
        case .signUp:
            return "Create your pet parent account"
        }
    }

    var subtitle: String {
        switch self {
        case .login:
            return "Jump back into your pet social circle."
        case .signUp:
            return "Start with your account, then set up your pet's public identity."
        }
    }

    var primaryActionTitle: String {
        switch self {
        case .login:
            return "Log In"
        case .signUp:
            return "Create Account"
        }
    }
}

struct AuthFormState: Equatable {
    var mode: AuthMode = .login
    var email = ""
    var password = ""
    var confirmPassword = ""
    var ownerDisplayName = ""
}
