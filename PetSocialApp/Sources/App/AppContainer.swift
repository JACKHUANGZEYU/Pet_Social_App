import Combine
import Foundation

final class AppContainer: ObservableObject {
    let environment: AppEnvironment
    let theme = AppTheme()
    let authRepository: any AuthRepository
    let repository: any PetSocialRepository
    let mediaStorage: any PetMediaStorage
    let aiService: any PetAIService
    let session: AppSessionStore
    private var cancellables = Set<AnyCancellable>()

    init(
        environment: AppEnvironment,
        authRepository: any AuthRepository,
        repository: any PetSocialRepository,
        mediaStorage: any PetMediaStorage,
        aiService: any PetAIService,
        session: AppSessionStore
    ) {
        self.environment = environment
        self.authRepository = authRepository
        self.repository = repository
        self.mediaStorage = mediaStorage
        self.aiService = aiService
        self.session = session

        session.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    static func bootstrap() -> AppContainer {
        AppBootstrap.makeContainer()
    }
}
