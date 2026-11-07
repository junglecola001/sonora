# Sonora 客户端（Flutter Windows）

UI 全部基于 [prism_ui](https://github.com/chen08209/prism_ui)，只跑 Windows 桌面。仓库根目录是后端音源服务，客户端在这里；整体规范见根目录 [AGENTS.md](../AGENTS.md)，排期见 [PLAN.md](../PLAN.md)。

## 运行

```powershell
flutter pub get
flutter run -d windows
flutter analyze
flutter test
```

需要 Flutter 3.47+、Visual Studio 2022「使用 C++ 的桌面开发」。原生库（window_manager、media_kit、SMTC）依赖该工具链，未安装时只能跑 `flutter analyze` 与 `flutter test`。

## 当前状态（M0）

- 自绘外壳：标题栏、272px 资料库侧栏、主区页面、88px 播放栏骨架。
- prism_ui 主题（深色 `tinted`，种子色 `#4CC2FF`），自绘 Glyph 图标集（`lib/ui/icons.dart`）。
- 播放控制是占位，未接音频引擎；无边框窗口与窗口按钮在 M5 接入。

## 目录

```text
lib/
├── app/          启动、主题、本地化
├── features/     页面（shell 已建，其余在 M2/M3 填）
├── ui/           主题 token、图标、侧栏、标题栏、播放栏
└── main.dart
```

## Windows ARM64 说明

本机是 Windows on ARM64，Flutter 官方分发的 `flutter_tools.snapshot` 是 x64 AOT，直接运行会在项目命令上长时间空转。可下载 Dart Windows ARM64 SDK 后自行构建内核快照：

```powershell
dart pub get -C <flutter>/packages/flutter_tools
dart --snapshot=<flutter>/bin/cache/flutter_tools_arm64.snapshot --snapshot-kind=kernel `
  <flutter>/packages/flutter_tools/bin/flutter_tools.dart
dart <flutter>/bin/cache/flutter_tools_arm64.snapshot test
```

没有 Visual Studio 时不要跑 `flutter run`/`flutter build windows`。
