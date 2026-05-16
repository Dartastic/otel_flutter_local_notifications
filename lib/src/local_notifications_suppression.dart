// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey =
    #otel_flutter_local_notifications_suppress;

bool localNotificationsInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

T runWithoutLocalNotificationsInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

Future<T> runWithoutLocalNotificationsInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}
