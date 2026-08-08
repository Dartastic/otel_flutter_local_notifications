# otel_flutter_local_notifications example

```dart
// example/lib/main.dart

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otel_flutter_local_notifications/otel_flutter_local_notifications.dart';

final fln = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Bring up OTel before any notification work so spans have a
  //    tracer provider to land on.
  await OTel.initialize(
    serviceName: 'local-notifications-demo',
  );

  // 2. Initialize the plugin, bridging taps into the active span.
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await fln.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      // ✨ Event: `notification.tap` on the active span, with
      //    `notification.id` / `notification.payload`.
      recordNotificationResponse(
        id: response.id,
        payload: response.payload,
      );
      // ... your handler
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _showReminder,
            child: const Text('Remind me'),
          ),
        ),
      ),
    );
  }
}

Future<void> _showReminder() async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails('reminders', 'Reminders'),
  );

  // ✨ Span: `local_notif show 42` (PRODUCER) with
  //    `notification.system=flutter_local_notifications`,
  //    `notification.operation=show`, `notification.id=42`.
  //
  //    The notification body (title/text) is intentionally NOT
  //    recorded — it often contains user-visible PII.
  await tracedLocalNotificationCall<void>(
    operation: 'show',
    id: 42,
    invoke: () => fln.show(42, 'Reminder', 'Stand up!', details),
  );

  // Same pattern for schedule / cancel:
  //   tracedLocalNotificationCall(operation: 'cancel', id: 42,
  //       invoke: () => fln.cancel(42));
}
```

## Trace shape

```
tap "Remind me"
  local_notif show 42            (PRODUCER)

(later, when the user taps the notification, inside your active span)
  <your span>
    event: notification.tap      notification.id=42
```

Attribute keys are exposed as the `LocalNotificationsSemantics` enum;
suppression is available via
`runWithoutLocalNotificationsInstrumentationAsync`.
