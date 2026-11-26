import 'package:camera_guide/main.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _EmptyCameraPlatform extends CameraPlatform {
  int availableCameraCalls = 0;

  @override
  Future<List<CameraDescription>> availableCameras() async {
    availableCameraCalls++;
    return [];
  }
}

void main() {
  testWidgets('camera guide starts with a minimal camera screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byTooltip('Choose guide image'), findsOneWidget);
    expect(find.byTooltip('Switch camera'), findsOneWidget);
    expect(find.byTooltip('Take photo'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0.45);

    final stageSize = tester.getSize(find.byKey(const Key('camera-stage')));
    final viewportSize =
        tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(stageSize, viewportSize);
  });

  testWidgets('slider changes the guide image opacity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pump();

    final opacity = tester.widget<Opacity>(
      find.byKey(const Key('guide-overlay-opacity')),
    );
    expect(opacity.opacity, greaterThan(0.45));
    expect(tester.widget<Slider>(find.byType(Slider)).value, opacity.opacity);
  });

  testWidgets('camera stage adapts to landscape rotation', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    tester.view.physicalSize = const Size(800, 400);
    await tester.pump();

    final stageSize = tester.getSize(find.byKey(const Key('camera-stage')));
    final viewportSize =
        tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(stageSize, viewportSize);
  });

  testWidgets('camera initialization retries when the app resumes', (
    WidgetTester tester,
  ) async {
    final previousPlatform = CameraPlatform.instance;
    final cameraPlatform = _EmptyCameraPlatform();
    CameraPlatform.instance = cameraPlatform;
    addTearDown(() => CameraPlatform.instance = previousPlatform);

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(cameraPlatform.availableCameraCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(cameraPlatform.availableCameraCalls, 2);
  });
}
