import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:math_multiplayer/config/app_config.dart';

/// Singleton service that manages the Socket.IO connection to the game server.
///
/// Usage:
///   SocketService().connect();
///   SocketService().joinQueue();
///   SocketService().onMatchFound((data) { ... });
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  /// Returns the underlying socket (throws if not connected).
  IO.Socket get socket {
    if (_socket == null) {
      throw StateError('SocketService.connect() has not been called yet.');
    }
    return _socket!;
  }

  /// Whether the socket is currently connected.
  bool get isConnected => _socket?.connected ?? false;

  // ---------------------------------------------------------------------------
  // Server URL
  // ---------------------------------------------------------------------------
  // Android emulator  → http://10.0.2.2:3000
  // iOS simulator     → http://localhost:3000
  // Physical device   → http://<your-PC-local-IP>:3000
  // Web / Desktop     → http://localhost:3000
  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  /// Opens a Socket.IO connection to [_serverUrl].
  void connect() {
    if (_socket != null) return; // already initialised

    _socket = IO.io(AppConfig.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('[SocketService] Connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('[SocketService] Disconnected');
    });

    _socket!.onConnectError((error) {
      print('[SocketService] Connection error: $error');
    });

    _socket!.onError((error) {
      print('[SocketService] Error: $error');
    });
  }

  /// Disconnects and disposes the socket.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ---------------------------------------------------------------------------
  // Client → Server events
  // ---------------------------------------------------------------------------

  /// Tell the server we want to join the matchmaking queue.
  void joinQueue() {
    socket.emit('join_queue');
  }

  /// Tell the server we want to leave the matchmaking queue.
  void leaveQueue() {
    socket.emit('leave_queue');
  }

  /// Submit the player's answer for the current round.
  void submitAnswer(int gameId, int answer, int round) {
    socket.emit('submit_answer', {
      'gameId': gameId,
      'answer': answer,
      'round': round,
    });
  }

  // ---------------------------------------------------------------------------
  // Server → Client event listeners
  // ---------------------------------------------------------------------------

  void onMatchFound(Function(dynamic) callback) {
    socket.on('match_found', callback);
  }

  void onGameStart(Function(dynamic) callback) {
    socket.on('game_start', callback);
  }

  void onStartRound(Function(dynamic) callback) {
    socket.on('start_round', callback);
  }

  void onRoundResult(Function(dynamic) callback) {
    socket.on('round_result', callback);
  }

  void onGameOver(Function(dynamic) callback) {
    socket.on('game_over', callback);
  }

  void onOpponentDisconnected(Function(dynamic) callback) {
    socket.on('opponent_disconnected', callback);
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Remove all game-related listeners.
  /// Call this when the player leaves the game screen.
  void clearGameListeners() {
    const events = [
      'match_found',
      'game_start',
      'start_round',
      'round_result',
      'opponent_disconnected',
    ];

    for (final event in events) {
      socket.off(event);
    }
  }
}
