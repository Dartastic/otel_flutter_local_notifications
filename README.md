# otel_flutter_local_notifications

OpenTelemetry instrumentation for
[`package:flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications).

```dart
final fln = FlutterLocalNotificationsPlugin();

// Show: wrap in a traced call
await tracedLocalNotificationCall<void>(
  operation: 'show',
  id: 42,
  invoke: () => fln.show(42, 'Title', 'Body', notificationDetails),
);

// Tap: bridge into your active span
await fln.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (response) {
    recordNotificationResponse(
      id: response.id,
      payload: response.payload,
    );
    // ... your handler
  },
);
```

Each call opens a PRODUCER span named `local_notif <op> <id>`
with `notification.system=flutter_local_notifications`,
`notification.operation`, `notification.id`.

**Notification body (title/text) is intentionally not recorded**
— it often contains user-visible PII.

Suppression: `runWithoutLocalNotificationsInstrumentationAsync`.

## License

Apache 2.0
