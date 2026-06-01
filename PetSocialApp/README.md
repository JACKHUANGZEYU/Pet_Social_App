# PetSocialApp

Native SwiftUI v1 MVP for a pet-centered social app.

## Current Scope

- Email auth screens with mock sign up / log in and Supabase-ready auth
- One-pet onboarding flow with native photo picking
- Current pet profile editing with avatar replacement
- Home feed, explore search, profile, create-post, and settings tabs
- Pet-authored text/image posts with owner-only delete controls
- Pet-to-pet follow/unfollow, follower counts, and following counts
- AI helpers for pet bio/tag generation, profile voice polishing, caption ideas, and an AI Studio tab
- Shared validation aligned with Supabase MVP database constraints
- Mutable mock repositories and seeded demo data
- Supabase-ready live repository scaffolding with mock fallback
- Runtime config loader for switching between `mock` and `supabase`
- Backend docs for media import and native photo picking into Supabase Storage

## Suggested Next Step

Generate the Xcode project on macOS with XcodeGen:

```bash
brew install xcodegen
cd PetSocialApp
xcodegen generate
open PetSocialApp.xcodeproj
```

## Runtime Config

1. Copy `Resources/Configuration/RuntimeConfig.plist.example` to `Resources/Configuration/RuntimeConfig.plist`.
2. Leave `BACKEND_MODE=mock` if you only want UI/demo data.
3. Switch to `BACKEND_MODE=supabase` and fill in `SUPABASE_URL` plus either `SUPABASE_PUBLISHABLE_KEY` or the legacy `SUPABASE_ANON_KEY` when you are ready to hit a real backend.
4. Set `SUPABASE_MEDIA_BUCKET=pet-media` and keep the path prefixes aligned with the backend docs if you plan to upload avatars or post media.
5. Keep `AI_MODE=mock` for local AI suggestions, or set `AI_MODE=proxy` and `AI_PROXY_BASE_URL` to a backend you control.
6. Run the SQL in [Backend/README.md](./Backend/README.md) before testing live auth/profile/post flows.

## AI Features

- The app includes a `PetAIService` abstraction with local mock suggestions by default.
- AI is wired into onboarding, edit profile, create post, settings, and the dedicated AI Studio tab.
- Do not place an OpenAI API key in the iOS app. For live AI, point `AI_PROXY_BASE_URL` at a backend endpoint such as `https://your-domain.com/pet-ai/generate`.
- The proxy endpoint should accept a JSON body containing `feature`, `pet`, `style`, and `context`, then return one of `profileSuggestion`, `captions`, or `studioPack`; see [Backend/ai_proxy_contract.md](./Backend/ai_proxy_contract.md).
- For OpenAI-backed text generation, use the Responses API from your server/proxy and return only the compact JSON the app needs.

## Media Upload Notes

- The live backend contract expects `avatar_path` and `image_path` to store Supabase Storage paths, not raw third-party URLs.
- The iOS app now supports two media input paths during onboarding and post creation: native local photo picking on device and remote image URL import.
- For remote import, the app may ingest an `http` or `https` image URL, download it locally, and then re-upload it into the `pet-media` bucket before saving the database record.
- For native local photo picking, the app should upload the selected asset bytes directly into the `pet-media` bucket before saving the database record.
- Bucket path conventions and practical limitations are documented in [Backend/supabase/storage_notes.md](./Backend/supabase/storage_notes.md).

## Real iPhone Testing Flow

1. Prepare a macOS machine with Xcode, generate the project, and run the app on a connected iPhone.
2. Keep `BACKEND_MODE=mock` if you only want to verify navigation, local photo picking UI, and seeded feed/profile flows without a backend.
3. Switch to `BACKEND_MODE=supabase` after filling `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, and `SUPABASE_MEDIA_BUCKET` when you want to verify real auth plus media upload.
4. On the first local-photo test, grant Photos permission on the iPhone when iOS prompts for access.
5. Test both media paths:
   - choose a local photo from the iPhone photo library and confirm it appears in the pet avatar or post preview
   - paste a remote image URL and confirm the app imports it by re-uploading into Supabase Storage
6. After each live upload, confirm the new object exists in the `pet-media` bucket and that the related profile or post record stores a storage-relative path instead of a third-party URL.
