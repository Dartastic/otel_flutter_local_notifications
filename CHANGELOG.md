# Changelog

## [0.3.1-wip]

### Changed

- README: standard header naming the instrumented library, its supported platforms and project links; pubspec description to match.

## [0.3.0] - 2026-10-11

### Changed

- Requires `dartastic_opentelemetry_api >=1.0.0-rc.4 <1.0.0-rc.5`.
- **Breaking:** depends on `dartastic_opentelemetry_api` only, no
  longer on the SDK. The application chooses and initializes the
  OpenTelemetry SDK. Parameters and fields typed with SDK classes
  now use the API types (`APITracer`, `APISpan`, `APILogger`, ...);
  SDK instances are still accepted wherever an API type is expected.

## [0.2.0] - 2026-08-09

### Added

- `LocalNotificationsSemantics` enum + `notificationTapEventName`
  const — all emitted attribute keys and event names are now
  exported constants instead of raw string literals (keys
  unchanged on the wire).
- `example/`.

### Changed

- Widened `flutter_local_notifications` constraint to
  `>=17.0.0 <23.0.0` (the instrumentation wraps calls via
  closures and works across these majors).

## [0.1.0-beta.1] - 2026-05-16

### Added

- `tracedLocalNotificationCall<R>({operation, id, invoke})` —
  PRODUCER span around show/schedule/cancel calls. Carries
  `notification.system=flutter_local_notifications`,
  `notification.operation`, `notification.id`. The notification
  body (title/text) is intentionally NOT recorded — it often
  contains user-visible PII.
- `recordNotificationResponse({id, payload})` — adds a
  `notification.tap` event to the active span when a
  notification is tapped (call from your
  `onDidReceiveNotificationResponse` handler).
- Zone-scoped suppression
  (`runWithoutLocalNotificationsInstrumentation` / async variant).
- 3 tests.
