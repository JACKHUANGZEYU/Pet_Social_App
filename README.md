# Pet Social App

Native SwiftUI MVP for a pet-centered social network where the visible identity is the pet, not the human owner.

The v1 goal is to prove the core product idea:

> Social networking through pet identities.

Users create one pet profile, post as that pet, discover other pets, follow/unfollow them, and use AI helpers to shape a playful pet voice.

## Current Status

This repository contains a native iOS MVP scaffold and implementation for the first version of the app.

The project is designed to run in two modes:

- `mock`: local seeded data and local AI suggestions for fast UI/product testing.
- `supabase`: live auth, database, storage, and optional AI proxy configuration.

The code is ready to generate an Xcode project with XcodeGen on macOS. This Windows workspace does not include the Xcode/Swift toolchain, so final compilation should be verified on macOS with Xcode.

## Product Features

- Email sign up and login flow.
- Persistent session restoration abstraction.
- One-pet onboarding for v1.
- Pet profile with avatar, handle, type, breed, age, gender, bio, and personality tags.
- Current pet profile editing with avatar replacement.
- Home feed showing posts from the current pet and followed pets.
- Text and image posts authored by the pet identity.
- Owner-only post delete controls.
- Explore/search page for discovering pets by name or handle.
- Pet-to-pet follow/unfollow.
- Follower and following counts.
- Settings page with current user, current pet, backend mode, AI mode, and sign out.
- AI bio/tag generation during onboarding.
- AI profile voice polishing.
- AI pet-style post caption suggestions.
- AI Studio tab for voice samples, post ideas, icebreakers, and creator reminders.

## Tech Stack

- iOS 17+
- Swift 5.9
- SwiftUI
- MVVM-style feature modules
- XcodeGen project generation
- Supabase-ready auth, database, and storage services
- Repository/service abstractions for mock-first development
- AI service abstraction with local mock mode and remote proxy mode

## Repository Structure

```text
.
├── PET_SOCIAL_APP_V1_OUTLINE.md
├── README.md
└── PetSocialApp
    ├── Backend
    │   ├── README.md
    │   ├── ai_proxy_contract.md
    │   └── supabase
    │       ├── phase2_mvp_schema.sql
    │       └── storage_notes.md
    ├── Resources
    │   ├── Assets.xcassets
    │   └── Configuration
    │       └── RuntimeConfig.plist.example
    ├── Sources
    │   ├── App
    │   ├── Core
    │   ├── Design
    │   └── Features
    ├── README.md
    └── project.yml
```

## App Architecture

The app uses a mock-first architecture so product flows can be developed before the live backend is fully configured.

```text
SwiftUI Views
    ↓
Feature ViewModels
    ↓
Repository / Service Protocols
    ↓
Mock implementations or Supabase / AI proxy implementations
```

Core abstractions:

- `AuthRepository`: sign up, login, restore session, sign out.
- `PetSocialRepository`: profiles, feed, posts, explore, follows.
- `PetMediaStorage`: avatar and post image handling.
- `PetAIService`: pet voice, profile, caption, and studio generation.
- `AppSessionStore`: app-wide authenticated user and current pet state.
- `AppContainer`: dependency container shared through SwiftUI environment.

## Getting Started

### 1. Install XcodeGen

On macOS:

```bash
brew install xcodegen
```

### 2. Generate the Xcode Project

```bash
cd PetSocialApp
xcodegen generate
open PetSocialApp.xcodeproj
```

### 3. Run in Mock Mode

Mock mode is the fastest way to test the app UI and product flow.

No backend is required. The app uses seeded demo data and local AI suggestions.

### 4. Run on iPhone

1. Open the generated project in Xcode.
2. Select your development team for signing.
3. Connect your iPhone.
4. Choose your device as the run target.
5. Build and run.
6. Grant Photos access when testing avatar or post image picking.

## Runtime Configuration

Copy the example config:

```bash
cp PetSocialApp/Resources/Configuration/RuntimeConfig.plist.example \
   PetSocialApp/Resources/Configuration/RuntimeConfig.plist
```

`RuntimeConfig.plist` is intentionally ignored by git because it can contain real project configuration.

Important keys:

```text
BACKEND_MODE=mock | supabase
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_your_key_here
SUPABASE_SCHEMA=public
SUPABASE_MEDIA_BUCKET=pet-media
SUPABASE_AVATAR_PATH_PREFIX=avatars
SUPABASE_POSTS_PATH_PREFIX=posts
AI_MODE=mock | proxy
AI_PROXY_BASE_URL=https://your-ai-proxy.example.com
```

## Supabase Setup

The app includes SQL and storage notes for a Supabase-backed MVP.

1. Create a Supabase project.
2. Run `PetSocialApp/Backend/supabase/phase2_mvp_schema.sql` in the Supabase SQL editor.
3. Confirm the `pet-media` storage bucket exists.
4. Copy `RuntimeConfig.plist.example` to `RuntimeConfig.plist`.
5. Set `BACKEND_MODE=supabase`.
6. Fill in `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`.

Backend docs:

- [Supabase setup](PetSocialApp/Backend/README.md)
- [Storage notes](PetSocialApp/Backend/supabase/storage_notes.md)

## AI Setup

The app ships with local mock AI suggestions, so AI product flows work immediately without an API key.

For live AI:

1. Keep provider keys on your backend, not in the iOS app.
2. Deploy an AI proxy endpoint.
3. Set `AI_MODE=proxy`.
4. Set `AI_PROXY_BASE_URL=https://your-domain.com`.

The iOS app calls:

```text
POST /pet-ai/generate
```

Proxy contract:

- [AI proxy contract](PetSocialApp/Backend/ai_proxy_contract.md)

Recommended backend behavior:

- Receive compact pet context from the app.
- Call your AI provider from the server.
- Ask for JSON matching the app contract.
- Validate the JSON.
- Return only app-ready fields.

## Security Notes

- Do not commit `RuntimeConfig.plist`.
- Do not put OpenAI, Supabase service-role, or other secret keys in the iOS app.
- Use Supabase publishable/anon keys only on the client.
- Use a backend proxy for AI provider calls.
- Keep Row Level Security enabled for live Supabase tables.

## Development Notes

This project currently uses XcodeGen instead of a checked-in `.xcodeproj`.

Benefits:

- Smaller repository.
- Easier project regeneration.
- Cleaner diffs.
- Less Xcode user-state noise.

Generated files such as `.xcodeproj`, `DerivedData`, and local runtime config are ignored.

## Testing Checklist

Mock mode:

- Sign up or log in with mock credentials.
- Complete one-pet onboarding.
- Pick a local avatar photo.
- View the home feed.
- Create a text post.
- Create an image post.
- Delete your own post.
- Explore other pets.
- Follow and unfollow another pet.
- Open AI Studio and generate suggestions.
- Sign out from Settings.

Supabase mode:

- Confirm SQL schema and RLS policies are installed.
- Confirm auth sign up and login work.
- Confirm onboarding creates one pet profile.
- Confirm avatar uploads to `pet-media`.
- Confirm posts appear in the feed and profile.
- Confirm post image paths are stored as bucket-relative storage paths.
- Confirm follow/unfollow updates counts.

## Known Limitations

- v1 supports one pet profile per user.
- Messaging is intentionally not included yet.
- AI live mode requires a separate proxy backend.
- The project still needs final compile and device validation on macOS/Xcode.
- No push notifications yet.
- No advanced recommendation system yet.
- No marketplace, map, metaverse, or 3D avatar features yet.

## Roadmap

Near-term:

- Compile and validate on macOS/Xcode.
- Add Supabase Edge Function or other AI proxy implementation.
- Add stronger auth edge-case handling.
- Add profile/post edit history or undo affordances.
- Add basic analytics events for MVP learning.

Later:

- Multi-pet accounts.
- Direct messaging.
- Richer pet-to-pet interactions.
- AI-generated pet voice/style memory.
- AI-assisted image prompts and avatar generation.
- Virtual rooms or lightweight pet spaces.
- Recommendation feed.
- Pet care reminders.

## License

No license has been selected yet. Add a license before distributing or accepting external contributions.
