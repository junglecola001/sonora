# 验证与已知边界

## 验证环境

2026-10-03，Windows 11、Node.js 24.19.0。项目支持 Node.js 22+，未在本次验证中运行 Docker 或其他操作系统。

## 本地／假上游验证

执行 `npm test` 与 `npm run check`。测试不使用真实账号，包括：

- 配置、Cookie 多格式规范化、原子持久化、登出清理和失败反馈。
- 请求参数、方法、错误形状、登录校验、缓存凭据版本隔离。
- 歌曲映射、trackIds 顺序、分页、歌词时间轴。
- 实际音质、降级优先完整音频、试听、音频探测失败。
- 二维码服务端会话和不泄露 Cookie。
- API_TOKEN、CORS、限流、OpenAPI 路由一致性。
- CDN 主机名边界、非公网 DNS、票据篡改／过期、单 Range／206／416、HEAD、重定向校验、客户端断开取消。

离线通过不代表上游协议永远可用。真实账号登录、扫码确认、VIP 播放、收藏、评论与听歌上报未使用用户凭据验证；写能力仅做假上游契约测试。

## 真实 HTTP／网易云验证

使用实际 `server.js`，测试端口 3317，关闭凭据持久化，没有登录账号：

| 验证 | 结果 |
|---|---|
| 健康检查、能力、OpenAPI | HTTP 200 |
| “晴天”搜索，limit=3 | HTTP 200，返回统一歌曲模型和总数 |
| 歌曲 186016 歌词 | HTTP 200，返回原文和时间轴 |
| 热歌榜 3778678 曲目，limit=2 | HTTP 200，保持顺序，总数 200 |
| 歌曲 186016 播放解析 | HTTP 200，正确报告版权不可用／不可播放 |
| 免费歌曲 2007983648 音频验证 | 未通过；本机 CDN DNS 返回非公网 Fake-IP |
| 封面代理 | 被 DNS 地址校验拒绝，未访问该非公网地址 |

当前环境将网易云 CDN 解析为 `198.18.1.x`。服务按 SSRF 规则拒绝连接；没有放松安全校验来“做出通过结果”。需要网络工具真实 DNS 解析后再验证实际媒体传输，参见 README 的 Fake-IP 说明。代理自身的 Range 和传输行为已用受控假上游测试。

测试服务达到运行时限后停止，不遗留测试端口占用。

## 2026-10-05 账号查询增补

新增 VIP／SVIP 状态、私人推荐歌单、批量专辑收藏状态。使用假上游覆盖会员包过期、SVIP 到 VIP 转换、旧会员接口回退、未知状态、缓存与账号隔离、私人推荐字段／错误、收藏分页／扫描上限／未知状态、收藏后重新查询及查询期间退出。

本次新增功能没有使用真实账号验证；离线测试与 OpenAPI 合同验证不能代替真实 VIP／SVIP 账号联调。会员状态展示不等于单曲播放权限。

执行 `npm test`：42 项全部通过（新增 9 项账号查询测试）；`npm run check`：29 个 JavaScript 文件通过语法检查。OpenAPI 已重新生成，包含 38 个路径。

## 依赖安全

保留原同名网易云 SDK `NeteaseCloudMusicApi@4.32.0`。安装使用 `--ignore-scripts`，不运行其生命周期脚本。传递依赖覆盖：

- `basic-ftp@6.2.1`：修复已有审计告警。
- `music-metadata@11.16.1`：修复旧 ASF 解析告警；此服务并不加载上传／元数据端点。

目前 `npm audit` 仍报告 **2 项 high**：`node-forge` 的 RSA PKCS#1 v1.5 验签缺陷，以及其对上游 SDK 的传递影响。npm 当前可获取的 node-forge 最新版本 1.4.0 仍在告警范围；不对依赖目录打不可复现补丁，不执行会降级 SDK 的 `audit fix --force`。

本服务使用 node-forge 读取固定网易云公钥并执行协议加密，不调用其 RSA 验签 API；不等于依赖完全无风险。应持续跟踪修复版并更新 lockfile，部署前重新执行 `npm audit`。

上游自带 HTTP 服务、上传端点、代理支持和会输出响应 Cookie 的 util/request 不被服务使用。自有 transport 保留协议加密但限制固定域名、超时、响应大小并避免敏感日志。

## 2026-10-17 移除 Web 前端后的回归

按需求删除 `web/` React 前端工程与播放器专属文档（`docs/PLAYER_PLAN.md`、`docs/PLAYER_PROGRESS.md`、`docs/PLAYER_UI_SPEC.md`），仓库只保留后端 API。`web/scripts/verify-live.mjs` 迁移为根目录 `scripts/verify-live.mjs`（`npm run verify:live`），并新增零依赖示例 `examples/client.mjs`。

移除后重新执行：

- `npm test`：46 项全部通过（后端离线假上游测试；不再包含前端 Vitest／Playwright）。
- `npm run check`：32 个 JavaScript／ESM 文件通过语法检查。
- `npm run docs`：OpenAPI 重新生成，包含 38 个路径；`test/contracts.test.js` 校验 `docs/openapi.json` 与路由定义一致。
- 冒烟：本地启动 `server.js` 后，`GET /api/v1/health`、`/api/v1/capabilities`、`/api/v1/openapi.json` 返回 200；未配置 `API_TOKEN` 时未知路由返回统一 404 JSON（配置后未认证请求先返回 401 `UNAUTHORIZED`），错误方法返回 405。

前端 E2E、浏览器截图与 `verify:live` 的前端调用方式随 `web/` 移除；真实媒体、账号与写操作边界仍以上文记录和 `npm run verify:live` 在线验证为准。
