import Foundation

enum AppBootstrap {
    static func makeContainer(environment: AppEnvironment = .load()) -> AppContainer {
        if let liveContainer = makeSupabaseContainerIfPossible(environment: environment) {
            return liveContainer
        }

        return makeMockContainer(environment: environment)
    }

    private static func makeMockContainer(environment: AppEnvironment) -> AppContainer {
        let repository = MockPetSocialRepository()
        let authRepository = MockAuthRepository()
        let mediaStorage = MockPetMediaStorage()
        let fallbackEnvironment = AppEnvironment(
            backendMode: .mock,
            supabase: nil,
            ai: environment.ai
        )
        let session = AppSessionStore(
            authState: .launching,
            authRepository: authRepository,
            petSocialRepository: repository
        )

        return AppContainer(
            environment: fallbackEnvironment,
            authRepository: authRepository,
            repository: repository,
            mediaStorage: mediaStorage,
            aiService: makeAIService(environment: fallbackEnvironment),
            session: session
        )
    }

    private static func makeSupabaseContainerIfPossible(environment: AppEnvironment) -> AppContainer? {
        guard environment.backendMode == .supabase,
              let configuration = environment.supabase,
              let liveStack = SupabaseServiceFactory.makeLiveStack(configuration: configuration)
        else {
            return nil
        }

        let session = AppSessionStore(
            authState: .launching,
            authRepository: liveStack.authRepository,
            petSocialRepository: liveStack.repository
        )

        return AppContainer(
            environment: environment,
            authRepository: liveStack.authRepository,
            repository: liveStack.repository,
            mediaStorage: liveStack.mediaStorage,
            aiService: makeAIService(environment: environment),
            session: session
        )
    }

    private static func makeAIService(environment: AppEnvironment) -> any PetAIService {
        guard environment.ai.mode == .proxy,
              let proxyBaseURL = environment.ai.proxyBaseURL
        else {
            return MockPetAIService()
        }

        return RemotePetAIService(proxyBaseURL: proxyBaseURL)
    }
}
