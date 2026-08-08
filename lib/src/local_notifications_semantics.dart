// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Name of the span event added by `recordNotificationResponse` when a
/// notification is tapped / responded to.
const String notificationTapEventName = 'notification.tap';

/// Local-notification attribute keys.
///
/// The OTel semantic-conventions registry has no `notification.*`
/// namespace yet, so these are package-local, vendor-neutral keys.
/// If the registry grows a notification convention, these can
/// `@Deprecated`-pivot to the upstream enum.
enum LocalNotificationsSemantics implements OTelSemantic {
  /// The notification backend. Always `flutter_local_notifications`
  /// for this package.
  notificationSystem('notification.system'),

  /// The wrapped operation, e.g. `show`, `schedule`, `cancel`.
  notificationOperation('notification.operation'),

  /// The plugin-level notification id, when one was supplied.
  notificationId('notification.id'),

  /// The tap payload string, set on the `notification.tap` event when
  /// the response carried one.
  notificationPayload('notification.payload');

  const LocalNotificationsSemantics(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}
