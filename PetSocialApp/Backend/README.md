# Supabase Backend Setup

This folder contains the phase-2 schema plus phase-4 media-input docs for `PetSocialApp`.

## Files

- `supabase/phase2_mvp_schema.sql`: database schema, indexes, RLS policies, and storage bucket setup
- `supabase/storage_notes.md`: phase-4 path conventions, native local-photo upload notes, remote URL re-upload notes, and media limitations

## What To Run In Supabase

1. Create a new Supabase project.
2. In `Authentication > Providers`, enable Email provider.
3. For local MVP testing, decide whether email confirmation should be disabled.
4. Open the SQL editor and run [`supabase/phase2_mvp_schema.sql`](./supabase/phase2_mvp_schema.sql).
5. Verify that the `pet-media` storage bucket was created.

The SQL is written to be idempotent where practical so it can be re-run during parallel development without dropping teammates' work.

Phase 4 does not require a new table. The existing `pet-media` bucket remains the source of truth for avatar and post images.

## iOS App Config Values

The Swift app should read these values from a local config source such as `Secrets.xcconfig`, a plist, or build settings:

- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_PUBLISHABLE_KEY`: Supabase publishable API key
- `SUPABASE_ANON_KEY`: legacy anon key fallback if you prefer the older key style
- `SUPABASE_MEDIA_BUCKET`: `pet-media`

Recommended optional values:

- `SUPABASE_SCHEMA`: `public`
- `SUPABASE_AVATAR_PATH_PREFIX`: `avatars`
- `SUPABASE_POSTS_PATH_PREFIX`: `posts`
- `SUPABASE_REMOTE_MEDIA_TIMEOUT_SECONDS`: app-side timeout for fetching remote image URLs before upload

The current iOS integration contract is:

- avatar and post drafts may start as either local photos selected on device or remote image URLs
- the app should upload local photo bytes directly into Supabase Storage
- the app should download remote bytes on-device, then upload them into Supabase Storage
- `public.pet_profiles.avatar_path` and `public.posts.image_path` should store bucket-relative paths, not third-party hotlinks
- the database continues to reference media by storage path so public URL generation stays consistent across local picks and imported remote images

## Suggested App Mapping

- `auth.users`: source of truth for signed-in users
- `public.pet_profiles`: one pet profile per user in v1
- `public.posts`: text/image pet posts
- `public.follows`: pet-to-pet follow graph

## Integration Notes

- Keep the current mock repositories in place while adding a Supabase-backed implementation.
- Switch feature by feature: auth/session first, then pet profile loading, then posts/feed, then follows/explore.
- The SQL uses public read access for profile and post discovery, but write access is constrained by row-level security.
- For phase 4 media upload, prefer a single normalization flow for both local picks and remote URLs: resolve bytes, detect MIME type, upload to `pet-media`, then persist the returned storage path.
- Do not save arbitrary external URLs directly into `avatar_path` or `image_path`; if the source URL disappears later, the public profile/feed media would break.

## Phase-4 Media Input Flow

1. User enters or selects an avatar/post image source.
2. If the source is already local on device, upload it directly to Supabase Storage.
3. If the source is an `http` or `https` URL, the iOS app should fetch the image data first and then re-upload that data into the `pet-media` bucket.
4. Persist only the storage-relative path in `pet_profiles.avatar_path` or `posts.image_path`.
5. Build public media URLs from Supabase Storage when rendering profile/feed UI.

See [`supabase/storage_notes.md`](./supabase/storage_notes.md) for path conventions and practical limitations.

## Practical Real-iPhone Test Flow

1. Install and run the app from Xcode on a physical iPhone.
2. Verify the first-run Photos permission prompt appears when selecting a local avatar or post image.
3. Test onboarding with a local library image and confirm the uploaded object lands under the avatar prefix in `pet-media`.
4. Test post creation with a different local library image and confirm the uploaded object lands under the posts prefix in `pet-media`.
5. Test remote URL import with a public `http` or `https` image and confirm the resulting database record still stores a bucket-relative path.
6. If an import fails on device, check network reachability, source-host hotlink restrictions, file size, and MIME type against the rules in `storage_notes.md`.
