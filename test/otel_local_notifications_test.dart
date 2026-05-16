// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otel_flutter_local_notifications/otel_flutter_local_notifications.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

Map<String, Object> _attrs(Span span) =>
    {for (final a in span.attributes.toList()) a.key: a.value};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('local notifications OTel', () {
    late _MemorySpanExporter exporter;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'local-notif-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    test('tracedLocalNotificationCall emits PRODUCER span with id', () async {
      await tracedLocalNotificationCall<void>(
        operation: 'show',
        id: 42,
        invoke: () async {},
      );

      final span = exporter.spans.single;
      expect(span.kind, equals(SpanKind.producer));
      expect(span.name, equals('local_notif show 42'));
      final attrs = _attrs(span);
      expect(
          attrs['notification.system'], equals('flutter_local_notifications'));
      expect(attrs['notification.operation'], equals('show'));
      expect(attrs['notification.id'], equals(42));
    });

    test('recordNotificationResponse adds event to active span', () async {
      await OTel.tracer().startActiveSpanAsync<void>(
        name: 'app',
        fn: (_) async {
          recordNotificationResponse(id: 42, payload: 'open:cart');
        },
      );
      final span = exporter.spans.firstWhere((s) => s.name == 'app');
      final events = span.spanEvents ?? [];
      final tap = events.firstWhere((e) => e.name == 'notification.tap');
      final tapAttrs = {
        for (final a in (tap.attributes?.toList() ?? <Attribute<Object>>[]))
          a.key: a.value,
      };
      expect(tapAttrs['notification.id'], equals(42));
      expect(tapAttrs['notification.payload'], equals('open:cart'));
    });

    test('runWithoutLocalNotificationsInstrumentationAsync bypasses spans',
        () async {
      await runWithoutLocalNotificationsInstrumentationAsync(() async {
        await tracedLocalNotificationCall<void>(
          operation: 'show',
          id: 1,
          invoke: () async {},
        );
      });
      expect(exporter.spans, isEmpty);
    });
  });
}
