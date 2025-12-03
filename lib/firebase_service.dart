import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  // Rujukan ke path /sensors dalam Realtime Database (RTDB)
  final DatabaseReference _sensorRef =
  FirebaseDatabase.instance.ref().child('sensors');

  // Rujukan ke path /commands untuk remote control
  final DatabaseReference _commandsRef =
  FirebaseDatabase.instance.ref().child('commands');

  // Stream untuk sensor data
  Stream<Map<String, dynamic>> getSensorDataStream() {
    return _sensorRef.onValue.map((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return data;
      } else {
        return {};
      }
    });
  }

  // Fungsi untuk hantar feed command ke Arduino
  Future<void> sendFeedCommand({
    Duration duration = const Duration(seconds: 2),
  }) async {
    try {
      await _commandsRef.child('feed').set(true);
      print('✅ Feed command sent to Firebase');

      // Auto reset feed flag to false after brief delay (edge-trigger)
      Future.delayed(duration, () async {
        try {
          await _commandsRef.child('feed').set(false);
          print('⏱️ Feed flag auto-reset to FALSE');
        } catch (e) {
          print('❌ Error resetting feed flag: $e');
        }
      });
    } catch (e) {
      print('❌ Error sending feed command: $e');
      rethrow;
    }
  }

  // Fungsi untuk hantar pump command ke Arduino
  Future<void> sendPumpCommand({
    Duration duration = const Duration(minutes: 5),
  }) async {
    try {
      // Turn pump ON
      await _commandsRef.child('pump').set(true);
      print('✅ Pump command sent to Firebase (ON)');

      // Schedule an automatic OFF after the specified duration
      // This relies on the app process being alive. For a backend-guaranteed
      // cutoff, implement the timer on the device or via Cloud Functions.
      Future.delayed(duration, () async {
        try {
          await _commandsRef.child('pump').set(false);
          print('⏱️ Pump auto-off after ${duration.inMinutes} minutes');
        } catch (e) {
          print('❌ Error auto-turning pump OFF: $e');
        }
      });
    } catch (e) {
      print('❌ Error sending pump command: $e');
      rethrow;
    }
  }
}