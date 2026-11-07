import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonora/app/app.dart';

void main() {
  testWidgets('外壳渲染侧栏、页面与播放栏', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SonoraApp());
    await tester.pumpAndSettle();

    expect(find.text('歌曲'), findsWidgets);
    expect(find.text('曲风'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('未在播放'), findsOneWidget);
    expect(find.text('从资料库或在线搜索开始'), findsOneWidget);
    expect(find.text('M2 接入本地曲库与在线音源'), findsOneWidget);
  });

  testWidgets('切换侧栏导航会切换页面标题', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SonoraApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('音频引擎、账号与界面'), findsOneWidget);
  });
}
