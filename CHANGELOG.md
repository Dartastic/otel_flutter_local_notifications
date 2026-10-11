# Changelog

## [1.0.0-wip]

### Changed

- Requires `dartastic_opentelemetry ^1.1.0-beta.17` and
  `dartastic_opentelemetry_api >=1.0.0-rc.4 <1.0.0-rc.5`.
- First 1.0 release: the public API of this package is stable and
  follows semantic versioning from here on.

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
