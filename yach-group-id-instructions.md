# Yach 群聊 ID 获取方法

## 方法 1: 查看日志
```bash
# 查看最近的群聊消息日志
tail -100 ~/.openclaw/logs/*.log | grep -i "group\|chat"
```

## 方法 2: 发送消息后查看
在目标群聊中发送一条消息，然后查看日志：
```bash
tail -f ~/.openclaw/logs/*.log
```
在群聊中发消息，日志中会显示 `groupId` 或 `chatId`

## 方法 3: Yach 后台
登录 Yach 管理后台，在群聊设置中找到群 ID

## 群聊 ID 格式
通常是类似 `chat_xxxxxx` 或纯数字的字符串

---

**获取到群聊 ID 后，告诉我，我来更新配置！**

示例：`chat_123456` 或 `496298750109773868`
