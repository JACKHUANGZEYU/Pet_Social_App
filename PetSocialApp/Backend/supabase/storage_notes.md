# Storage Notes

Use a single public bucket named `pet-media` for the phase-2 MVP, phase-3 remote media import flow, and phase-4 native local photo picking flow.

## Recommended Path Conventions

- Avatar image: `<pet_profile_id>/avatars/<file-name>`
- Post image: `<pet_profile_id>/posts/<file-name>`

Examples:

- `2f3c1e67-2ba1-4d9d-a1f6-6c7c9d8d12ab/avatars/profile.jpg`
- `2f3c1e67-2ba1-4d9d-a1f6-6c7c9d8d12ab/posts/2026-04-17-morning-walk.jpg`

Recommended filename pattern for phase 4:

- Avatar: `avatar-<unix-timestamp>.<ext>`
- Post: `post-<unix-timestamp>-<short-uuid>.<ext>`

This keeps paths stable enough for debugging without forcing the app to preserve third-party filenames.

## Native Local Photo Contract

The iOS app now supports selecting avatar and post images directly from the iPhone photo library in addition to typing or pasting remote image URLs.

Expected flow:

1. Present the native iOS photo picker and let the user choose an image asset.
2. Read the selected asset bytes on-device.
3. Infer or normalize the file extension and MIME type.
4. Upload the bytes into `pet-media` using the owned-pet path prefix.
5. Save only the resulting storage-relative path to Postgres.

The local-photo path should end in the same storage contract as the remote-import path so the feed and profile UI do not need separate rendering rules.

## Remote URL Ingestion Contract

The current iOS app may receive media as remote URLs during onboarding or post creation. For live Supabase mode, treat those URLs as import sources, not as canonical media locations.

Expected flow:

1. Accept an `http` or `https` image URL from the UI layer.
2. Download the bytes on-device into temporary memory or a temporary file.
3. Infer or normalize the file extension and MIME type.
4. Upload the bytes into `pet-media` using the owned-pet path prefix.
5. Save only the resulting storage-relative path to Postgres.

Do not persist raw external URLs in `avatar_path` or `image_path`. The database columns are meant to point at Supabase Storage objects that are covered by the bucket policies in `phase2_mvp_schema.sql`.

## Why Keep The Bucket Public In MVP

- Explore and public pet profiles need fast image reads without signed URL plumbing.
- The app already treats pet profiles and posts as public-facing social content.
- This keeps the SwiftUI integration smaller while phase 2 and phase 3 focus on replacing mock data and normalizing media imports.

## Practical Limitations

- Local-photo testing requires a real iPhone or iOS Simulator flow with Photos permission enabled; on a real iPhone, the user must accept the Photos access prompt before the app can read the selected asset.
- The current bucket limit is 10 MB per object; oversized remote images should be rejected or downscaled before upload.
- Allowed MIME types are `image/jpeg`, `image/png`, `image/webp`, and `image/heic`; unusual formats such as GIF, AVIF, or SVG are outside the MVP contract unless you widen the bucket policy.
- Remote import is client-side. If the source host is slow, blocks hotlinking, or requires cookies/auth headers, the iOS app may fail to ingest the image.
- External URLs can disappear at any time, which is exactly why the app should re-upload them instead of storing the third-party URL directly.
- There is no server-side deduplication, malware scanning, or image moderation in the MVP.
- Public bucket reads are convenient for shipping, but they are not ideal for private media or regulated content.

## Real iPhone Smoke Test

1. Launch the app on a physical iPhone signed into a Supabase-backed build.
2. Pick a local image for the pet avatar and confirm the object appears under `<pet_profile_id>/avatars/...`.
3. Create a post with another local image and confirm the object appears under `<pet_profile_id>/posts/...`.
4. Repeat with a remote image URL and confirm the stored database value is still a storage-relative path rather than the original external URL.
5. Open the profile/feed after each upload to verify the rendered image uses the Supabase-hosted object successfully.

## Future Hardening

If you want tighter media permissions later, move to path-aware storage policies:

- only allow uploads into `<owned_pet_id>/...`
- only allow updates/deletes for objects under that same prefix
- optionally keep avatars public and serve post images through signed URLs

That hardening is intentionally not required for the MVP so the app team can integrate in parallel without waiting on storage-specific client code.
