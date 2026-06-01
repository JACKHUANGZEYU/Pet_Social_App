import Foundation

enum PetOnboardingStep: Int, CaseIterable, Identifiable {
    case identity
    case details
    case personality

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .identity:
            return "Identity"
        case .details:
            return "Basics"
        case .personality:
            return "Voice"
        }
    }

    var subtitle: String {
        switch self {
        case .identity:
            return "Set up the public-facing pet profile."
        case .details:
            return "Add the core facts other pets should know."
        case .personality:
            return "Capture your pet's vibe before the first post."
        }
    }
}

struct PetProfileDraft: Equatable {
    var petName = ""
    var petHandle = ""
    var avatarURL = ""
    var avatarAsset: PickedImageAsset?
    var petType: PetType = .dog
    var breed = ""
    var age = ""
    var gender: PetGender = .unknown
    var bio = ""
    var personalityTags: [String] = []
    var pendingTag = ""

    init() {}

    init(profile: PetProfile) {
        petName = profile.name
        petHandle = profile.username
        avatarURL = profile.avatarURL?.absoluteString ?? ""
        avatarAsset = nil
        petType = profile.petType
        breed = profile.breed
        age = String(profile.age)
        gender = profile.gender
        bio = profile.bio
        personalityTags = profile.personalityTags
    }
}

extension PetType: Identifiable {
    public var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

extension PetGender: Identifiable {
    public var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}
