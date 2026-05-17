# Silicon Review Marketplace

Claude Code 插件市场，提供视频内容提取与分析相关的技能插件。

## 安装

### 添加 Marketplace

在 Claude Code 中使用 `/plugin` 命令添加本市场：

```
/plugin marketplace add gaoboy/silicon-review-marketplace
```

或手动编辑 `~/.claude/settings.json`，在 `marketplaces` 中添加：

```json
{
  "marketplaces": [
    {
      "name": "silicon-review-marketplace",
      "source": {
        "source": "github",
        "repo": "gaoboy/silicon-review-marketplace"
      }
    }
  ]
}
```

### 安装插件

添加市场后，在 Claude Code 中使用以下命令安装插件：

```
/plugin install video-analyzer@silicon-review-marketplace
```

## 可用插件

| 插件 | 分类 | 描述 | 适用场景 | 运行依赖 |
|------|------|------|----------|----------|
| [video-analyzer](./video-analyzer/) | 视频分析 | 从视频中提取用户想要的内容，支持会议纪要、教学/培训总结、产品演示分析及自定义提取模式 | 会议录制提取决策和行动项、教学视频提取知识点、产品演示提取功能模块、任意视频自定义提取 | [peepshow](https://github.com/anthropics/peepshow) (帧提取+转录)、[MiniMax MCP](https://platform.minimaxi.com) `understand_image` (图片理解)、`ffmpeg`/`ffprobe` (视频信息检查)、[whisper.cpp](https://github.com/ggerganov/whisper.cpp) `whisper-cli` (本地语音转录) |

## 许可

MIT License — 详见 [LICENSE](LICENSE)
