# 🎮 Math Multiplayer — Flutter Client

> A real-time, 1v1 competitive multiplayer gaming platform featuring high-speed mental arithmetic (**Flicker Fomo / Flash Anzan**) and speed-solving **6×6 Sudoku** — built with Flutter, Dart, Provider, Socket.IO, and Supabase Auth.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Game Modes](#game-modes)
  - [Flicker Fomo (FlashNumbers)](#-flicker-fomo-flashnumbers)
  - [Multiplayer Sudoku](#-multiplayer-sudoku)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Running the App](#running-the-app)
- [State Management](#state-management)
- [Networking & Socket Protocol](#networking--socket-protocol)
- [Authentication](#authentication)
- [Key Algorithms](#key-algorithms)
- [Screenshots & UI Flow](#screenshots--ui-flow)
- [Testing](#testing)
- [Known Limitations](#known-limitations)
- [Roadmap](#roadmap)
- [License](#license)

---

## Overview

**Math Multiplayer** (branded as **Bundled IQ**) is the cross-platform Flutter frontend for a real-time 1v1 competitive gaming platform. Two remote players are matched through a FIFO queue-based matchmaking system, enter a synchronized countdown, and race to outperform each other in mental math and puzzle-solving challenges — all validated by an authoritative Node.js + Socket.IO backend.

### Key Highlights

- 🏆 **Two competitive multiplayer game modes** — FlashNumbers and Speed Sudoku
- ⚡ **Real-time WebSocket communication** via Socket.IO for sub-second synchronization
- 🔒 **Server-authoritative architecture** — scoring, timers, and puzzle solutions are validated exclusively on the backend
- 🔐 **Supabase Authentication** — email/password sign-up and sign-in
- 📱 **Cross-platform** — Android, iOS, Web, Windows, macOS, Linux

---

## Game Modes

### ⚡ Flicker Fomo (FlashNumbers)

Inspired by **Flash Anzan** — a mental arithmetic competition where players must sum rapidly flashing numbers.

| Parameter              | Value                      |
|------------------------|----------------------------|
| Numbers per round      | 8 integers (range 1–10)    |
| Flash duration         | ~10 seconds (1.25s each)   |
| Answer input window    | 5 seconds                  |
| Total rounds per match | 3                          |
| Pre-game countdown     | 5 seconds                  |
| Scoring                | +1 point per correct sum   |

**How it works:**
1. Both players join the matchmaking queue and are paired in real-time.
2. A 5-second countdown synchronizes both clients.
3. A sequence of **8 random integers** (1–10) flashes on screen, one at a time, each for ~1.25 seconds.
4. After flashing completes, a **5-second input window** appears for players to type their calculated sum.
5. The server evaluates answers against the authoritative correct sum and broadcasts results.
6. This repeats for **3 rounds** — the player with the highest cumulative score wins.

> 💡 Each player receives a **different** random sequence per round, preventing screen-peeking.

---

### 🧩 Multiplayer Sudoku

A speed-solving race on dynamically generated **6×6 mini-Sudoku** puzzles with guaranteed single-solution uniqueness.

| Parameter             | Value                                 |
|-----------------------|---------------------------------------|
| Grid size             | 6×6 (2×3 subgrid blocks)             |
| Valid values          | 1–6                                   |
| Pre-filled clues      | 16 (leaving 20 cells to solve)        |
| Regulation time       | 60 seconds                            |
| Overtime (if tied)    | 30 seconds (sudden death)             |
| Scoring               | +1 point per correctly solved puzzle  |

**How it works:**
1. Players are matched and presented with the **same sequence of puzzles**.
2. During the **60-second regulation round**, players race to solve as many puzzles as possible.
3. The grid features **real-time conflict highlighting** — invalid placements are immediately shown with red indicators.
4. When a puzzle is completed without conflicts, it is **automatically submitted** to the server for validation.
5. If correct, the player advances to the next puzzle and scores a point. If incorrect, the server sends the puzzle back for correction.
6. If scores are tied after regulation, a **30-second sudden-death overtime** begins — the first player to solve a puzzle wins instantly.
7. If no one solves during overtime, the match ends in a **draw**.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       FLUTTER CLIENT                            │
│                                                                 │
│  ┌──────────────┐  ┌──────────────────┐  ┌───────────────────┐  │
│  │ Supabase Auth│  │   UI Screens     │  │  State Stores     │  │
│  │ (AuthGate,   │  │  (Home, Flash,   │  │  (GameService,    │  │
│  │  Login, JWT) │  │   Sudoku, etc.)  │  │  SudokuService)   │  │
│  └──────────────┘  └──────────────────┘  └────────┬──────────┘  │
│                                          Provider ChangeNotifier│
│                                                   │             │
│                                          ┌────────▼──────────┐  │
│                                          │  SocketService    │  │
│                                          │   (Singleton)     │  │
└──────────────────────────────────────────┴────────┬──────────┘──┘
                                                    │
                                       WebSocket (Socket.IO)
                                         Port 3000
                                                    │
┌───────────────────────────────────────────────────▼──────────────┐
│                      NODE.JS BACKEND                             │
│                                                                  │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐  │
│  │ Matchmaker  │  │ GameManager  │  │  Game Engines           │  │
│  │ (FIFO Queue)│  │ (Map<ID,Game>)│ │  • FlashNumber/game.js  │  │
│  │             │  │              │  │  • Sudoku/game.js       │  │
│  └─────────────┘  └──────────────┘  │  • util/sudokuGen.js    │  │
│                                     └─────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

The client follows a **reactive, event-driven architecture**:

1. **`SocketService`** — Singleton managing the WebSocket connection lifecycle, event dispatching, and listener teardown.
2. **`GameService` / `SudokuGameService`** — `ChangeNotifier` state stores that bind socket events to typed state models and notify UI listeners.
3. **Screens** — Stateless/Stateful widgets that consume state via `Provider` and render appropriate UI phases based on enum-driven state machines.

---

## Tech Stack

| Category               | Technology           | Version    |
|------------------------|----------------------|------------|
| Framework              | Flutter              | SDK ^3.9.2 |
| Language               | Dart                 | 3.9+       |
| State Management       | Provider             | ^6.1.2     |
| Real-Time Networking   | socket_io_client     | ^3.0.2     |
| Authentication         | supabase_flutter     | ^2.16.0    |
| Typography             | google_fonts         | ^8.1.0     |
| Icons                  | cupertino_icons      | ^1.0.8     |
| Linting                | flutter_lints        | ^5.0.0     |

**Backend** (separate repo — `SudokuMultiplayer/`):
- Node.js, Express 5, Socket.IO 4.8

---

## Project Structure

```
math_multiplayer/
├── lib/
│   ├── main.dart                          # App entry: Supabase init, Provider setup, root widget
│   ├── config/
│   │   └── app_config.dart                # Server URL & game timing constants
│   ├── models/
│   │   ├── game_state.dart                # FlashNumbers state model & GamePhase enum
│   │   └── sudoku_game_state.dart         # Sudoku state model & SudokuGamePhase enum
│   ├── screens/
│   │   ├── homescreen.dart                # Game mode selection portal ("Bundled IQ")
│   │   ├── Authfiles/
│   │   │   ├── auth_gate.dart             # Auth state listener & route guard
│   │   │   ├── auth_screen.dart           # Login/Signup toggle screen
│   │   │   ├── login_box.dart             # Login form widget
│   │   │   └── signup_box.dart            # Signup form widget
│   │   ├── FlashAzan/
│   │   │   ├── game_screen.dart           # FlashNumbers phase router
│   │   │   ├── flash_screen.dart          # Number flashing animation view
│   │   │   └── answer_screen.dart         # Sum input view with countdown
│   │   ├── Sudoku/
│   │   │   ├── sudoku_main.dart           # Sudoku game screen coordinator
│   │   │   ├── sudoku_board.dart          # 6×6 grid renderer
│   │   │   ├── sudoku_cell.dart           # Individual cell widget with conflict styling
│   │   │   ├── number_pad.dart            # 1–6 digit input pad
│   │   │   ├── scoreboard_widget.dart     # Live score display
│   │   │   └── timer_widget.dart          # Countdown timer display
│   │   └── common/
│   │       ├── countdown_screen.dart      # Pre-game countdown overlay
│   │       ├── loading_screen.dart        # Matchmaking waiting screen
│   │       ├── victory_game_screen.dart   # Victory celebration screen
│   │       ├── defeat_game_screen.dart    # Defeat screen
│   │       ├── draw_screen.dart           # Draw result screen
│   │       ├── round_result_screen.dart   # Inter-round result display
│   │       └── game_over_fallback.dart    # Fallback game-over view
│   ├── services/
│   │   ├── socket_service.dart            # Singleton Socket.IO client
│   │   ├── auth_service.dart              # Supabase GoTrue wrapper
│   │   ├── flash_game_service.dart        # FlashNumbers ChangeNotifier store
│   │   └── sudoku_game_service.dart       # Sudoku ChangeNotifier store
│   ├── utils/
│   │   ├── sudoku_validator.dart          # Client-side 6×6 constraint checker
│   │   └── validators.dart                # Form validation utilities
│   └── widgets/
│       └── custom_text_field.dart          # Reusable styled text input
├── images/
│   └── background.png                     # Home screen background image
├── test/
│   └── game_state_test.dart               # Unit test for GameState.reset()
├── pubspec.yaml                           # Dependencies & asset declarations
├── analysis_options.yaml                  # Dart/Flutter lint rules
└── README.md                              # ← You are here
```

---

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.9.2 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** ≥ 3.9 (bundled with Flutter)
- **Node.js** ≥ 18 (for the backend server in `SudokuMultiplayer/`)
- A **Supabase** project with email/password authentication enabled
- An Android emulator, iOS simulator, or physical device

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd MultiplayerMath/math_multiplayer
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Start the backend server** (in a separate terminal):
   ```bash
   cd ../SudokuMultiplayer
   npm install
   node server.js
   ```
   The server will start on port **3000**.

### Configuration

Edit [`lib/config/app_config.dart`](lib/config/app_config.dart) to configure the server URL for your environment:

```dart
class AppConfig {
  // Android emulator  → http://10.0.2.2:3000
  // iOS simulator     → http://localhost:3000
  // Physical device   → http://<your-PC-IP>:3000
  // Web / Desktop     → http://localhost:3000
  static const String serverUrl = 'http://10.0.2.2:3000';
}
```

Update Supabase credentials in [`lib/main.dart`](lib/main.dart) with your own project URL and publishable key:

```dart
await Supabase.initialize(
  url: "https://your-project.supabase.co",
  publishableKey: "your-publishable-key",
);
```

### Running the App

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows / macOS / Linux
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

> ⚠️ Make sure the backend server is running before launching the app. Two clients are required to test multiplayer — use two emulators/devices or a combination of platforms.

---

## State Management

The app uses **Provider** with `ChangeNotifier` for reactive state management. Two service classes act as the single source of truth:

### FlashNumbers — `GameService`

Manages the `GameState` object through a finite state machine with the following phases:

```
[idle] → joinQueue → [waiting] → match_found → [matched]
                                                    │
                                              game_start
                                                    ▼
[gameOver] ← finishGame ← [roundResult] ← [answering] ← [flashing]
```

**`GamePhase` enum:** `idle` → `waiting` → `matched` → `countdown` → `flashing` → `answering` → `roundResult` → `gameOver`

### Sudoku — `SudokuGameService`

Manages the `SudokuGameState` object:

```
[idle] → joinQueue → [waiting] → match_found → [matched]
                                                    │
                                              game_start
                                                    ▼
[gameOver] ← win/draw ← [overtime] ← tie@60s ← [playing]
```

**`SudokuGamePhase` enum:** `idle` → `waiting` → `matched` → `countdown` → `playing` → `overtime` → `gameOver`

### State Features

- **`SudokuGameState.loadPuzzleFromServer()`** — Parses incoming puzzle payloads, populates the 6×6 grid, and marks pre-filled cells as locked using `Set<(int, int)>` record tuples.
- **`GameState.reset()` / `SudokuGameState.reset()`** — Cleanly restores all properties to idle defaults between matches.

---

## Networking & Socket Protocol

### Connection

- **Transport:** WebSocket via `socket_io_client` (pure WebSocket, no HTTP long-polling)
- **Lifecycle:** `SocketService` is a **singleton** instantiated at app startup in `main.dart`
- **Reconnection:** Auto-connect is disabled; connection is explicitly established once
- **Heartbeat:** Backend uses 5000ms ping interval / 5000ms ping timeout for rapid disconnect detection

### Event Protocol

```
CLIENT                                                        SERVER
  │                                                              │
  │─── join_queue({ gameType }) ────────────────────────────────▶│
  │◀── match_found({ gameId, gameType, player2 }) ──────────────│
  │◀── game_start({ gameId, startsIn, timestamp, ... }) ────────│
  │                                                              │
  │ [FlashNumbers]                                               │
  │◀── start_round({ round, numbers, timestamp, duration }) ────│
  │─── submit_answer({ gameId, round, answer }) ────────────────▶│
  │◀── round_result({ round, victor, scores, ... }) ────────────│
  │                                                              │
  │ [Sudoku]                                                     │
  │◀── start_round({ puzzle, timestamp, duration }) ────────────│
  │─── submit_puzzle({ gameId, puzzle }) ───────────────────────▶│
  │◀── score_update({ playerId, scores }) ──────────────────────│
  │◀── puzzle_completed({ score, nextPuzzle, ... }) ────────────│
  │◀── puzzle_wrong({ reason, puzzle, score, ... }) ────────────│
  │◀── overtime({ extraTime, message }) ────────────────────────│
  │                                                              │
  │ [Terminal]                                                   │
  │◀── game_over({ scores, winner, endOfGame }) ────────────────│
  │◀── opponent_disconnected({ message }) ──────────────────────│
```

### Listener Lifecycle

`SocketService.clearGameListeners()` tears down all game-specific event listeners when a match ends or the player navigates away, preventing memory leaks and stale callbacks.

---

## Authentication

Authentication is handled via **Supabase Auth (GoTrue)** with email/password credentials.

| Component                          | Responsibility                                      |
|------------------------------------|-----------------------------------------------------|
| `AuthService`                      | Wraps `signIn`, `signUp`, `signOut` with error handling |
| `AuthGate` (StreamBuilder)         | Listens to `onAuthStateChange` — routes to Login or Home |
| `LoginBox` / `SignupBox`           | Form widgets with field validation                  |

The auth flow is:
1. App launches → `AuthGate` checks Supabase session
2. **No session** → Show `AuthScreen` (Login/Signup toggle)
3. **Session active** → Navigate to `HomePage`
4. Sign out → `AuthService.signOut()` → Stream triggers redirect to `AuthScreen`

---

## Key Algorithms

### Client-Side Sudoku Validator (`sudoku_validator.dart`)

Provides **instant visual feedback** without server round-trips:

- **`isCellValid(grid, row, col, num)`** — Checks row, column, and 2×3 subgrid constraints
- **`findConflicts(grid)`** — Returns a `Set<(int, int)>` of all conflicting cell coordinates for highlighting
- **`isGridComplete(grid)`** — Checks if all 36 cells are filled (non-zero)
- **`isGridValidAndComplete(grid)`** — Combined check triggering auto-submission

### Auto-Submit Logic

When a player fills the last empty cell and the grid has **zero conflicts**, the completed puzzle is **automatically submitted** to the server — no manual submit button needed. This is critical for the speed-solving competitive format.

### Subgrid Calculation

```dart
int startRow = (row ~/ 2) * 2;  // 2-row blocks
int startCol = (col ~/ 3) * 3;  // 3-column blocks
```

---

## Screenshots & UI Flow

The app features a dark, gaming-inspired aesthetic with the following screens:

| Screen             | Description                                               |
|--------------------|-----------------------------------------------------------|
| **Auth Screen**    | Email/password login and signup with form validation      |
| **Home Screen**    | "Bundled IQ" branding, game mode selection, sign-out      |
| **Waiting Screen** | Circular progress indicator during matchmaking queue      |
| **Countdown**      | 5-second synchronized countdown before match start        |
| **Flash Screen**   | Numbers flashing sequentially at center of screen         |
| **Answer Screen**  | Text input with countdown timer for sum submission        |
| **Sudoku Board**   | Interactive 6×6 grid with number pad and live validation  |
| **Scoreboard**     | Real-time score comparison during Sudoku matches          |
| **Victory/Defeat** | Animated result screens with final scores                 |
| **Draw Screen**    | Displayed when Sudoku overtime ends with no winner        |

---

## Testing

Run the test suite:

```bash
flutter test
```

Current coverage:
- ✅ `game_state_test.dart` — Verifies `GameState.reset()` correctly restores all default values

Run static analysis:

```bash
flutter analyze
```

> The project passes with **0 errors** (some informational warnings exist for `avoid_print` and `use_super_parameters`).

---

## Known Limitations

| Area                     | Limitation                                                                      |
|--------------------------|---------------------------------------------------------------------------------|
| **Socket Auth**          | WebSocket handshake does not transmit the Supabase JWT — player identity relies on ephemeral `socket.id` |
| **Reconnection**         | No reconnection support — a dropped connection immediately terminates the match  |
| **Hardcoded Credentials**| Supabase URL and key are hardcoded in `main.dart` (should use `--dart-define`)   |
| **Test Coverage**        | Only 1 unit test exists; no integration or widget tests                          |
| **Backend Persistence**  | All game sessions and queues are stored in volatile Node.js memory (no database) |
| **Puzzle Bug**            | Next puzzle payload arrives as `undefined` after first solve due to a key mismatch (`nextPuzzle` vs `puzzle`) in the backend |

---

## Roadmap

- [ ] 🔐 Pass Supabase JWT in Socket.IO handshake for authenticated connections
- [ ] 🔄 Implement session reconnection and recovery
- [ ] 💾 Add persistent leaderboards and match history with Supabase/Postgres
- [ ] 🧪 Expand test coverage (widget tests, integration tests, backend tests)
- [ ] 🎨 Add configurable difficulty levels for both game modes
- [ ] 🏅 Player profiles, rankings, and statistics dashboard
- [ ] 🌐 Deploy backend with containerization (Docker) and CI/CD pipeline
- [ ] 📱 Push notifications for match invitations

---

## License

This project is private and not published to pub.dev.

---

<p align="center">
  Built with ❤️ using Flutter & Dart
</p>
