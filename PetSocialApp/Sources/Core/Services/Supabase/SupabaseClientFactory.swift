import Foundation

#if canImport(Supabase)
import Supabase
    
enum SupabaseClientFactory {
    static func makeClient(configuration: SupabaseConfiguration) -> SupabaseClient {
        SupabaseClient(
            supabaseURL: configuration.url,
            supabaseKey: configuration.publishableKey,
            options: SupabaseClientOptions(
                db: .init(schema: configuration.schema)
            )
        )
    }
}
#endif
