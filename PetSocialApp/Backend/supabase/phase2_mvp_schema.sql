-- PetSocialApp phase-2 MVP schema
-- Safe to run in Supabase SQL editor.

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.pet_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null unique references auth.users(id) on delete cascade,
  pet_name text not null check (char_length(trim(pet_name)) between 1 and 40),
  pet_handle text not null unique check (pet_handle ~ '^[a-z0-9_]{3,20}$'),
  avatar_path text,
  pet_type text not null check (pet_type in ('dog', 'cat', 'bird', 'rabbit', 'hamster', 'other')),
  breed text,
  age integer check (age is null or age between 0 and 40),
  gender text check (gender is null or gender in ('male', 'female', 'unknown')),
  bio text check (bio is null or char_length(bio) <= 240),
  personality_tags text[] not null default '{}',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pet_profiles(id) on delete cascade,
  text_content text check (text_content is null or char_length(text_content) <= 500),
  image_path text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint posts_content_check
    check (
      coalesce(nullif(trim(text_content), ''), '') <> ''
      or image_path is not null
    )
);

create table if not exists public.follows (
  id uuid primary key default gen_random_uuid(),
  follower_pet_id uuid not null references public.pet_profiles(id) on delete cascade,
  following_pet_id uuid not null references public.pet_profiles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  constraint follows_unique unique (follower_pet_id, following_pet_id),
  constraint follows_no_self check (follower_pet_id <> following_pet_id)
);

create index if not exists pet_profiles_owner_user_id_idx
  on public.pet_profiles (owner_user_id);

create index if not exists pet_profiles_handle_lower_idx
  on public.pet_profiles (lower(pet_handle));

create index if not exists pet_profiles_name_trgm_idx
  on public.pet_profiles using gin (pet_name gin_trgm_ops);

create index if not exists pet_profiles_handle_trgm_idx
  on public.pet_profiles using gin (pet_handle gin_trgm_ops);

create index if not exists posts_pet_id_created_at_idx
  on public.posts (pet_id, created_at desc);

create index if not exists posts_created_at_idx
  on public.posts (created_at desc);

create index if not exists follows_follower_pet_id_idx
  on public.follows (follower_pet_id);

create index if not exists follows_following_pet_id_idx
  on public.follows (following_pet_id);

create or replace function public.auth_owns_pet(target_pet_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.pet_profiles pet
    where pet.id = target_pet_id
      and pet.owner_user_id = auth.uid()
  );
$$;

create or replace function public.storage_path_matches_owned_pet(object_name text)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.pet_profiles pet
    where pet.owner_user_id = auth.uid()
      and split_part(object_name, '/', 1) = pet.id::text
  );
$$;

drop trigger if exists pet_profiles_set_updated_at on public.pet_profiles;
create trigger pet_profiles_set_updated_at
before update on public.pet_profiles
for each row
execute function public.set_updated_at();

drop trigger if exists posts_set_updated_at on public.posts;
create trigger posts_set_updated_at
before update on public.posts
for each row
execute function public.set_updated_at();

alter table public.pet_profiles enable row level security;
alter table public.posts enable row level security;
alter table public.follows enable row level security;

drop policy if exists "pet profiles are publicly readable" on public.pet_profiles;
create policy "pet profiles are publicly readable"
on public.pet_profiles
for select
using (true);

drop policy if exists "owners can insert their pet profile" on public.pet_profiles;
create policy "owners can insert their pet profile"
on public.pet_profiles
for insert
with check (owner_user_id = auth.uid());

drop policy if exists "owners can update their pet profile" on public.pet_profiles;
create policy "owners can update their pet profile"
on public.pet_profiles
for update
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

drop policy if exists "owners can delete their pet profile" on public.pet_profiles;
create policy "owners can delete their pet profile"
on public.pet_profiles
for delete
using (owner_user_id = auth.uid());

drop policy if exists "posts are publicly readable" on public.posts;
create policy "posts are publicly readable"
on public.posts
for select
using (true);

drop policy if exists "pet owners can insert posts" on public.posts;
create policy "pet owners can insert posts"
on public.posts
for insert
with check (public.auth_owns_pet(pet_id));

drop policy if exists "pet owners can update posts" on public.posts;
create policy "pet owners can update posts"
on public.posts
for update
using (public.auth_owns_pet(pet_id))
with check (public.auth_owns_pet(pet_id));

drop policy if exists "pet owners can delete posts" on public.posts;
create policy "pet owners can delete posts"
on public.posts
for delete
using (public.auth_owns_pet(pet_id));

drop policy if exists "follows are publicly readable" on public.follows;
create policy "follows are publicly readable"
on public.follows
for select
using (true);

drop policy if exists "pet owners can follow from their own pet" on public.follows;
create policy "pet owners can follow from their own pet"
on public.follows
for insert
with check (public.auth_owns_pet(follower_pet_id));

drop policy if exists "pet owners can unfollow from their own pet" on public.follows;
create policy "pet owners can unfollow from their own pet"
on public.follows
for delete
using (public.auth_owns_pet(follower_pet_id));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'pet-media',
  'pet-media',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "pet media is publicly readable" on storage.objects;
create policy "pet media is publicly readable"
on storage.objects
for select
using (bucket_id = 'pet-media');

drop policy if exists "authenticated users can upload pet media" on storage.objects;
create policy "authenticated users can upload pet media"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'pet-media'
  and public.storage_path_matches_owned_pet(name)
);

drop policy if exists "authenticated users can update pet media" on storage.objects;
create policy "authenticated users can update pet media"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'pet-media'
  and public.storage_path_matches_owned_pet(name)
)
with check (
  bucket_id = 'pet-media'
  and public.storage_path_matches_owned_pet(name)
);

drop policy if exists "authenticated users can delete pet media" on storage.objects;
create policy "authenticated users can delete pet media"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'pet-media'
  and public.storage_path_matches_owned_pet(name)
);

comment on table public.pet_profiles is
  'One pet profile per auth user for v1. Publicly readable; owner writable.';

comment on table public.posts is
  'Pet-authored text/image posts for feed and profile timelines.';

comment on table public.follows is
  'Pet-to-pet follow graph used for feed filtering and counts.';

comment on column public.pet_profiles.avatar_path is
  'Storage-relative path in pet-media bucket, for example <pet_id>/avatars/avatar.jpg. External URLs should be imported into storage first.';

comment on column public.posts.image_path is
  'Storage-relative path in pet-media bucket, for example <pet_id>/posts/post-uuid.jpg. External URLs should be imported into storage first.';
