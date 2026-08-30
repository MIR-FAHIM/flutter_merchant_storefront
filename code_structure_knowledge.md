# Code Structure Knowledge

This project should be maintained as a GetX-based modular Flutter codebase.

## Core Stack

- Use GetX for state management, dependency injection, bindings, and route management.
- Keep feature code modular under `lib/app/modules`.
- Keep shared app infrastructure under `lib/app/api_providers`, `lib/app/models`, `lib/app/repositories`, `lib/app/routes`, and `lib/app/services`.

## Main Architecture

Data and control flow should stay in this order:

```text
View -> Controller -> Repository -> APIManager -> API
View <- Controller state/model <- Repository <- APIManager
```

Important boundaries:

- Views must not call repositories or `APIManager` directly.
- Controllers must call repositories.
- Repositories must call `APIManager`.
- API endpoint strings must come from `api_url.dart`.
- API/network errors should be mapped through custom exception classes where possible.

## Root Folder Responsibilities

```text
lib/
  app/
    api_providers/
    models/
    modules/
    repositories/
    routes/
    services/
```

### `api_providers/`

Direct API/network layer.

Expected files:

- `api_manager.dart`: HTTP methods, headers, request body, query params, response parsing, status handling, timeout handling, exception mapping.
- `api_url.dart`: base URL, endpoint paths, API route constants.
- `custom_exceptions.dart` or current project equivalent `customExceptions.dart`: network/API exception classes.

### `models/`

Dart model classes for API responses and request/response payloads.

Rules:

- Use `fromJson` and `toJson` where needed.
- Organize by feature/domain when the model list grows.
- Controllers should store API results as typed model objects when practical.

### `repositories/`

Shared/global repositories only.

Rules:

- Use this folder when repository logic is reused across multiple modules.
- Shared repositories call `api_providers`.
- Shared repositories return clean model/data responses to controllers.

### `services/`

App-wide services such as:

- Auth/session service
- Local storage service
- Connectivity service
- Notification service
- Firebase messaging service
- Location service
- Theme/settings/translation services
- Other app-level utility services

### `routes/`

All GetX navigation belongs here.

Required files:

- `app_pages.dart`: defines `AppPages`, `INITIAL`, and `GetPage` entries.
- `app_routes.dart`: `part of 'app_pages.dart';`, public `Routes` constants, private `_Paths` constants.

Every module route should register:

- route name/path
- page/view
- binding

## Feature Module Structure

Target structure for each feature:

```text
lib/app/modules/feature_name/
  bindings/
    feature_name_binding.dart
  controllers/
    feature_name_controller.dart
  repositories/
    feature_name_repository.dart
  views/
    feature_name_view.dart
    widgets/
```

Current project note:

- Some existing modules use `binding/`, `controller/`, and `view/` singular folders.
- When editing an existing module, follow that module's current local convention unless a refactor is explicitly requested.
- When creating a new module, prefer the target structure above.

## Feature Module Rules

- `bindings/`: GetX bindings for injecting the feature controller and feature repository when needed.
- `controllers/`: GetX controllers; handle feature logic, UI state, repository calls, loading state, error state, and model response storage.
- `repositories/`: feature-specific API/data logic.
- `views/`: main screen/page UI only.
- `views/widgets/`: reusable UI widgets used only by that feature.

Every feature should have its own repository inside its module when the logic belongs only to that feature. Use app-level repositories only for shared logic.

## Login Feature Standard

Login is the default auth feature pattern.

Expected structure:

```text
lib/app/modules/auth/login/
  bindings/
    login_binding.dart
  controllers/
    login_controller.dart
  repositories/
    login_repository.dart
  views/
    login_view.dart
    widgets/
```

Class names:

- `LoginBinding`
- `LoginController`
- `LoginRepository`
- `LoginView`

Login controller rules:

- Extend `GetxController`.
- Use `GlobalKey<FormState>` for form state.
- Use Rx variables for input and UI state.
- Call repository methods for login API work.
- Save successful API response into a Dart model.
- Use `AuthService` or equivalent to persist logged-in user/session.
- Navigate with GetX routes after successful login, usually `Get.offAllNamed(...)`.
- Show loading and error states properly.
- Never call `APIManager` directly.

Login view rules:

- Extend `GetView<LoginController>` where practical.
- Use controller variables and methods.
- Keep UI code in the view/widgets layer.
- Put reusable login UI components inside `views/widgets/`.

## Naming Rules

- Folders and files: lowercase `snake_case`.
- Classes: `PascalCase`.
- Controllers: `FeatureNameController`.
- Bindings: `FeatureNameBinding`.
- Repositories: `FeatureNameRepository`.
- Views: `FeatureNameView`.
- Route constants: follow the existing `Routes`/`_Paths` style in `app_routes.dart`.

## When Creating A New Feature

Always add:

- Binding
- Controller
- Repository
- Main view
- Widgets folder
- Route entry in `app_pages.dart`
- Route constant/path in `app_routes.dart`

## Existing Project Anchors

Current important paths:

- API manager: `lib/app/api_providers/api_manager.dart`
- API URLs: `lib/app/api_providers/api_url.dart`
- Custom exceptions: `lib/app/api_providers/customExceptions.dart`
- Routes: `lib/app/routes/app_pages.dart` and `lib/app/routes/app_routes.dart`
- App services: `lib/app/services/`
- Shared repositories: `lib/app/repositories/`
- Modules: `lib/app/modules/`
- Global widgets: `lib/app/modules/global_widgets/`

Use this file as the default structure memory before adding or changing code in this project.
