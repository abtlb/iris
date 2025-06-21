import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/storage/storage.dart';
import 'package:untitled3/features/chat/data/models/message.dart';
import 'package:logging/logging.dart';

import '../../../../core/env.dart';

class ChatService {
  late HubConnection _hubConnection;
  final SecureStorage secureStorage;
  bool _isConnecting = false;
  String? username;
  String? token;

  ChatService({required this.secureStorage});

  Future<void> connect() async {
    if (_isConnecting) {
      print("Connection is already in progress or connected.");
      return; // Prevent multiple attempts
    }

    _isConnecting = true; // Set flag
    print("Setting _isConnecting to true"); // Log for debugging

    username = await secureStorage.getUsername();
    token = await secureStorage.getToken();
    String url = '$chatBaseURL/ChatHub?userId=$username&access_token=$token';
    print(url);

    // Configure the logging
    Logger.root.level = Level.ALL;
    // Writes the log messages to the console
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

// If you want only to log out the message for the higer level hub protocol:
    final hubProtLogger = Logger("SignalR - hub");

    // _hubConnection = HubConnectionBuilder()
    //     .withUrl(url,  options: HttpConnectionOptions(
    //     transport: HttpTransportType.LongPolling,
    //     requestTimeout: 2000,
    //   )).configureLogging(hubProtLogger)
    //     .build();
    //
    //
    // while(_hubConnection.state != HubConnectionState.Connected) {
    //   try {
    //     await _hubConnection.start()?.timeout(
    //         const Duration(seconds: 2),
    //       onTimeout: () {print("timedout");}
    //     );
    //     print("Connected to SignalR");
    //   } catch (e) {
    //     print("Error connecting to SignalR: $e");
    //   }
    // }
    _hubConnection = HubConnectionBuilder()
        .withUrl(url,  options: HttpConnectionOptions(
        transport: HttpTransportType.LongPolling,
        requestTimeout: 2000 // Still the poll request timeout
    )).configureLogging(hubProtLogger)
        .build();

    // Initial connection attempt
    // try {
    //   await _hubConnection.start();
    //   print("Connected to SignalR");
    //   _isConnecting = false; // Reset flag on failure
    //   print("Setting _isConnecting to false");
    //   return; // Exit after successful connection
    // } catch (e) {
    //   print("Error connecting to SignalR: $e");
    //   _isConnecting = false; // Reset flag on failure
    //   print("Setting _isConnecting to false on failure");
    //   // Fall through to retry logic
    // }

    // Retry logic with a limit
    int retryCount = 0;
    const int maxRetries = 5; // Define a maximum number of retries

    while(_hubConnection.state != HubConnectionState.Connected && retryCount < maxRetries) {
      retryCount++;
      print("Attempting to reconnect (Attempt $retryCount of $maxRetries)...");
      try {
        // Keep the Future timeout if you want to detect hangs, but understand its purpose
        await _hubConnection.start()?.timeout(const Duration(seconds: 5), onTimeout: () async{ // Increased Future timeout slightly for retry
          print("Start Future timed out during retry.");
          _hubConnection = HubConnectionBuilder()
              .withUrl(url,  options: HttpConnectionOptions(
              transport: HttpTransportType.LongPolling,
              requestTimeout: 2000 // Still the poll request timeout
          )).configureLogging(hubProtLogger)
              .build();
          // No need to call stop() here, the timeout exception will be caught below
          throw TimeoutException('Connection start timed out during retry');
        });
        print("Connected to SignalR after retry!");
        _isConnecting = false; // Reset flag on failure
        print("Setting _isConnecting to false");
        // If successful, the loop condition becomes false and exits
      } catch (e) {
        print("Error connecting to SignalR during retry: $e");
        // The loop continues if the state is still not Connected
      }

      // If still not connected AND we haven't reached max retries, wait before the next attempt
      if (_hubConnection.state != HubConnectionState.Connected && retryCount < maxRetries) {
        // Implement a backoff strategy for better retry behavior (optional but recommended)
        // For example, wait longer with each failed attempt
        int delayMilliseconds = 500 * retryCount; // Wait 0.5s, 1s, 1.5s, etc.
        //print("Connection failed, waiting ${delayMilliseconds}ms before next retry...");
        //await Future.delayed(Duration(milliseconds: delayMilliseconds));
      } else if (_hubConnection.state != HubConnectionState.Connected && retryCount >= maxRetries) {
        print("Max retry attempts reached. Connection failed.");
        _isConnecting = false; // Reset flag on failure
        print("Setting _isConnecting to false");
        // You might want to throw an exception or update a UI state here
        // indicating that the connection failed permanently after retries.
      }
    }
    print("Exited connection loop. Final Connection state: ${_hubConnection.state}");
    if (_hubConnection.state != HubConnectionState.Connected) {
      // Handle the case where connection ultimately failed after retries
      print("Failed to connect to SignalR after multiple retries.");
      // Consider disposing the connection or showing an error to the user
    }
  }


  void sendMessage(ChatMessageModel message) {
    _hubConnection.invoke('SendMessage', args: [message.sender, message.receiver, message.message]);
  }

  void displayMessage(ChatMessageModel message) {
    _hubConnection.invoke('DisplayMessage', args: [message.sender, message.receiver, message.message]);
  }


  /// Registers a listener for incoming messages.
  void onMessageReceived(void Function(ChatMessageModel) callback) {
    _hubConnection.on('ReceiveMessage', (List<Object?>? args) {
      if (args == null || args.length < 4) throw Exception("Message received with wrong formatting");

      final sender   = args[0] as String;
      final receiver = args[1] as String;
      final content  = args[2] as String;
      final rawTime  = args[3] as String;
      final time     = DateTime.parse(rawTime).toLocal();

      callback(ChatMessageModel(
        sender:   sender,
        receiver: receiver,
        message:  content,
        time:     time,
      ));
    });
  }

  void onDisplayMessageReceived(void Function(ChatMessageModel) callback) {
    _hubConnection.on('DisplayMessage', (List<Object?>? args) {
      if (args == null || args.length < 4) throw Exception("Message received with wrong formatting");

      final sender   = args[0] as String;
      final receiver = args[1] as String;
      final content = args[2] as String;
      final rawTime  = args[3] as String;
      final time     = DateTime.parse(rawTime).toLocal();

      callback(ChatMessageModel(
        sender:   sender,
        receiver: receiver,
        message:  content,
        time:     time,
      ));
    });
  }


  Future<List<ChatMessageModel>> loadMessages(String senderId, String receiverId) async {
    // Ensure connection is established before invoking the method.
    await connect();

    // Create a completer that will complete when the messages are received.
    final completer = Completer<List<ChatMessageModel>>();

    // Set up a listener for the "LoadMessages" event.
    _hubConnection.on('LoadMessages', (arguments) {
      // Assuming the server sends back a list as the first argument.
      if (arguments != null && arguments.isNotEmpty) {
        final messagesList = arguments[0] as List;
        final messages = messagesList
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
        completer.complete(messages);
      } else {
        completer.completeError("No messages received");
      }
    });

    try {
      // Invoke the "LoadMessages" method on the hub.
      await _hubConnection.invoke("LoadMessages", args: [senderId, receiverId]);
    } catch (e) {
      // In case of an error, complete the completer with an error.
      if (!completer.isCompleted) {
        completer.completeError("Error loading messages: $e");
      }
    }

    // Return the Future that completes when messages are received.
    return completer.future;
  }


  Future<void> disconnect() async {
    await _hubConnection.stop();
  }
}
