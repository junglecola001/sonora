# 迁移说明（历史参考）

本文件记录从旧版 `server.js` 迁移到当前纯 API 后端的差异，供旧客户端参考；新项目直接阅读 [README](../README.md) 与 [API 文档](API.md)。

## 原文件

原 `server.js` 已完整存档到 `legacy/server.original.js`。它引用的 `qq-vip-api`、`kugou-api`、`qishui-api`、DJ 分析和客户端模块不在本仓库；存档仅供对照，不能作为服务启动。

新 `server.js` 是启动入口；导入 `src/app.js` 的 `createApp()` 不监听端口。以 `npm start` 启动；依赖和环境配置现在齐全。

## 需要修改的客户端行为

1. 优先改用 `/api/v1`；保留的核心旧路径见 [API 文档](API.md#兼容旧接口)。这些是**路径别名，不是旧数据格式兼容层**。
2. JSON 业务结果统一读取 `response.data`；失败处理 HTTP 状态与 `error.code`，不要只判断 200。
3. 歌曲 `id` 统一为字符串；时长字段改成 `durationMs`，专辑改为 `{ id, name, cover }`。
4. 列表从 `data.items` 读取；使用返回的 `nextOffset`，不要按实际显示数量递增（上游可能缺失某首歌曲）。
5. 播放必须检查 `playable`、`status` 和 `restriction`；不能把搜索结果的 fee 或 Cookie 存在当作播放权限。
6. 用播放解析返回的签名 `proxyUrl`，或调用 `/media/tickets` 给封面签票。任意 URL 的 `/api/audio` 和 `/api/cover` 已移除。
7. 账号写操作改为 JSON POST／PUT／DELETE；GET 不再更改账号状态。
8. 二维码登录改为 `POST /auth/qr` + `GET /auth/qr/:sessionId`；不再把上游 key 当作客户端持久凭据。
9. 配置 CORS 白名单。远程监听必须配置长随机 API_TOKEN，客户端 API 请求传 Bearer；音频票据请求不需要 Bearer。
10. 如确实要站内同曲匹配，显式传 `allowMatch=true`，处理 `matchedSong` 和请求／实际 ID；默认不替换歌曲。
11. 原 VIP 查询逻辑迁为 `GET /auth/membership`，`/auth/status` 同时附带会员摘要；字段为 `membership/isVip/isSvip/expiresAt`，不再从头像徽章或 Cookie 推断会员。查询失败为 `unknown`，不是“无会员”。
12. 原 `recommend_resource` 私人推荐迁为 `GET /recommendations/personal-playlists`；原 `/api/album/subscribe/check` 改用 `GET /me/collections/albums/status?ids=...`。专辑查询未扫描完时返回 `null`，不要显示为未收藏。

## 不再包含

QQ、酷狗、汽水、Spotify 的接口，客户端自动更新、登录彩蛋、天气电台、Cuefield、beatmap／DJ 分析和 public 静态页面服务均不属于这套网易云音源后端。

旧 `/api/discover/home` 拆为 `/recommendations/playlists`、`/recommendations/daily` 与 `/me/playlists`，新项目按需要组合，而不是后端夹带客户端页面逻辑。

## 上游适配层

`src/netease/sdk.js` 只加载列出的协议模块，`transport.js` 负责固定官方 API 域名、加密、请求取消／响应大小限制。`client.call(method, params, snapshot)` 校验上游成功码。查询、账号、登录和播放模块只依赖这一契约。

后续更换 SDK：实现同样的 `api[method](params) -> { body, cookie? }` 形状，替换 sdk 加载层或向 `createApp` 注入 `api`，再运行假上游与真实只读回归。不需要改客户端 HTTP 契约；不要透传任意客户端 method、proxy、domain 或 Cookie 到上游。
