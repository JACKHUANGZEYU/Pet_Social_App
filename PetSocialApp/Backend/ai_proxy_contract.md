# AI Proxy Contract

The iOS app intentionally does not store provider secret keys. For live AI, deploy a small server endpoint and set:

- `AI_MODE=proxy`
- `AI_PROXY_BASE_URL=https://your-domain.com`

The app will call:

```text
POST /pet-ai/generate
Content-Type: application/json
```

## Request

```json
{
  "feature": "profileSuggestion",
  "style": "playful",
  "context": "optional user-entered focus",
  "pet": {
    "id": "optional-pet-id",
    "name": "Mochi",
    "handle": "mochi_the_corgi",
    "petType": "dog",
    "breed": "Corgi",
    "age": 3,
    "gender": "unknown",
    "bio": "Tiny legs. Big opinions.",
    "personalityTags": ["playful", "snack-driven"]
  }
}
```

Supported `feature` values:

- `profileSuggestion`
- `profilePolish`
- `postCaptions`
- `studioPack`

## Response Shapes

Return the matching top-level payload for the requested feature.

```json
{
  "profileSuggestion": {
    "bio": "Tiny legs, huge park opinions, and a snack strategy for every room.",
    "tags": ["playful", "dramatic", "snack-driven"]
  }
}
```

```json
{
  "captions": [
    "Filed today under: suspicious leaf, excellent snack.",
    "I investigated the park and found it acceptable."
  ]
}
```

```json
{
  "studioPack": {
    "voiceSample": "Mochi speaks in tiny dramatic field reports.",
    "postIdeas": ["Morning patrol report", "Toy ranking"],
    "icebreakers": ["What toy is legendary in your house?"],
    "careReminders": ["Keep posts short and pet-first."]
  }
}
```

## OpenAI Backend Note

Use OpenAI from this proxy/backend, not from the mobile app. A practical implementation can call the OpenAI Responses API, ask for compact JSON matching the shapes above, validate it, and return only the app-ready fields.
