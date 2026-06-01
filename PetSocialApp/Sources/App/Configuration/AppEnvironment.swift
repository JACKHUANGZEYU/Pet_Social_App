import Foundation

enum BackendMode: String {
    case mock
    case supabase
}

enum AIMode: String {
    case mock
    case proxy
}

struct AIConfiguration {
    let mode: AIMode
    let proxyBaseURL: URL?
}

struct AppEnvironment {
    let backendMode: BackendMode
    let supabase: SupabaseConfiguration?
    let ai: AIConfiguration

    static func load(bundle: Bundle = .main) -> AppEnvironment {
        let dictionary = loadRuntimeDictionary(bundle: bundle)

        let backendMode = BackendMode(
            rawValue: (dictionary["BACKEND_MODE"] as? String ?? "mock").lowercased()
        ) ?? .mock

        let urlString = dictionary["SUPABASE_URL"] as? String ?? ""
        let publishableKey = (
            dictionary["SUPABASE_PUBLISHABLE_KEY"] as? String
            ?? dictionary["SUPABASE_ANON_KEY"] as? String
            ?? ""
        )
        let schema = dictionary["SUPABASE_SCHEMA"] as? String ?? "public"
        let mediaBucket = dictionary["SUPABASE_MEDIA_BUCKET"] as? String ?? SupabaseTable.mediaBucket
        let avatarPathPrefix = dictionary["SUPABASE_AVATAR_PATH_PREFIX"] as? String ?? "avatars"
        let postsPathPrefix = dictionary["SUPABASE_POSTS_PATH_PREFIX"] as? String ?? "posts"
        let aiMode = AIMode(
            rawValue: (dictionary["AI_MODE"] as? String ?? "mock").lowercased()
        ) ?? .mock
        let aiProxyURL = URL(string: dictionary["AI_PROXY_BASE_URL"] as? String ?? "")

        let supabaseConfiguration: SupabaseConfiguration?
        if let url = URL(string: urlString), !publishableKey.isEmpty {
            supabaseConfiguration = SupabaseConfiguration(
                url: url,
                publishableKey: publishableKey,
                schema: schema,
                mediaBucket: mediaBucket,
                avatarPathPrefix: avatarPathPrefix,
                postsPathPrefix: postsPathPrefix
            )
        } else {
            supabaseConfiguration = nil
        }

        return AppEnvironment(
            backendMode: backendMode,
            supabase: supabaseConfiguration,
            ai: AIConfiguration(mode: aiMode, proxyBaseURL: aiProxyURL)
        )
    }

    private static func loadRuntimeDictionary(bundle: Bundle) -> [String: Any] {
        let fileURL = bundle.url(
            forResource: "RuntimeConfig",
            withExtension: "plist",
            subdirectory: "Configuration"
        ) ?? bundle.url(forResource: "RuntimeConfig", withExtension: "plist")

        guard let fileURL,
              let data = try? Data(contentsOf: fileURL),
              let object = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
              ),
              let dictionary = object as? [String: Any]
        else {
            return [:]
        }

        return dictionary
    }
}
