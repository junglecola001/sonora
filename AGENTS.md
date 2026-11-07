# AGENTS.md — Sonora 开发规范

> 修改代码前先读本文件与 [PLAN.md](PLAN.md)；接口以 [docs/API.md](docs/API.md) 为准，排期以 PLAN 为准。本文件同时约束人类与 AI Agent。

## 1. 项目定位

| 维度 | 约定 |
| --- | --- |
| 产品 | Windows 10/11 桌面音乐播放器，双音源：本地文件 + 网易云在线，单窗口、单账号 |
| UI/功能参考 | Salt Player for Windows（Steam 3009140）：侧栏信息架构、列表密度、播放页与歌词布局、音频引擎设置页 |
| 不参考 | 不复制其图片、图标、字体、皮肤或代码；不绕过会员与版权限制 |
| 仓库 | 前后端同仓：根目录为后端（Node.js + Express 5），`app/` 为 Flutter Windows 客户端 |
| 边界 | 客户端只调用 `/api/v1`，不直连网易云上游，不在前端复刻解析、回退、校验逻辑 |
| 非目标 | 多用户、云同步、Steam 工坊、移动端、macOS/Linux 首发 |

产品细节与里程碑见 [PLAN.md](PLAN.md)。

## 2. 版本与依赖（硬约束）

| 层 | 选型 | 版本 |
| --- | --- | --- |
| 后端运行时 | Node.js | `>=22.12.0`（开发机 24.19） |
| 后端框架 | Express / NeteaseCloudMusicApi | `5.1.0` / `4.32.0` |
| 客户端 | Flutter / Dart | `>=3.47.0` / `>=3.10.0`（prism_ui 要求） |
| UI | prism_ui | `0.1.2`，精确 pin |
| 音频 | media_kit（libmpv） | `1.2.6`，M1 实证后定稿 |
| 本地库 | drift | `2.35.3` |
| 窗口 / 托盘 / 热键 | window_manager / tray_manager / hotkey_manager | `0.6.0` / `0.8.3` / `0.3.0` |
| 系统媒体控制 | smtc_windows | `1.1.0`（基于 flutter_rust_bridge，构建机可能需 Rust） |
| 敏感配置 | flutter_secure_storage | `11.2.0`（Windows 走 DPAPI） |
| 构建环境 | Windows 10 1903+ x64，Visual Studio 2022「使用 C++ 的桌面开发」 | — |

- 升级依赖单独提交，写明动机与影响面；prism_ui 每次升级都要人工回归受影响页面。
- **许可证**：prism_ui 是 GPL-3.0。客户端链接它后整体按 GPL-3.0 分发，发布二进制必须同时提供完整对应源码。后端是独立进程、通过 HTTP 通信，可单独授权。仓库 LICENSE 方案未定（见 PLAN §11），发布前必须落地。
- 不引入 Material/Cupertino 适配层，也不为 prism_ui 写"通用兜底组件库"；缺什么就在 `lib/ui/` 里做一个明确的组件。

## 3. 目录结构

```text
sonora/
├── server.js, src/, test/, docs/     后端（Node.js，仓库根目录）
├── app/                              Flutter Windows 客户端（M0 创建）
│   └── lib/                          main.dart、app/、core/、features/、ui/
├── scripts/, examples/, legacy/      后端工具、接入示例、原始服务存档
├── AGENTS.md  PLAN.md  README.md
```

- 后端按现有分层：`src/core` 纯逻辑、`src/netease` 上游协议、`src/http` 传输层。
- 前端只在 `app/` 内开发，按 feature 分目录；禁止建"万能 utils"。
- `docs/openapi.json` 由 `npm run docs` 生成，禁止手改。
- `docs/VERIFICATION.md` 只追加，不改写历史条目。

## 4. 常用命令

| 目标 | 命令 |
| --- | --- |
| 后端安装 | `npm ci --ignore-scripts` |
| 后端开发 | `npm run dev` |
| 后端测试 | `npm test`（等价的 `node --test test/*.test.js`，46 项） |
| 后端语法检查 | `npm run check` |
| 重生成 OpenAPI | `npm run docs` |
| 在线只读联调 | `npm run verify:live` |
| 客户端安装 | `cd app && flutter pub get` |
| 客户端运行 | `flutter run -d windows` |
| 客户端检查/测试 | `flutter analyze`、`flutter test` |
| 客户端发布构建 | `flutter build windows --release` |

提交前最低要求：改后端 → `npm test` + `npm run check`；改接口 → `npm run docs` 并提交生成结果；改前端 → `flutter analyze` + `flutter test`。

## 5. 后端规范

- CommonJS + `'use strict'`，2 空格缩进、单引号、分号；无编译步骤。
- 新能力"五件套"缺一不可：service 方法、路由、`src/http/openapi.js`、`docs/API.md`、测试。
- 错误统一 `new AppError(CODE, 中文文案, status)`；`code` 稳定，客户端按 `code` 分支，禁止用文案做判断。
- 上游访问只走 `NeteaseClient`/transport；CDN 白名单、DNS 校验、票据签名、Range 规则不得放宽或绕过。
- 成功响应固定 `{ success, data, requestId }`；参数校验放 `src/http/validation.js`，新增分页参数必须有上下界。
- 不引入数据库；账号凭据只落 `data/netease.cookie`（可关闭持久化）。日志与错误信息不得出现 Cookie、直链 `url`、ticket。
- 测试用假上游，不联网、不依赖真实账号；真实联调走 `npm run verify:live`。

## 6. 客户端规范

### 结构

```text
app/lib/
├── main.dart
├── app/          启动、依赖装配、路由、主题、外壳
├── core/
│   ├── audio/    播放引擎抽象（本地/在线同一接口）
│   ├── backend/  /api/v1 客户端、错误码映射、票据刷新
│   ├── db/       drift 本地库与迁移
│   ├── platform/ 窗口、SMTC、托盘、热键、单实例、文件关联
│   └── settings/ 配置读写
├── features/     每页一个目录（library、now_playing、lyrics、online、search、settings…），内部分 data/domain/ui
└── ui/           主题 token 与 prism_ui 通用封装
```

### UI

- 只用 prism_ui：不 import `material.dart` / `cupertino.dart`，基础件用 `widgets.dart`；命名冲突用 `hide` 或前缀。
- 颜色、圆角、字重、动效时长全部来自 `ColorScheme`/主题或 `ui/` token；禁止散落 `Color(0xFF…)` 与 `Duration(...)` 字面量。
- 布局遵循 Salt Player 的信息层级：左侧固定 `NavigationSidebar` + 主区大标题/操作行 + 56px 行高虚拟化列表 + 底部 `LiquidGlass` 播放栏 + 播放页（模糊封面背景 + 歌词列）。区域与组件映射见 PLAN §6。
- 桌面优先：hover/pressed/focus 三态齐全；右键菜单；Tab 顺序与焦点环；Esc 返回；空格播放/暂停；方向键切歌与音量。快捷键集中定义在 `core/platform`。
- 文案进 `lib/l10n`（ARB），widget 内不硬编码；首发中文，英文补键同步。

### 音频

- 播放状态唯一来源是 `PlaybackController`；UI 只订阅，不直接触碰引擎。
- 引擎实现收敛在 `core/audio`，对外只有 `load/play/pause/seek/volume/preload/next`；换引擎不改 UI。
- 在线曲目只用 `proxyUrl`（票据默认 300s 有效，seek 或播放前检查过期并重取一次）；不缓存直链 `url`，音频不写磁盘（离线缓存是待定需求）。
- 队列预载下一首实现无间隙；切歌可取消，过期回调必须丢弃。

### 数据与性能

- 本地库用 drift，迁移只增不改；库管理"只增不删"：文件缺失标记 `missing`，不自动清理。
- 远端数据不落库；收藏/喜欢按需查询并做短 TTL 缓存。
- 列表用 slivers 虚拟化；封面按显示尺寸解码 + 磁盘缩略图 LRU；标签解析在后台 isolate，不阻塞 UI。

### 安全

- 后端默认绑定 `127.0.0.1` 且不启用 Token；客户端如需 Token，用 `flutter_secure_storage`（DPAPI）保存，不写明文配置或日志。
- 账号 Cookie 只导入后端；客户端不落盘、不回显。
- 日志与崩溃信息脱敏，禁止输出 Token、Cookie、ticket。

## 7. 提交与协作

- Conventional Commits（`feat`/`fix`/`docs`/`refactor`/`test`/`chore`/`build`），正文中文，写清动机与验证方式。
- 一个提交一个主题；格式化、重命名与功能改动分开。
- `main` 保持可运行；不建长寿命分支。个人项目直推 `main`，但推送前本地检查必须通过。
- 不提交：`node_modules/`、`.env*`、`data/`、`*.cookie`、`app/build/`、`app/.dart_tool/`、构建产物与大二进制。
- 不删除 `legacy/`，不改写 `docs/VERIFICATION.md` 历史。
- 文档随代码同提交：接口、命令、目录、里程碑变化必须同步。

## 8. 完成定义

- 功能完成 = 可观察行为 + 冒烟或测试证据 + 文档更新。
- 播放/音频改动必须真机冒烟：载入 → 播放 → 暂停 → seek → 切歌 → 退出，并核对日志与采样率显示。
- 不写只验证 mock 转发、源码文本或"不抛异常"的测试；不声称未实测的音质、独占、DSD 能力。
- 平台或上游能力不确定时，先写最小验证脚本，结论进 `docs/`，再定实现。

## 9. Agent 工作方式

- 动工前读 AGENTS.md、PLAN.md 与 `docs/API.md` 相关段落；不凭记忆改接口或命令。
- 不夹带任务外重构；发现的必要清理单独提交，并在回复中说明原因。
- 结论给证据：命令输出、日志、文件路径、测试数量，不用"应该可以"代替验证。
