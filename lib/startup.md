# Feature: Startup Market News Screen (Frontend Only)

## Objective

Implement a premium startup screen that is displayed immediately when the application launches.

The purpose of this screen is to keep users engaged while our backend server (Render Free Tier) wakes up in the background.

**IMPORTANT: This feature must be implemented entirely on the Flutter frontend.**

Do NOT create any backend endpoints.

Do NOT modify the backend.

Do NOT depend on backend APIs for news.

The Flutter application should fetch market news directly from the Marketaux REST API.

This feature must work on both Flutter Mobile and Flutter Web.

---

# Existing Project

The project already has:

- Flutter
- GetX
- Clean Architecture
- Shared widgets
- Responsive layouts
- Mobile + Web support

Follow the existing project architecture.

Do not introduce another architecture.

---

# Startup Flow

Immediately after launching the application:

1. Display the Startup News Screen.
2. Start a background request to wake the backend using the existing backend health endpoint.
3. At the same time, fetch the latest financial news directly from the Marketaux API.
4. Display the news as soon as it is available.
5. Continue checking the backend health endpoint until it responds successfully.
6. Once the backend is ready, automatically continue to the existing app flow.

The user should never press any button.

---

# Marketaux API Integration

Implement everything on the frontend.

Create:

lib/
    models/
        news_model.dart

    services/
        marketaux_service.dart

Responsibilities:

- Make HTTP requests directly to the Marketaux REST API
- Parse JSON response
- Convert to Dart model
- Handle exceptions
- Return a list of NewsModel objects

Required fields:

- title
- description
- source
- published_at
- image_url
- url

The API key should be stored securely (e.g., using --dart-define or a config/constants file if the project already uses one). Avoid hardcoding secrets throughout the codebase.

---

# News Caching

Cache the latest news locally.

If the app opens again:

Show cached news immediately.

Refresh the news silently in the background.

If API fails:

Use cached news.

If cache is empty:

Display finance facts instead.

Never show an empty screen.

---

# Startup Screen UI

Top

App Logo

Preparing Your AI Market Assistant

Loading today's market highlights...

--------------------------------------------------

Latest Market News

--------------------------------------------------

News Card

Headline

Source

Published Time

--------------------------------------------------

News Card

Headline

Source

Published Time

--------------------------------------------------

Bottom

Animated status messages

Examples

✓ Fetching today's market news

✓ Connecting securely

✓ Waking cloud server

✓ Preparing AI engine

Rotate status messages every 3–4 seconds.

Use AnimatedSwitcher.

---

# News Cards

Modern UI

Rounded corners

Soft shadow

Optional image

Headline

Source

Published time

Responsive layout

Works on both mobile and web.

---

# Animations

Use subtle animations:

Fade

Slide

AnimatedSwitcher

AnimatedOpacity

Smooth scrolling

No flashy animations.

---

# Backend Warm-up

This feature already exists or will use the existing backend health endpoint.

Do not modify backend logic.

Only call the existing endpoint from Flutter.

Retry until success.

When backend responds successfully:

- Stop timers
- Dispose resources
- Continue to existing navigation flow

---

# Error Handling

If Marketaux request fails:

Use cached data.

If cache unavailable:

Show built-in finance facts.

Never block the UI.

Never crash.

---

# Performance

- Fetch news only once per app launch
- Cache locally
- Minimize rebuilds
- Dispose timers/controllers correctly
- Responsive using LayoutBuilder
- Keep animations smooth

---

# Code Quality

Follow:

- Clean Architecture
- Existing GetX pattern
- Reusable widgets
- Null Safety
- SOLID Principles

Do not change existing project architecture.

Only add the new startup feature.

---

# Final UX Goal

The user should feel like they are reading a professional financial briefing while the backend wakes up.

The loading experience should feel like a premium fintech application rather than a waiting screen.

The transition to the main application should happen automatically as soon as the backend is available.