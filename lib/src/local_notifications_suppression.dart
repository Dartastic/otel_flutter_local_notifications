// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey = #otel_flutter_local_notifications_suppress;

/// Whether local-notification instrumentation is suppressed in the
/// current [Zone] (see [runWithoutLocalNotificationsInstrumentation]).
bool localNotificationsInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

/// Runs [body] with local-notification instrumentation suppressed:
/// no spans are opened and no tap events are recorded inside it.
T runWithoutLocalNotificationsInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

/// Async variant of [runWithoutLocalNotificationsInstrumentation].
Future<T> runWithoutLocalNotificationsInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}
