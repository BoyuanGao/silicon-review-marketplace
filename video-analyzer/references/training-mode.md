---
name: training-mode
description: 教学/培训总结模式 — 提取知识点、章节结构、关键概念和实操步骤
---

# 教学/培训总结模式

## 模式标识

`training` — 当用户提到教学、培训、课程、知识点、lecture、tutorial 等关键词时触发。

## 帧过滤标准

识别"知识讲解时间段"：

- **目标段**：知识讲解、概念定义、示例演示、实操步骤、案例分析、板书/图表讲解
- **跳过段**：课前准备/调试、课间休息、广告/宣传、纯闲聊、设备故障等待

## 帧分析 Prompt

每帧调用 `mcp__MiniMax__understand_image` 时使用以下 prompt：

```
教学/培训视频截图分析。请描述画面中的内容。重点关注：
1. 幻灯片/PPT 的标题和要点（章节标题、定义、公式）
2. 板书/手写内容（关键概念、推导过程）
3. 代码演示片段（语言、函数名、关键逻辑）
4. 图表和示意图（流程图、架构图、对比图）
5. 实操界面（工具名称、操作步骤）
用中文回答，简明扼要。如果画面没有变化（如静止PPT），说明即可。
```

## 转录提炼重点

从转录文本中提取：

- 课程/培训的主题和目标
- 章节结构和知识体系
- 关键概念的定义和解释
- 重要公式、定理或规则
- 示例和案例
- 实操步骤和注意事项
- 常见问题和易错点

## 图像分析模式输出模板

生成如下 HTML 结构（使用共享 CSS 基础样式 + 教学绿 `#16a34a`）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><课程名称> — 学习总结</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #fafbfc; color: #1e293b; line-height: 1.6; }
  .container { max-width: 860px; margin: 0 auto; padding: 32px 40px; }
  h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
  h2 { font-size: 18px; color: #0f172a; margin: 28px 0 12px; display: flex; align-items: center; gap: 8px; }
  .section-bar { width: 4px; height: 20px; border-radius: 2px; display: inline-block; flex-shrink: 0; }
  .highlight { border-radius: 10px; padding: 16px 20px; margin-bottom: 24px; border-left: 3px solid #22c55e; }
  .highlight-green { background: linear-gradient(135deg, #f0fdf4, #ecfdf5); }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  thead th { padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600; letter-spacing: 0.3px; text-align: left; }
  td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  .knowledge-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .knowledge-card { border-radius: 10px; padding: 14px; }
  .knowledge-tag { font-size: 11px; padding: 2px 8px; border-radius: 4px; margin-right: 4px; }
  details { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 10px; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; color: #1e293b; background: #fafbfc; }
  .chapter-body { padding: 0 16px 14px; font-size: 14px; color: #475569; line-height: 1.8; }
  .warning-note { background: #fef3c7; border-radius: 6px; padding: 10px 14px; margin-top: 8px; font-size: 13px; }
  .summary-block { font-size: 14px; color: #475569; background: #f8fafc; padding: 16px; border-radius: 10px; line-height: 1.8; }
  .header-meta { font-size: 13px; color: #64748b; }
  .header-tag { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: #16a34a; margin-bottom: 8px; font-weight: 600; }
  .header-line { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
  footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center; }
  .ref-table thead th { background: #f0fdf4; color: #166534; }
  @media print { details > summary { list-style: none; } details > summary::-webkit-details-marker { display: none; } body { background: #fff; } }
</style>
</head>
<body>
<div class="container">
  <div class="header-line">
    <div class="header-tag">教学总结 · Training / Lecture Summary</div>
    <h1><课程/培训名称></h1>
    <div class="header-meta">🎓 <难度/级别> · ⏱️ <时长> · 👤 讲师：<讲师名></div>
  </div>
  <div class="highlight highlight-green">
    <div style="font-size:11px; text-transform:uppercase; color:#16a34a; font-weight:600; margin-bottom:4px;">课程概览</div>
    <p style="margin:0; font-size:14px; line-height:1.7;"><strong>目标：</strong><学完能掌握什么></p>
    <p style="margin:4px 0 0; font-size:14px;"><strong>适用人群：</strong><目标受众></p>
  </div>
  <h2><span class="section-bar" style="background:#86efac;"></span>知识结构</h2>
  <div class="knowledge-grid">
    <div class="knowledge-card" style="background:#eff6ff; border:1px solid #bfdbfe;">
      <div style="font-size:13px; font-weight:700; color:#1e40af; margin-bottom:8px;"><分类1></div>
      <span class="knowledge-tag" style="background:#dbeafe; color:#1e40af;"><标签1></span>
      <span class="knowledge-tag" style="background:#dbeafe; color:#1e40af;"><标签2></span>
    </div>
    <div class="knowledge-card" style="background:#f0fdf4; border:1px solid #bbf7d0;">
      <div style="font-size:13px; font-weight:700; color:#166534; margin-bottom:8px;"><分类2></div>
      <span class="knowledge-tag" style="background:#dcfce7; color:#166534;"><标签1></span>
    </div>
  </div>
  <h2><span class="section-bar" style="background:#6ee7b7;"></span>核心知识点</h2>
  <details open>
    <summary>第 1 章 · <章节名称> <span style="font-size:11px; color:#94a3b8; font-weight:400; margin-left:8px;">⏱️ <时长></span></summary>
    <div class="chapter-body">
      <ul style="padding-left:20px;"><li><strong><概念名>：</strong><解释></li></ul>
      <div style="background:#f8fafc; border:1px dashed #cbd5e1; border-radius:6px; padding:8px; margin:12px 0; display:flex; gap:8px;">
        <div style="flex:1; background:#fff; padding:6px 10px; border-radius:4px; font-size:12px; text-align:center; color:#64748b;">📷 <截图描述><br><span style="font-size:10px;">screenshots/<文件名></span></div>
      </div>
      <div class="warning-note">⚠️ <strong>常见问题：</strong><易错点或注意事项></div>
    </div>
  </details>
  <h2><span class="section-bar" style="background:#bef264;"></span>方案速查表</h2>
  <table class="ref-table">
    <thead><tr><th>场景</th><th>推荐方案</th><th>理由</th></tr></thead>
    <tbody><tr><td style="font-weight:500;"><场景></td><td><code><方案></code></td><td style="color:#475569;"><理由></td></tr></tbody>
  </table>
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>实操步骤</h2>
  <div class="summary-block">
    <ol style="padding-left:20px;"><li><strong><步骤名>：</strong><描述></li></ol>
    <p style="margin-top:8px;"><strong>注意事项：</strong></p>
    <ul style="padding-left:20px;"><li><注意事项></li></ul>
  </div>
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>课程转录摘要</h2>
  <div class="summary-block"><200-300 字摘要></div>
  <footer>Generated by video-analyzer · <生成时间></footer>
</div>
</body>
</html>
```

## 降级模式输出模板（零目标帧时使用）

生成如下 HTML 结构（在图像分析模板基础上，移除截图，添加警告横幅和转录附录）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><课程名称> — 学习总结（纯转录）</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #fafbfc; color: #1e293b; line-height: 1.6; }
  .container { max-width: 860px; margin: 0 auto; padding: 32px 40px; }
  h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
  h2 { font-size: 18px; color: #0f172a; margin: 28px 0 12px; display: flex; align-items: center; gap: 8px; }
  .section-bar { width: 4px; height: 20px; border-radius: 2px; display: inline-block; flex-shrink: 0; }
  .highlight { border-radius: 10px; padding: 16px 20px; margin-bottom: 24px; border-left: 3px solid #22c55e; }
  .highlight-green { background: linear-gradient(135deg, #f0fdf4, #ecfdf5); }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  thead th { padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600; letter-spacing: 0.3px; text-align: left; }
  td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  .knowledge-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .knowledge-card { border-radius: 10px; padding: 14px; }
  .knowledge-tag { font-size: 11px; padding: 2px 8px; border-radius: 4px; margin-right: 4px; }
  details { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 10px; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; color: #1e293b; background: #fafbfc; }
  .chapter-body { padding: 0 16px 14px; font-size: 14px; color: #475569; line-height: 1.8; }
  .summary-block { font-size: 14px; color: #475569; background: #f8fafc; padding: 16px; border-radius: 10px; line-height: 1.8; }
  .header-meta { font-size: 13px; color: #64748b; }
  .header-tag { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: #16a34a; margin-bottom: 8px; font-weight: 600; }
  .header-line { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
  footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center; }
  @media print { details > summary { list-style: none; } details > summary::-webkit-details-marker { display: none; } body { background: #fff; } }
</style>
</head>
<body>
<div class="container">
  <div class="header-line">
    <div class="header-tag">教学总结 · Training / Lecture Summary</div>
    <h1><课程/培训名称></h1>
    <div class="header-meta">🎓 <难度/级别> · ⏱️ <时长> · 👤 讲师：<讲师名></div>
  </div>
  <div style="background:#fef3c7; border-left:3px solid #f59e0b; border-radius:0 8px 8px 0; padding:12px 16px; margin-bottom:24px;">
    <p style="margin:0; font-size:14px; color:#92400e;">⚠️ 本视频无幻灯片/板书等视觉教学内容。以下内容基于转录文本整理。</p>
  </div>
  <div class="highlight highlight-green">
    <div style="font-size:11px; text-transform:uppercase; color:#16a34a; font-weight:600; margin-bottom:4px;">课程概览</div>
    <p style="margin:0; font-size:14px; line-height:1.7;"><strong>目标：</strong><学完能掌握什么></p>
    <p style="margin:4px 0 0; font-size:14px;"><strong>适用人群：</strong><目标受众></p>
  </div>
  <h2><span class="section-bar" style="background:#86efac;"></span>知识结构</h2>
  <div class="knowledge-grid">
    <div class="knowledge-card" style="background:#eff6ff; border:1px solid #bfdbfe;"><div style="font-size:13px; font-weight:700; color:#1e40af; margin-bottom:8px;"><分类1></div><span class="knowledge-tag" style="background:#dbeafe; color:#1e40af;"><标签1></span></div>
    <div class="knowledge-card" style="background:#f0fdf4; border:1px solid #bbf7d0;"><div style="font-size:13px; font-weight:700; color:#166534; margin-bottom:8px;"><分类2></div><span class="knowledge-tag" style="background:#dcfce7; color:#166534;"><标签1></span></div>
  </div>
  <h2><span class="section-bar" style="background:#6ee7b7;"></span>核心知识点</h2>
  <details open>
    <summary>第 1 章 · <章节名称> <span style="font-size:11px; color:#94a3b8; font-weight:400; margin-left:8px;">⏱️ <时长></span></summary>
    <div class="chapter-body"><ul style="padding-left:20px;"><li><strong><概念名>：</strong><解释></li></ul></div>
  </details>
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>附录：完整转录文件</h2>
  <div style="background:#fff; border-radius:10px; padding:14px 16px; box-shadow:0 1px 3px rgba(0,0,0,0.04);">
    <p style="font-size:14px;"><a href="<课程名称>_transcript.txt" style="color:#16a34a;">📄 完整转录文本</a></p>
    <p style="font-size:14px; margin-top:4px;"><a href="<课程名称>_transcript.srt" style="color:#16a34a;">📝 字幕文件 (SRT)</a></p>
  </div>
  <footer>Generated by video-analyzer · <生成时间>（纯转录模式）</footer>
</div>
</body>
</html>
```
