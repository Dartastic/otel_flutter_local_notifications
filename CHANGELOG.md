# Changelog

## [0.1.0-beta.2-wip]

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
