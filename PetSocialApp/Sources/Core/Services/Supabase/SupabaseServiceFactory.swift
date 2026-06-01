import Foundation

#if canImport(Supabase)
import Supabase
#endif

struct SupabaseLiveStack {
    let authRepository: any AuthRepository
    let repository: any PetSocialRepository
    let mediaStorage: any PetMediaStorage
}

enum SupabaseServiceFactory {
    static func makeLiveStack(configuration: SupabaseConfiguration) -> SupabaseLiveStack? {
        #if canImport(Supabase)
        let client = SupabaseClientFactory.makeClient(configuration: configuration)
        return SupabaseLiveStack(
            authRepository: SupabaseAuthRepository(client: client),
            repository: SupabasePetSocialRepository(client: client, configuration: configuration),
            mediaStorage: SupabasePetMediaStorage(client: client, configuration: configuration)
        )
        #else
        return nil
        #endif
    }
}
