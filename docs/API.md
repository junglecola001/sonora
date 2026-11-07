# API 参考

Base URL：`http://127.0.0.1:3000/api/v1`。本服务只提供 HTTP API，前端界面由同仓客户端工程实现；以下接口适用于任意 Web、桌面、移动或命令行客户端。可直接运行 [examples/client.mjs](../examples/client.mjs) 验证搜索、音源、歌词与封面链路。

所有 JSON 成功响应：

```json
{ "success": true, "data": {}, "requestId": "uuid" }
```

所有参数都校验：分页默认 `limit=20,offset=0`，limit 为 1..100，offset 为 0..1000000；上游不提供总数时 `total=null`。歌单名最多 40 字符、评论最多 500 字符、关键词最多 200 字符，批量 ID 最多 100 个，听歌 seconds 为 1..86400。请求体必须为 JSON 对象，最大 64KB。

除 `/health` 与签名媒体 GET／HEAD 外，配置 API_TOKEN 后所有接口都需 Bearer。未配置时默认只允许回环监听。浏览器请求还需要配置 CORS_ORIGINS。

失败响应统一为 HTTP 非 2xx：

```json
{ "success": false, "error": { "code": "INVALID_ARGUMENT", "message": "..." }, "requestId": "uuid" }
```

完整机器可读定义见 `GET /api/v1/openapi.json`。接口 ID、URL 和 Cookie 均应按字符串处理；单个 ID 只接受正整数。

## 公开曲库

| 方法 | 路径 | 查询／请求体 | 说明 |
|---|---|---|---|
| GET | `/health` | — | 仅服务进程健康，不探测上游 |
| GET | `/capabilities` | — | 当前版本能力与边界 |
| GET | `/search` | `keywords` 必填；`limit` 1..100；`offset` | 搜索歌曲。返回 `items,total,limit,offset,nextOffset,hasMore` |
| GET | `/songs` | `ids=1,2,3` | 最多 100 首，响应顺序与有效 ID 输入顺序一致 |
| GET | `/songs/:id` | — | 歌曲、艺人、专辑、封面、时长和 `fee` |
| GET | `/songs/:id/lyrics` | — | `original/translated/romanized/wordByWord/lines`。`lines` 是从原文 `[mm:ss.xx]` 解析的近似时间轴 |
| GET | `/songs/:id/comments` | `limit,offset` | 评论分页；第一页另有 `hot` |
| GET | `/playlists/:id` | — | 公开歌单元数据 |
| GET | `/playlists/:id/tracks` | `limit,offset` | 先恢复 `trackIds`，再批量详情，保证顺序；`missingIds` 表示上游缺失详情 |
| GET | `/albums/:id` | — | 专辑和歌曲 |
| GET | `/artists/:id` | `limit,offset` | 歌手信息和热门歌曲 |
| GET | `/recommendations/playlists` | `limit` | 公开推荐歌单 |
| GET | `/podcasts/search` | `keywords,limit,offset` | 播客搜索 |
| GET | `/podcasts/hot` | `limit,offset` | 热门播客 |
| GET | `/podcasts/:id` | — | 播客详情 |
| GET | `/podcasts/:id/programs` | `limit,offset` | 节目列表；节目 `song.id` 可继续请求播放解析 |

歌曲模型示例：

```json
{
  "provider": "netease", "id": "186016", "name": "晴天",
  "artist": "周杰伦", "artists": [{ "id": "6452", "name": "周杰伦" }],
  "album": { "id": "18965", "name": "叶惠美", "cover": "https://..." },
  "cover": "https://...", "durationMs": 269000, "fee": 0, "popularity": 100
}
```

## 播放解析

`GET /songs/:id/playback?quality=hires&allowMatch=false`

`quality` 可为 `standard`、`exhigh`、`lossless`、`hires` 或 `jymaster`，服务从请求档位向下尝试；响应中的 `quality` 是**实际成功档位**，不会把请求的 `hires` 冒充成实际无损。

```json
{
  "id": "186016", "requestedId": "186016", "resolvedId": "186016",
  "status": "full", "playable": true, "trial": false,
  "url": "https://...", "proxyUrl": "/api/v1/media/audio?ticket=...",
  "requestedQuality": "hires", "quality": "standard", "bitrate": 128000,
  "format": "mp3", "expiresAt": 1730000000000, "verified": true,
  "matched": false, "restriction": null
}
```

- `status=full`：本次上游返回完整音频并通过探测。
- `status=trial`：只能试听，`restriction.code=TRIAL_ONLY`。
- `status=unavailable`：无可播放 URL；常见 `COPYRIGHT_UNAVAILABLE`、`ENTITLEMENT_REQUIRED`、`URL_UNAVAILABLE`。
- `verified=false`：配置关闭 `PROBE_AUDIO`，不能据此认为直链有效。
- `AUDIO_PROBE_FAILED` 可附带安全的 `error.details.reason`：`fake_ip`、`non_public_dns`、`timeout`、`invalid_audio`、`http_error`、`connection_failed` 或 `unknown`。其中 `fake_ip` 需在网络工具中对网易云 CDN 使用真实 DNS；这些诊断不会放宽媒体校验或返回音频 URL。
- `url` 是上游直链，不应长期存储或展示；客户端应优先使用 `proxyUrl`。代理票据短期有效。
- `allowMatch=true` 才允许以歌名、艺人和时长匹配网易云站内另一个 ID。返回 `matched=true`、`requestedId`、`resolvedId`、`matchedSong`、`matchBasis` 和 `originalRestriction`；这不是音频指纹证明，默认关闭，不能静默换录音。
- `status=unavailable` 时 `url`、`proxyUrl`、`quality` 为 `null`，不包含 `bitrate`／`format`／`size`／`expiresAt`，可能带 `verificationFailed`；`status=trial` 时额外给出 `trialInfo`。
- 会员／地区／版权限制不被绕过。上游不提供音源时返回结构化不可播放，而不是伪造 URL。

客户端播放：

```js
const response = await fetch(`${base}/songs/${id}/playback?quality=exhigh`);
const { data } = await response.json();
if (data.playable) audio.src = new URL(data.proxyUrl, base);
```

## 登录和账号

本服务仅一个共享网易云账号。账号接口在 `API_TOKEN` 配置后需要：

```http
Authorization: Bearer <API_TOKEN>
```

### Cookie 登录

`POST /auth/cookie`：

```json
{ "cookie": "MUSIC_U=...; __csrf=..." }
```

服务先调用网易云验证，只有确认账号有效后才保存。响应只返回账号摘要，绝不返回 Cookie。Cookie 可能是字符串、浏览器 Cookie 对象或对象数组，但应尽量传 Cookie header 字符串。

### 扫码登录

1. `POST /auth/qr`，保存返回的 `sessionId`、`image`、`url`（官方二维码链接，可选）和 `expiresAt`。
2. 展示 `image`。
3. 每至少 2 秒 `GET /auth/qr/:sessionId`。
4. `state` 依次可能为 `waiting`、`scanned`、`authorized`；二维码超过 180 秒返回 `QR_EXPIRED`。

扫码 session 与创建时的凭据版本绑定，不返回上游 key 或 Cookie。`POST /auth/logout` 仅删除本服务的本地凭据。

`GET /auth/status` 返回登录账号摘要并附带会员查询结果。未登录时 `membership=unknown`；Cookie 导入和扫码授权返回的账号摘要也可能尚未查询会员。未登录的每日推荐 `GET /recommendations/daily`、私人推荐歌单、`GET /auth/membership`、`GET /me/*` 和所有写操作返回 `LOGIN_REQUIRED`。

### VIP／SVIP 状态

`GET /auth/membership`（需要登录）：

```json
{
  "membership": "svip", "isVip": true, "isSvip": true,
  "expiresAt": 1800000000000, "checkedAt": 1790000000000,
  "source": "vip_info_v2"
}
```

- 优先 `vip_info_v2`，调用失败或不能识别时回退 `vip_info`。只解析 `redplus`／`redPlus`、`associator`、`musicPackage`／`music_package` 的明确到期字段；时间单位为 Unix 毫秒。
- `membership=svip` 表示存在有效 redplus 包；`vip` 表示有效 associator／musicPackage 包；只有三类包都明确无效时才返回 `none`。无法确定时 `unknown`，`isVip/isSvip/expiresAt/source` 为 `null`，可能附带安全的 `errorCode`。
- SVIP 包未提供但有有效 VIP 包时，返回已知的 `vip` 和 `isSvip=null`，不把缺少的数据当成明确否定。
- 有效结果最多缓存 5 分钟，并在最早会员包到期时提前刷新；未知结果缓存 15 秒。账号切换／退出清理缓存。查询上游失败不会把账号退出，也不阻止其他账号操作。
- 到期时间：SVIP 状态取 redplus 到期时间；VIP 状态取有效 VIP 包最晚到期时间。`none` 或未知为 `null`。
- 这些字段是账号展示信息，**不代表某首歌的实际播放权限**；仍应请求播放解析检查 `playable/status/restriction`。

### 私人推荐歌单

`GET /recommendations/personal-playlists`（需要登录）：调用 `recommend_resource`，返回 `{ "items": Playlist[] }`，包含统一的 ID、封面、创建者等字段。网易云未提供推荐时 `items=[]`；上游失败返回错误，不伪装成空列表。按凭据版本缓存 60 秒，账号变更及账号写操作清理缓存。

这是为账号推荐的歌单，不是用户创建的隐私歌单。用户自己的歌单仍通过 `/me/playlists` 查询。

### 专辑收藏状态

`GET /me/collections/albums/status?ids=20,21&maxPages=8`（需要登录），`ids` 必填，为逗号分隔的 1..100 个专辑 ID，去重后保持顺序；`maxPages` 为 1..20，默认 8。

```json
{
  "ids": ["20", "21"], "collected": { "20": true, "21": null },
  "complete": false, "scanned": 100, "nextOffset": 100
}
```

分页读取 `album_sublist`，每页 100 条，总扫描预算为 `UPSTREAM_TIMEOUT_MS`。找到全部目标、读完收藏列表、达到页数或时间预算时停止。

- `true`：已在收藏列表找到；`false`：已读完整个列表仍未找到；`null`：扫描未完成，暂时无法判断。
- `complete`：本次所有目标的状态都已确定；`scanned` 为已读取条目数。`nextOffset` 是扫描位置（读完列表为 `null`），仅供诊断，本接口不支持从该位置继续查询。
- 查询不缓存，收藏／取消收藏成功后的下次查询会重新读取上游。上游失败、分页异常返回错误；执行中的账号变更返回 `SESSION_CHANGED`。

客户端只有在值为 `false` 时才能显示明确的“未收藏”，不要把 `null` 转成布尔值。

### 写操作

| 方法 | 路径 | 请求体 |
|---|---|---|
| PUT | `/me/likes/:id` | `{ "liked": true }` |
| POST | `/playlists` | `{ "name": "名称", "private": false }` |
| POST／DELETE | `/playlists/:id/tracks` | `{ "ids": ["1", "2"] }` |
| PUT | `/me/collections/playlists/:id` | `{ "collected": true }` |
| PUT | `/me/collections/albums/:id` | `{ "collected": true }` |
| POST | `/songs/:id/comments` | `{ "content": "内容" }` |
| PUT | `/songs/:id/comments/:commentId/like` | `{ "liked": true }` |
| POST | `/listen` | `{ "id": "1", "sourceId": "0", "seconds": 30 }` |

所有写操作只用表中 HTTP 方法。上游成功返回前不响应成功；网络中断后不要自动重试评论、创建歌单或听歌上报，先查询核对。

## 媒体代理

推荐让服务为已取得的网易云 URL 签票：

`POST /media/tickets`：`{ "url": "https://m1.music.126.net/...", "kind": "audio" }`

也可以直接使用播放响应里的 `proxyUrl`。封面使用 `kind=cover`。成功响应为 `{ "proxyUrl": "/api/v1/media/cover?ticket=...", "expiresInSeconds": 300 }`。

- 播放 GET／HEAD，支持单 `Range: bytes=0-1023`，返回 206、`Content-Range` 和 `Accept-Ranges`。
- 不转发网易云账号 Cookie；已签票媒体的 GET／HEAD 不需要 Authorization header。
- 只接受 HTTPS／HTTP 的网易云 CDN 子域名，拒绝 IP、端口、用户信息、内网解析、非图片封面和非音频响应；重定向最多 3 跳且每跳重新校验。
- `416` 表示 Range 越界或非法；逗号多段 Range 被拒绝。
- `MEDIA_URL_REJECTED`、`MEDIA_TICKET_EXPIRED`、`MEDIA_TYPE_REJECTED` 等错误不应自动降级为任意 URL 代理。

## 错误码

| HTTP | code 示例 | 处理 |
|---|---|---|
| 400 | `INVALID_ARGUMENT`、`INVALID_JSON`、`INVALID_COOKIE` | 修正参数，不自动重试；Cookie 缺少 `MUSIC_U` 或格式非法时返回 `INVALID_COOKIE` |
| 401 | `UNAUTHORIZED`、`LOGIN_REQUIRED`、`INVALID_COOKIE` | API 密钥与网易云账号登录是两种不同认证；Cookie 无效或过期时 `INVALID_COOKIE` 需重新导入或扫码 |
| 403 | `ORIGIN_FORBIDDEN`、`INVALID_MEDIA_TICKET` | 核对 CORS／票据 |
| 404 | `NOT_FOUND`、`SONG_NOT_FOUND`、`PLAYLIST_NOT_FOUND`、`ALBUM_NOT_FOUND`、`ARTIST_NOT_FOUND`、`PODCAST_NOT_FOUND` | 路由或资源不存在 |
| 405 | `METHOD_NOT_ALLOWED` | 使用 Allow 指定的方法 |
| 409 | `SESSION_CHANGED`、`SESSION_CHANGED_AFTER_WRITE`、`QR_POLL_BUSY` | 登录版本变化或并发；写操作核对原账号，不盲目重试 |
| 410 | `QR_EXPIRED`、`MEDIA_TICKET_EXPIRED` | 创建新二维码或重新解析播放 |
| 413／415 | `BODY_TOO_LARGE`、`UNSUPPORTED_MEDIA_TYPE` | 请求体限制／必须 JSON |
| 416 | `INVALID_RANGE` | 修正单 Range；上游越界时可能返回空媒体响应而不是 JSON |
| 429 | `RATE_LIMITED` | 按 Retry-After 等待 |
| 500 | `CREDENTIAL_STORAGE_FAILED`、`INTERNAL_ERROR` | 排查存储权限／服务日志 |
| 501 | `CAPABILITY_UNSUPPORTED` | 上游适配器缺少该功能 |
| 502 | `UPSTREAM_REJECTED`、`UPSTREAM_INCOMPLETE`、`UPSTREAM_HTTP_ERROR`、`UPSTREAM_INVALID_JSON`、`AUDIO_PROBE_FAILED`、`MEDIA_UPSTREAM_ERROR`、`LOGIN_UNVERIFIED` | 上游拒绝、字段缺失、响应异常、媒体验证失败或扫码后账号未验证；写操作先核对结果 |
| 503 | `UPSTREAM_BUSY` | 等待在途上游请求完成 |
| 504 | `UPSTREAM_TIMEOUT`、`MEDIA_TIMEOUT` | 上游或流超时 |

上游拒绝可能附带安全的 `details.upstreamCode`，不返回堆栈、Cookie 或原始账号响应。开始流传输后发生错误会关闭连接，不能再附加 JSON 错误。

## 客户端完整接入示例

以下示例适用于浏览器或 Node.js 22.12+；仓库内可运行版本见 [examples/client.mjs](../examples/client.mjs)。

```js
const apiOrigin = 'http://127.0.0.1:3000';
const token = ''; // 自用受信客户端的配置；不要内置到公开网页
async function api(path, options = {}) {
  const response = await fetch(`${apiOrigin}/api/v1${path}`, {
    ...options,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...options.headers,
    },
  });
  const payload = await response.json();
  if (!response.ok || !payload.success) {
    throw new Error(`${payload.error?.code}: ${payload.error?.message}`);
  }
  return payload.data;
}
const results = await api(`/search?keywords=${encodeURIComponent('钢琴')}&limit=20`);
const track = results.items[0];
const playback = await api(`/songs/${track.id}/playback?quality=exhigh`);
if (playback.playable) {
  const audio = new Audio(new URL(playback.proxyUrl, apiOrigin));
  // 用户点击播放时调用，以遵守浏览器自动播放限制。
  playButton.onclick = () => audio.play();
  // 长时间暂停后若票据过期，重新解析并恢复 currentTime。
}
const cover = await api('/media/tickets', {
  method: 'POST', body: JSON.stringify({ url: track.cover, kind: 'cover' }),
});
coverImage.src = new URL(cover.proxyUrl, apiOrigin);
```

## 补充数据结构

- 评论：`{ id, content, likedCount, liked, time, user: { id, nickname, avatar } }`，time 为毫秒。
- 歌单：`{ provider, id, name, cover, description, trackCount, playCount, creator: { id, name }, subscribed }`。
- 专辑详情：`{ album: { id, name, cover, artists, publishedAt, trackCount }, songs: Song[] }`。
- 歌手详情：`{ artist: { id, name, avatar, description, musicSize, albumSize }, items: Song[], ...分页字段 }`。
- 播客：`{ id, name, cover, description, category, programCount, creator }`。
- 节目：`{ id, name, cover, description, durationMs, song: Song, radio: Podcast, publishedAt }`；**播放用 song.id，而非节目 id**。
- `/me/likes`：`{ ids: string[] }`；`/me/playlists` 为 Page，`/recommendations/*` 为 `{ items }`。
- 歌单增删：`{ id, ids, operation: "add" | "del", accepted: true }`；喜欢／收藏／评论点赞返回目标 ID 和结果布尔值。
- `/listen`：`{ id, seconds, platformSubmitted: true, accountDurationSync: "unverified" }`。

## 兼容旧接口

保留的 `/api/*` 只作迁移过渡，响应仍是新统一格式，并带 `Deprecation: true`：

```text
/api/search              -> GET /api/v1/search
/api/song/detail         -> GET /api/v1/songs/:id
/api/song/url            -> GET /api/v1/songs/:id/playback
/api/lyric               -> GET /api/v1/songs/:id/lyrics
/api/song/comments       -> GET /api/v1/songs/:id/comments
/api/playlist/tracks     -> GET /api/v1/playlists/:id/tracks
/api/album/detail        -> GET /api/v1/albums/:id
/api/artist/detail       -> GET /api/v1/artists/:id
/api/login/status        -> GET /api/v1/auth/status
/api/login/cookie        -> POST /api/v1/auth/cookie
/api/logout              -> POST /api/v1/auth/logout
/api/user/playlists      -> GET /api/v1/me/playlists
```

其他平台、天气、更新、节拍分析和客户端专属路由均已移除。迁移时不要把旧的任意 `/api/audio?url=` 代理直接接回去；使用签名 `proxyUrl`。
