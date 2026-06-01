import Foundation

enum PetSocialValidation {
    static func normalizedHandle(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func validatePetName(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Add your pet's display name." }
        guard trimmed.count <= 40 else { return "Pet name should be 40 characters or fewer." }
        return nil
    }

    static func validateHandle(_ value: String) -> String? {
        let normalized = normalizedHandle(value)
        guard (3...20).contains(normalized.count) else {
            return "Pet ID should be 3 to 20 characters."
        }

        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")
        guard normalized.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return "Pet ID can only use lowercase letters, numbers, and underscores."
        }

        return nil
    }

    static func validateAge(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let age = Int(trimmed) else {
            return "Age should be a whole number."
        }

        guard (0...40).contains(age) else {
            return "Age should be between 0 and 40."
        }

        return nil
    }

    static func validateBio(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Write a short bio in your pet's voice." }
        guard trimmed.count <= 240 else { return "Bio should be 240 characters or fewer." }
        return nil
    }

    static func validatePostText(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count <= 500 else { return "Post text should be 500 characters or fewer." }
        return nil
    }
}
