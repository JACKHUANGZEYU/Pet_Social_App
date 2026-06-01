Pet Social App v1 Project Outline

Project Goal

Build the first iOS MVP of a pet-centered social app.

This is a mobile app where users interact through their pets' identities instead of their own.
Each account is centered on a pet profile. The first version should focus on the core experience: creating a pet identity, viewing a pet profile, posting pet-style updates, and basic pet-to-pet social interaction.

The goal of v1 is not to build the full metaverse vision yet.
The goal is to create a clean, working foundation that proves the core concept:

"social networking through pet identities."

Core Product Concept

In this app:

the visible identity is the pet
users create a pet profile
pets can have avatars, bios, personality tags, and posts
the app should feel like a lightweight pet social network, not just a generic forum

Human owners operate the app, but the social layer is presented as if pets are the main characters.

v1 Scope

Focus only on the following basic features:

1. Authentication
user sign up
user log in
persistent session
simple onboarding flow

2. Pet Profile Creation

Each user creates one pet profile for v1:

pet name
pet ID / username
avatar image
pet type (dog, cat, etc.)
breed
age
gender
short bio
personality tags

3. Pet Profile Page

A public-facing pet profile page should include:

avatar
pet name
pet ID
bio
basic pet info
personality tags
post list

4. Pet Feed / Posts

Users can create simple posts as their pet:

text post
image post
timestamp
display on home feed
display on pet profile page

The tone of the UI should reinforce that the post is coming from the pet identity.

5. Basic Social Graph

For v1, support lightweight pet social connection:

follow / unfollow another pet
follower count
following count
feed can show posts from followed pets

No need for full messaging in v1 yet unless architecture makes it easy later.

6. Basic Explore

Simple discover page:

list of pets
search by pet name or pet ID
tap into pet profile

Non-Goals for v1

Do not build these yet:

full chat / messaging
voice or video calls
metaverse world
AI pet clone training
3D pet avatar
location-based social map
pet matchmaking
marketplace
advanced recommendation system

These can be planned later, but should not block v1.

Product Priorities

The first version should prioritize:

shipping quickly
clean architecture
clear data models
simple but polished UI
extensibility for future AI / virtual pet features

Suggested Tech Direction

Ask the planner to choose a practical modern iOS stack suitable for fast iteration.

Suggested default:

Swift + SwiftUI
MVVM or a similarly simple scalable architecture
Firebase or Supabase for backend/auth/storage if speed is preferred
modular code structure so future features can be added cleanly

The project should be designed so that future versions can add:

AI-generated pet voice/style
virtual pet rooms
digital pet clone / behavior modeling
richer social interactions

Deliverables I Want From the Planner

Please generate:

a phased implementation plan for v1
recommended app architecture
initial data models
page / screen list
backend choice recommendation
folder structure suggestion
MVP development order from easiest to hardest
what should be mocked first vs what should be built for real

Keep the plan practical and focused on helping me start coding immediately.
