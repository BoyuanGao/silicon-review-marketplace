---
name: product-mode
description: 产品演示分析模式 — 提取功能模块、使用场景和 User Journey
---

# 产品演示分析模式

## 模式标识

`product` — 当用户提到产品、功能、demo、演示、user journey 等关键词时触发。

## 帧过滤标准

识别"产品功能演示时间段"：

- **目标段**：讲解功能模块、操作演示、界面展示的片段
- **跳过段**：开场寒暄、嘉宾介绍、会议总结/感谢、Q&A 闲聊、纯过渡画面

## 帧分析 Prompt

每帧调用 `mcp__MiniMax__understand_image` 时使用以下 prompt：

```
产品演示视频截图分析。请描述画面中的内容。重点关注：
1. 产品功能模块名称（左侧菜单、顶部标签、按钮文字）
2. 正在演示的具体功能（筛选条件、话术配置、数据看板等）
3. 界面上的关键数据和文字
4. 对应的业务使用场景
用中文回答，简明扼要。如果画面没有变化（如PPT静止页），说明即可。
```

## 转录提炼重点

从转录文本中提取：

- 产品名称、定位、解决的问题
- 功能模块及其作用描述
- 典型使用场景和用户角色
- 技术特点或竞争优势
- 行业案例或客户故事

## 图像分析模式输出模板

生成如下 HTML 结构（使用共享 CSS 基础样式 + 产品紫 `#8b5cf6`）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><产品名称> — 产品分析</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #fafbfc; color: #1e293b; line-height: 1.6; }
  .container { max-width: 860px; margin: 0 auto; padding: 32px 40px; }
  h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
  h2 { font-size: 18px; color: #0f172a; margin: 28px 0 12px; display: flex; align-items: center; gap: 8px; }
  .section-bar { width: 4px; height: 20px; border-radius: 2px; display: inline-block; flex-shrink: 0; }
  .highlight { border-radius: 10px; padding: 16px 20px; margin-bottom: 24px; border-left: 3px solid #8b5cf6; }
  .highlight-purple { background: linear-gradient(135deg, #faf5ff, #f5f3ff); }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  thead th { padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600; letter-spacing: 0.3px; text-align: left; }
  td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  .arch-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 10px; }
  .arch-module { border-radius: 8px; padding: 14px; text-align: center; }
  .arch-layer { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; text-align: center; }
  details { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 10px; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; color: #1e293b; background: #fafbfc; }
  .screenshot-placeholder { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 6px; padding: 8px; margin: 12px 0; display: flex; gap: 8px; }
  .screenshot-placeholder .img-box { flex: 1; background: #fff; padding: 6px 10px; border-radius: 4px; font-size: 12px; text-align: center; color: #64748b; }
  .journey-steps { display: flex; gap: 8px; align-items: flex-start; flex-wrap: wrap; }
  .journey-step { flex: 1; min-width: 120px; background: #fff; border-radius: 10px; padding: 14px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  .journey-arrow { color: #cbd5e1; font-size: 20px; align-self: center; }
  .summary-block { font-size: 14px; color: #475569; background: #f8fafc; padding: 16px; border-radius: 10px; line-height: 1.8; }
  .header-meta { font-size: 13px; color: #64748b; }
  .header-tag { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: #8b5cf6; margin-bottom: 8px; font-weight: 600; }
  .header-line { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
  footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center; }
  @media print { details > summary { list-style: none; } details > summary::-webkit-details-marker { display: none; } body { background: #fff; } }
</style>
</head>
<body>
<div class="container">
  <div class="header-line">
    <div class="header-tag">产品分析 · Product Demo Analysis</div>
    <h1><产品名称></h1>
    <div class="header-meta">🏢 <公司> · 📅 <日期> · 🎯 <产品定位></div>
  </div>
  <div class="highlight highlight-purple">
    <div style="font-size:11px; text-transform:uppercase; color:#7c3aed; font-weight:600; margin-bottom:4px;">产品定位</div>
    <p style="margin:0; font-size:14px; line-height:1.7;"><2-3 句产品定位描述></p>
  </div>
  <h2><span class="section-bar" style="background:#c4b5fd;"></span>产品架构概览</h2>
  <div class="arch-card">
    <div style="font-size:14px; font-weight:700; color:#0f172a;"><产品名> 平台</div>
    <div style="font-size:12px; color:#64748b; margin-top:4px;"><一句话描述></div>
  </div>
  <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px; margin-bottom:10px;">
    <div class="arch-module" style="background:#eff6ff; border:1px solid #bfdbfe;"><div style="font-size:20px; margin-bottom:4px;">📄</div><div style="font-size:13px; font-weight:600; color:#1e40af;"><模块1名称></div><div style="font-size:11px; color:#3b82f6; margin-top:4px;"><关键词></div></div>
    <div class="arch-module" style="background:#f0fdf4; border:1px solid #bbf7d0;"><div style="font-size:20px; margin-bottom:4px;">🗄️</div><div style="font-size:13px; font-weight:600; color:#166534;"><模块2名称></div><div style="font-size:11px; color:#16a34a; margin-top:4px;"><关键词></div></div>
    <div class="arch-module" style="background:#faf5ff; border:1px solid #e9d5ff;"><div style="font-size:20px; margin-bottom:4px;">🤖</div><div style="font-size:13px; font-weight:600; color:#6b21a8;"><模块3名称></div><div style="font-size:11px; color:#7c3aed; margin-top:4px;"><关键词></div></div>
  </div>
  <div class="arch-layer"><div style="font-size:13px; font-weight:600; color:#475569;">🔗 <集成层名称></div><div style="font-size:11px; color:#64748b; margin-top:4px;"><集成列表></div></div>
  <h2><span class="section-bar" style="background:#a5b4fc;"></span>功能模块</h2>
  <details open>
    <summary>模块 1：<模块名称> <span style="font-size:11px; color:#94a3b8; font-weight:400; margin-left:8px;"><N> 张截图</span></summary>
    <div style="padding:0 16px 14px;">
      <div class="screenshot-placeholder"><div class="img-box">📷 <截图描述 1><br><span style="font-size:10px;">screenshots/<文件名></span></div><div class="img-box">📷 <截图描述 2><br><span style="font-size:10px;">screenshots/<文件名></span></div></div>
      <ul style="margin:8px 0 0; font-size:13px; color:#475569; padding-left:20px;"><li><功能点 1></li><li><功能点 2></li></ul>
    </div>
  </details>
  <h2><span class="section-bar" style="background:#fde68a;"></span>用户旅程</h2>
  <div class="journey-steps">
    <div class="journey-step"><div style="font-size:24px; margin-bottom:6px;"><emoji></div><div style="font-size:13px; font-weight:600; color:#1e293b;"><步骤1></div><div style="font-size:11px; color:#94a3b8; margin-top:4px;"><简述></div></div>
    <div class="journey-arrow">→</div>
    <div class="journey-step"><div style="font-size:24px; margin-bottom:6px;"><emoji></div><div style="font-size:13px; font-weight:600; color:#1e293b;"><步骤2></div><div style="font-size:11px; color:#94a3b8; margin-top:4px;"><简述></div></div>
  </div>
  <h2><span class="section-bar" style="background:#93c5fd;"></span>行业应用场景</h2>
  <table><thead><tr style="background:#f1f5f9;"><th>场景</th><th>用途</th><th>关键功能</th></tr></thead><tbody><tr><td style="font-weight:500;"><行业></td><td style="color:#475569;"><用途></td><td style="color:#475569;"><功能></td></tr></tbody></table>
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>技术特点</h2>
  <div class="summary-block"><ul style="padding-left:20px;"><li><技术特点></li></ul></div>
  <footer>Generated by video-analyzer · <生成时间></footer>
</div>
</body>
</html>
```

## 降级模式输出模板（零功能帧时使用）

生成如下 HTML 结构（在图像分析模板基础上，移除截图和架构图，添加警告横幅）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><产品名称> — 产品分析（纯转录）</title>
<style>
  /* Same CSS as image analysis template above */
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #fafbfc; color: #1e293b; line-height: 1.6; }
  .container { max-width: 860px; margin: 0 auto; padding: 32px 40px; }
  h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
  h2 { font-size: 18px; color: #0f172a; margin: 28px 0 12px; display: flex; align-items: center; gap: 8px; }
  .section-bar { width: 4px; height: 20px; border-radius: 2px; display: inline-block; flex-shrink: 0; }
  .highlight { border-radius: 10px; padding: 16px 20px; margin-bottom: 24px; border-left: 3px solid #8b5cf6; }
  .highlight-purple { background: linear-gradient(135deg, #faf5ff, #f5f3ff); }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  thead th { padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600; letter-spacing: 0.3px; text-align: left; }
  td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  details { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 10px; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; color: #1e293b; background: #fafbfc; }
  .summary-block { font-size: 14px; color: #475569; background: #f8fafc; padding: 16px; border-radius: 10px; line-height: 1.8; }
  .header-meta { font-size: 13px; color: #64748b; }
  .header-tag { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: #8b5cf6; margin-bottom: 8px; font-weight: 600; }
  .header-line { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
  footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center; }
  @media print { details > summary { list-style: none; } details > summary::-webkit-details-marker { display: none; } body { background: #fff; } }
</style>
</head>
<body>
<div class="container">
  <div class="header-line">
    <div class="header-tag">产品分析 · Product Demo Analysis</div>
    <h1><产品名称></h1>
    <div class="header-meta">🏢 <公司> · 📅 <日期> · 🎯 <产品定位></div>
  </div>
  <div style="background:#fef3c7; border-left:3px solid #f59e0b; border-radius:0 8px 8px 0; padding:12px 16px; margin-bottom:24px;">
    <p style="margin:0; font-size:14px; color:#92400e;">⚠️ 本次会议视频为人物录屏/PPT，无产品界面演示。以下内容基于会议转录文本整理。</p>
  </div>
  <div class="highlight highlight-purple">
    <div style="font-size:11px; text-transform:uppercase; color:#7c3aed; font-weight:600; margin-bottom:4px;">产品定位</div>
    <p style="margin:0; font-size:14px; line-height:1.7;"><2-3 句产品定位描述></p>
  </div>
  <h2><span class="section-bar" style="background:#a5b4fc;"></span>功能模块梳理</h2>
  <p style="font-size:13px; color:#94a3b8; margin-bottom:12px;">以下模块由会议讨论内容归纳，非界面演示提取。</p>
  <details open>
    <summary>模块 1：<模块名称></summary>
    <div style="padding:0 16px 14px; font-size:14px; color:#475569; line-height:1.7;">
      <p><strong>功能点（来自会议讨论）：</strong></p>
      <ul style="padding-left:20px;"><li><功能点></li></ul>
      <p style="margin-top:8px;"><strong>涉及场景：</strong><场景></p>
    </div>
  </details>
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>附录：完整转录文件</h2>
  <div style="background:#fff; border-radius:10px; padding:14px 16px; box-shadow:0 1px 3px rgba(0,0,0,0.04);">
    <p style="font-size:14px;"><a href="<产品名称>_transcript.txt" style="color:#8b5cf6;">📄 完整转录文本</a></p>
    <p style="font-size:14px; margin-top:4px;"><a href="<产品名称>_transcript.srt" style="color:#8b5cf6;">📝 字幕文件 (SRT)</a></p>
  </div>
  <footer>Generated by video-analyzer · <生成时间>（纯转录模式）</footer>
</div>
</body>
</html>
```
