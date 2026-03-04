# 🎬 YouTube/B 站视频学习流程指南

## 📋 概述

本指南介绍如何使用 OpenClaw 的 Skills 系统，自动从 YouTube 和 B 站视频学习内容并整理成结构化笔记。

---

## 🔄 完整分析流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    用户提供视频链接                              │
│              (YouTube 或 B 站 URL)                               │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  步骤 1: 检查视频平台                                           │
│  - 识别平台：YouTube / Bilibili                                 │
│  - 提取视频 ID                                                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  步骤 2: 获取字幕/转录                                          │
│  YouTube: youtube-transcript skill                              │
│  B 站：bilibili-subtitle-download-skill                         │
│  备用：yt-dlp 下载字幕                                          │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  步骤 3: 下载视频（如需分析画面）                                │
│  工具：yt-dlp-downloader-skill                                  │
│  需要：平台 Cookie（B 站需登录）                                 │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  步骤 4: 提取关键帧                                             │
│  工具：video-watcher skill                                      │
│  输出：每秒 1 帧 JPG 图片                                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  步骤 5: 分析画面内容                                           │
│  - 读取关键帧图片                                               │
│  - 识别 PPT、图表、代码演示                                      │
│  - 记录时间戳和关键信息                                          │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  步骤 6: 整合输出                                               │
│  - 结合字幕文本 + 画面分析                                       │
│  - 生成结构化学习笔记                                           │
│  - 输出到 Notion/飞书文档                                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ 使用的 Skills

### 1. youtube-transcript
**用途**: 获取 YouTube 视频转录

**安装**:
```bash
clawhub install youtube-transcript --force
```

**依赖**:
- Python 3.x
- youtube-transcript-api
- WireGuard VPN (可选，用于绕过 IP 限制)

**使用**:
```bash
python3 skills/youtube-transcript/scripts/fetch_transcript.py <VIDEO_ID_OR_URL>
```

**限制**:
- YouTube 会封锁云服务器 IP
- 需要配置 WireGuard VPN 连接家庭网络
- 或使用本地浏览器 Cookie

---

### 2. bilibili-youtube-watcher
**用途**: 获取 B 站和 YouTube 视频转录

**安装**:
```bash
clawhub install bilibili-youtube-watcher
```

**依赖**:
- yt-dlp
- B 站 Cookie（需要登录）

**使用**:
```bash
python3 skills/bilibili-youtube-watcher/scripts/get_transcript.py "VIDEO_URL"
```

**支持平台**:
- Bilibili (bilibili.com, b23.tv)
- YouTube (youtube.com, youtu.be)

---

### 3. bilibili-subtitle-download-skill
**用途**: 下载 B 站视频字幕并分块

**安装**:
```bash
clawhub install bilibili-subtitle-download-skill --force
```

**依赖**:
- bilibili-api-python
- B 站登录（扫码）

**使用**:
```bash
python3 skills/bilibili-subtitle-download-skill/scripts/download_and_chunk.py <BV_ID>
```

**功能**:
- 自动登录（生成二维码）
- 下载字幕
- 分块处理（适合 LLM 处理）
- 生成总结

---

### 4. yt-dlp-downloader-skill
**用途**: 下载视频文件

**安装**:
```bash
clawhub install yt-dlp-downloader-skill --force
```

**依赖**:
- yt-dlp: `pip3 install yt-dlp`
- ffmpeg: `dnf install ffmpeg`

**使用**:
```bash
# 下载视频
yt-dlp -f "best[height<=720]" -o "videos/%(title)s.%(ext)s" --cookies <COOKIE_FILE> "VIDEO_URL"

# 仅下载字幕
yt-dlp --write-auto-sub --sub-lang zh-CN --skip-download "VIDEO_URL"
```

**支持格式**:
- 视频：MP4, MKV, WebM
- 音频：MP3, M4A
- 字幕：SRT, VTT

---

### 5. video-watcher
**用途**: 分析视频画面内容

**安装**:
```bash
clawhub install video-watcher
```

**依赖**:
- ffmpeg: `dnf install ffmpeg`

**使用**:
```bash
bash skills/video-watcher/scripts/extract_frames.sh <VIDEO_PATH> [OUTPUT_DIR] [FPS]
```

**输出**:
- 提取的视频帧（JPG 格式）
- 视频元数据（时长、分辨率、帧数）

**分析策略**:
- 短视频 (<1 分钟): 查看所有帧
- 中等视频 (1-5 分钟): 每 3-5 帧抽样
- 长视频 (>5 分钟): 每 10+ 帧抽样，关注场景转换

---

### 6. notion
**用途**: 创建和管理 Notion 页面

**安装**: 已预装

**配置**:
```bash
openclaw configure
# 设置 Notion API Token
# 设置 Parent Page ID
```

**使用**:
```bash
# 创建页面
notion create --title "学习笔记" --parent <PAGE_ID>

# 更新内容
notion update --page <PAGE_ID> --content "markdown 内容"
```

---

## 📦 依赖安装清单

### 系统依赖
```bash
# OpenCloudOS/CentOS
dnf install -y ffmpeg python3-pip

# 安装 yt-dlp
pip3 install yt-dlp

# 安装 deno (YouTube 解密)
curl -fsSL https://deno.land/install.sh | sh
export PATH=$PATH:/root/.deno/bin
```

### Python 依赖
```bash
pip3 install youtube-transcript-api
pip3 install bilibili-api-python
pip3 install aiohttp
```

---

## 🔐 认证配置

### YouTube
**问题**: 云服务器 IP 被 YouTube 封锁

**解决方案**:
1. **WireGuard VPN** (推荐)
   - 配置家庭网络 WireGuard 服务器
   - VPS 作为客户端连接
   - 通过家庭 IP 访问 YouTube

2. **本地 Cookie**
   - 在本地浏览器导出 cookies.txt
   - 使用 `--cookies cookies.txt` 参数

### B 站
**问题**: 需要登录才能获取字幕

**解决方案**:
1. **扫码登录** (推荐)
   ```bash
   python3 -c "
   import asyncio
   from bilibili_api import login_v2
   async def main():
       qr = login_v2.QrCodeLogin()
       await qr.generate_qrcode()
       qr.get_qrcode_picture().to_file('qr.png')
       print('请扫描二维码')
       while not qr.has_done(): await qr.check_state(); await asyncio.sleep(2)
       cookies = qr.get_credential().get_cookies()
       with open('bilibili_cookie.txt', 'w') as f:
           f.write('; '.join(f'{k}={v}' for k,v in cookies.items()))
       print('登录成功!')
   asyncio.run(main())
   "
   ```

2. **保存 Cookie**
   - Cookie 文件：`~/.openclaw/workspace/bilibili_cookie.txt`
   - 格式转换：Netscape 格式用于 yt-dlp

---

## 📝 输出模板

### 视频学习笔记

```markdown
# 📺 视频学习笔记

## 📌 基本信息
- **标题**: [视频标题]
- **作者**: [UP 主/频道名称]
- **时长**: [视频长度]
- **链接**: [原始链接]
- **平台**: YouTube / Bilibili

## 🎬 画面内容（关键帧分析）

### Chapter 1: [章节名称] (时间范围)
- [时间戳] 画面描述
- [时间戳] 关键信息
- ...

## 📝 语音内容（转录总结）

### 核心主题
[1-2 句话总结]

### 关键知识点

#### 1. [知识点名称]
- 详细说明
- 为什么重要

#### 2. [知识点名称]
- 详细说明
- 实际应用

### 重要引用
> [视频中的金句]

## 💡 核心见解
- 洞察 1
- 洞察 2
- 洞察 3

## 📚 行动建议
- [ ] 可以立即尝试的事情 1
- [ ] 可以立即尝试的事情 2

## 🔗 相关资源
- 视频中提到的链接
- 延伸阅读材料
```

---

## 🚀 快速开始

### 1. 安装 Skills
```bash
cd ~/.openclaw/workspace

# YouTube 相关
clawhub install youtube-transcript --force
clawhub install yt-dlp-downloader-skill --force

# B 站相关
clawhub install bilibili-youtube-watcher
clawhub install bilibili-subtitle-download-skill --force

# 视频分析
clawhub install video-watcher
```

### 2. 安装依赖
```bash
# 系统依赖
dnf install -y ffmpeg python3-pip

# Python 依赖
pip3 install yt-dlp youtube-transcript-api bilibili-api-python aiohttp

# Deno (YouTube 解密)
curl -fsSL https://deno.land/install.sh | sh
```

### 3. B 站登录
```bash
# 运行登录脚本生成二维码
# 用 B 站 APP 扫描
# Cookie 自动保存
```

### 4. 开始学习
```
提供视频链接：
- YouTube: https://www.youtube.com/watch?v=xxx
- B 站：https://www.bilibili.com/video/BV1xxx

我会自动：
1. 获取字幕
2. 下载视频
3. 提取关键帧
4. 分析画面
5. 整理笔记
6. 输出到 Notion
```

---

## ⚠️ 常见问题

### Q1: YouTube 提示 "Sign in to confirm you're not a bot"
**原因**: 云服务器 IP 被 YouTube 封锁

**解决**:
- 配置 WireGuard VPN 连接家庭网络
- 或在本地电脑下载后上传文件

### Q2: B 站提示 HTTP 412 错误
**原因**: 需要登录 Cookie

**解决**:
- 运行登录脚本生成二维码
- 用 B 站 APP 扫描
- Cookie 会自动保存

### Q3: 视频没有字幕
**原因**: UP 主未上传字幕，YouTube 未生成自动字幕

**解决**:
- 仅分析画面内容
- 手动提供转录文本
- 使用第三方字幕服务

### Q4: 提取帧太多，分析不过来
**解决**:
- 降低 FPS: `extract_frames.sh video.mp4 output 0.5` (每 2 秒 1 帧)
- 抽样分析：只看章节转换处的帧
- 聚焦关键内容：PPT、图表、代码演示

---

## 📊 性能参考

| 视频时长 | 下载时间 | 提取帧数 | 分析时间 | 总计 |
|---------|---------|---------|---------|------|
| 5 分钟   | ~30 秒   | 300 帧   | ~2 分钟  | ~3 分钟 |
| 10 分钟  | ~1 分钟  | 600 帧   | ~4 分钟  | ~6 分钟 |
| 30 分钟  | ~3 分钟  | 1800 帧  | ~10 分钟 | ~15 分钟 |

*测试环境：OpenCloudOS 9.4, 100Mbps 网络*

---

## 🎯 最佳实践

1. **优先获取字幕**: 字幕比画面分析更准确
2. **关键帧抽样**: 长视频不需要分析每一帧
3. **章节定位**: 根据视频章节提取关键帧
4. **结果验证**: 重要信息人工复核
5. **Cookie 保存**: 登录一次，长期使用

---

_最后更新：2026-03-01_
_版本：1.0_
