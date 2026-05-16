// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'local_notifications_suppression.dart';

const _tracerName = 'otel_flutter_local_notifications';
const _notifSystem = 'flutter_local_notifications';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

/// Generic helper. Opens a PRODUCER span named
/// `local_notif <operation> [<id>]` with notification.* attrs.
///
/// The body of the notification (title/text) is intentionally
/// NOT recorded — notifications often contain user-visible PII.
/// Only the id and operation land in the span.
Future<R> tracedLocalNotificationCall<R>({
  required String operation,
  int? id,
  required Future<R> Function() invoke,
}) async {
  if (localNotificationsInstrumentationSuppressed()) return invoke();
  final span = _tracer().startSpan(
    id == null ? 'local_notif $operation' : 'local_notif $operation $id',
    kind: SpanKind.producer,
    attributes: OTel.attributesFromMap(<String, Object>{
      'notification.system': _notifSystem,
      'notification.operation': operation,
      if (id != null) 'notification.id': id,
    }),
  );
  try {
    return await invoke();
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

/// Records a CONSUMER span event when a notification is tapped /
/// responded to. Call this from your
/// `onDidReceiveNotificationResponse` handler.
///
/// If no active span is present, the event is dropped — see the
/// pattern note in this package's README.
void recordNotificationResponse({required int? id, String? payload}) {
  if (localNotificationsInstrumentationSuppressed()) return;
  final activeSpan = Context.current.span;
  if (activeSpan == null || !activeSpan.isValid) return;
  activeSpan.addEventNow(
    'notification.tap',
    OTel.attributesFromMap(<String, Object>{
      'notification.system': _notifSystem,
      if (id != null) 'notification.id': id,
      if (payload != null) 'notification.payload': payload,
    }),
  );
}
