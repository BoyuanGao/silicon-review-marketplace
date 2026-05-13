# Silicon Review Marketplace

Claude Code 插件市场，提供产品分析与视频理解相关的技能插件。

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
/plugin install video-product-summary@silicon-review-marketplace
```

## 可用插件

| 插件 | 分类 | 描述 | 适用场景 | 运行依赖 |
|------|------|------|----------|----------|
| [video-product-summary](./video-product-summary/) | 产品分析 | 分析产品介绍/演示类会议视频，提取功能模块、使用场景和 User Journey，输出带截图的 Markdown 结构化报告 | 产品演示会议录制、SaaS 产品能力介绍、软件系统功能培训、销售 Demo 录像分析 | [peepshow](https://github.com/anthropics/peepshow) (帧提取+转录)、[MiniMax MCP](https://platform.minimaxi.com) `understand_image` (图片理解)、`ffmpeg`/`ffprobe` (视频信息检查)、[whisper.cpp](https://github.com/ggerganov/whisper.cpp) `whisper-cli` (本地语音转录) |

## 许可

MIT License — 详见 [LICENSE](LICENSE)
