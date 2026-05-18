---
name: meeting-mode
description: 会议纪要模式 — 提取决策、行动项、关键讨论点
---

# 会议纪要模式

## 模式标识

`meeting` — 当用户提到会议、meeting、纪要、行动项、action item 等关键词时触发。

## 帧过滤标准

识别"实质性讨论时间段"：

- **目标段**：议程讨论、决策陈述、任务分配、数据汇报、方案评审
- **跳过段**：开场寒暄、自我介绍、茶歇/休息、闲聊、纯过渡画面

## 帧分析 Prompt

每帧调用 `mcp__MiniMax__understand_image` 时使用以下 prompt：

```
会议视频截图分析。请描述画面中的内容。重点关注：
1. 演示文档/PPT 的标题和要点（大标题、项目符号、关键数据）
2. 数据图表的内容（轴标签、数值、趋势）
3. 白板/协作画板上的文字和图形
4. 屏幕共享中的应用界面（如项目管理工具、表格等）
用中文回答，简明扼要。如果画面没有变化（如静止PPT），说明即可。
```

## 转录提炼重点

从转录文本中提取：

- 决策项：达成了什么共识或决定
- 行动项：谁需要在什么时间前完成什么
- 关键讨论点：各方观点和论据
- 反对意见：谁持不同意见，理由是什么
- 待定事项：悬而未决、需要后续跟进的问题
- 重要数据：会议中引用的关键数字和指标

## 图像分析模式输出模板

生成如下 HTML 结构（使用共享 CSS 基础样式 + 会议蓝 `#3b82f6`）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><会议主题> — 会议纪要</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #fafbfc; color: #1e293b; line-height: 1.6; }
  .container { max-width: 860px; margin: 0 auto; padding: 32px 40px; }
  h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
  h2 { font-size: 18px; color: #0f172a; margin: 28px 0 12px; display: flex; align-items: center; gap: 8px; }
  .section-bar { width: 4px; height: 20px; border-radius: 2px; display: inline-block; flex-shrink: 0; }
  .highlight { border-radius: 10px; padding: 16px 20px; margin-bottom: 24px; border-left: 3px solid #3b82f6; }
  .highlight-blue { background: linear-gradient(135deg, #eff6ff, #f0f4ff); }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  thead th { background: #f1f5f9; text-align: left; padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600; color: #475569; letter-spacing: 0.3px; }
  td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  details { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 10px; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; color: #1e293b; background: #fafbfc; }
  details .detail-body { padding: 0 16px 14px; font-size: 14px; color: #475569; line-height: 1.7; }
  .task-row { display: flex; align-items: center; padding: 12px 16px; border-bottom: 1px solid #f1f5f9; gap: 12px; }
  .task-row:last-child { border-bottom: none; }
  .task-text { font-size: 14px; font-weight: 500; }
  .task-meta { font-size: 12px; color: #94a3b8; margin-top: 2px; }
  .owner-tag { font-size: 12px; padding: 2px 8px; border-radius: 4px; white-space: nowrap; }
  .date-tag { font-size: 12px; color: #94a3b8; white-space: nowrap; }
  .pending-table thead th { background: #fff7ed; color: #9a3412; }
  .summary-block { font-size: 14px; color: #475569; background: #f8fafc; padding: 16px; border-radius: 10px; line-height: 1.8; }
  .header-meta { font-size: 13px; color: #64748b; display: flex; gap: 16px; }
  .header-tag { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: #3b82f6; margin-bottom: 8px; font-weight: 600; }
  .header-line { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
  footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center; }
  @media print { details > summary { list-style: none; } details > summary::-webkit-details-marker { display: none; } body { background: #fff; } }
</style>
</head>
<body>
<div class="container">

  <!-- Header -->
  <div class="header-line">
    <div class="header-tag">会议纪要 · Meeting Minutes</div>
    <h1><会议主题></h1>
    <div class="header-meta">
      <span>📅 <日期></span><span>🕑 <时长></span><span>👥 <参会人数> 人</span>
    </div>
  </div>

  <!-- 核心结论 -->
  <div class="highlight highlight-blue">
    <div style="font-size:11px; text-transform:uppercase; color:#3b82f6; font-weight:600; margin-bottom:4px;">核心结论</div>
    <p style="margin:0; font-size:14px; line-height:1.7;"><核心结论 1-2 句话></p>
  </div>

  <!-- 决策记录 -->
  <h2><span class="section-bar" style="background:#bfdbfe;"></span>决策记录</h2>
  <table>
    <thead><tr><th>#</th><th>决策</th><th>相关背景</th><th>备注</th></tr></thead>
    <tbody>
      <tr><td>1</td><td style="font-weight:500;"><决策描述></td><td style="color:#475569;"><背景></td><td style="color:#475569;"><备注></td></tr>
      <!-- 更多决策行 -->
    </tbody>
  </table>

  <!-- 行动项 -->
  <h2><span class="section-bar" style="background:#bbf7d0;"></span>行动项</h2>
  <div style="background:#fff; border-radius:10px; box-shadow:0 1px 3px rgba(0,0,0,0.04); overflow:hidden;">
    <div class="task-row">
      <input type="checkbox" style="width:18px; height:18px; accent-color:#10b981; cursor:pointer; flex-shrink:0;"
        onchange="var t=this.parentElement.querySelector('.task-text');var m=this.parentElement.querySelector('.task-meta');if(this.checked){t.style.textDecoration='line-through';t.style.color='#94a3b8';m.style.textDecoration='line-through';m.style.color='#cbd5e1';}else{t.style.textDecoration='none';t.style.color='inherit';m.style.textDecoration='none';m.style.color='#94a3b8';}">
      <div style="flex:1;">
        <div class="task-text"><任务描述></div>
        <div class="task-meta"><补充说明></div>
      </div>
      <span class="owner-tag" style="background:#dbeafe; color:#1e40af;"><负责人></span>
      <span class="date-tag">📅 <截止日期></span>
    </div>
    <!-- 更多行动项行 -->
  </div>

  <!-- 关键讨论 -->
  <h2><span class="section-bar" style="background:#ddd6fe;"></span>关键讨论</h2>
  <details open>
    <summary>议题 1：<议题名称></summary>
    <div class="detail-body">
      <p><strong>背景：</strong><背景></p>
      <p style="margin-top:8px;"><strong>各方观点：</strong></p>
      <ul style="padding-left:20px;">
        <li><strong><人/角色 A></strong>：<观点></li>
        <li><strong><人/角色 B></strong>：<观点></li>
      </ul>
      <p style="margin-top:8px;"><strong>结论：</strong><讨论结果></p>
    </div>
  </details>
  <!-- 更多讨论 details -->

  <!-- 待跟进事项 -->
  <h2><span class="section-bar" style="background:#fecaca;"></span>待跟进事项</h2>
  <table class="pending-table">
    <thead><tr><th>事项</th><th>跟进人</th><th>下一步</th></tr></thead>
    <tbody>
      <tr><td><事项></td><td><跟进人></td><td style="color:#475569;"><下一步动作></td></tr>
    </tbody>
  </table>

  <!-- 会议转录摘要 -->
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>会议转录摘要</h2>
  <div class="summary-block"><200-300 字摘要></div>

  <footer>Generated by video-analyzer · <生成时间></footer>
</div>
</body>
</html>
```

## 降级模式输出模板（零目标帧时使用）

生成如下 HTML 结构（在图像分析模板基础上，移除截图内容，添加警告横幅和转录文件附录）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><会议主题> — 会议纪要（纯转录）</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, -apple-system, sans-serif; background: #fafbfc; color: #1e293b; line-height: 1.6; }
  .container { max-width: 860px; margin: 0 auto; padding: 32px 40px; }
  h1 { font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
  h2 { font-size: 18px; color: #0f172a; margin: 28px 0 12px; display: flex; align-items: center; gap: 8px; }
  .section-bar { width: 4px; height: 20px; border-radius: 2px; display: inline-block; flex-shrink: 0; }
  .highlight { border-radius: 10px; padding: 16px 20px; margin-bottom: 24px; border-left: 3px solid #3b82f6; }
  .highlight-blue { background: linear-gradient(135deg, #eff6ff, #f0f4ff); }
  table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04); }
  thead th { background: #f1f5f9; text-align: left; padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600; color: #475569; letter-spacing: 0.3px; }
  td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  details { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); overflow: hidden; margin-bottom: 10px; }
  summary { padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; color: #1e293b; background: #fafbfc; }
  details .detail-body { padding: 0 16px 14px; font-size: 14px; color: #475569; line-height: 1.7; }
  .task-row { display: flex; align-items: center; padding: 12px 16px; border-bottom: 1px solid #f1f5f9; gap: 12px; }
  .task-row:last-child { border-bottom: none; }
  .task-text { font-size: 14px; font-weight: 500; }
  .task-meta { font-size: 12px; color: #94a3b8; margin-top: 2px; }
  .owner-tag { font-size: 12px; padding: 2px 8px; border-radius: 4px; white-space: nowrap; }
  .date-tag { font-size: 12px; color: #94a3b8; white-space: nowrap; }
  .pending-table thead th { background: #fff7ed; color: #9a3412; }
  .summary-block { font-size: 14px; color: #475569; background: #f8fafc; padding: 16px; border-radius: 10px; line-height: 1.8; }
  .header-meta { font-size: 13px; color: #64748b; display: flex; gap: 16px; }
  .header-tag { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: #3b82f6; margin-bottom: 8px; font-weight: 600; }
  .header-line { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 2px solid #e2e8f0; }
  footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center; }
  @media print { details > summary { list-style: none; } details > summary::-webkit-details-marker { display: none; } body { background: #fff; } }
</style>
</head>
<body>
<div class="container">

  <!-- Header（同图像分析模式） -->

  <!-- 警告横幅 -->
  <div style="background:#fef3c7; border-left:3px solid #f59e0b; border-radius:0 8px 8px 0; padding:12px 16px; margin-bottom:24px;">
    <p style="margin:0; font-size:14px; color:#92400e;">⚠️ 本次会议视频无共享屏幕/PPT 内容。以下内容基于会议转录文本整理。</p>
  </div>

  <!-- 核心结论（同图像分析模式） -->

  <!-- 决策记录（同图像分析模式） -->

  <!-- 行动项（同图像分析模式） -->

  <!-- 关键讨论（同图像分析模式） -->

  <!-- 待跟进事项（同图像分析模式） -->

  <!-- 会议转录摘要（同图像分析模式） -->

  <!-- 附录：完整转录文件 -->
  <h2><span class="section-bar" style="background:#e2e8f0;"></span>附录：完整转录文件</h2>
  <div style="background:#fff; border-radius:10px; padding:14px 16px; box-shadow:0 1px 3px rgba(0,0,0,0.04);">
    <p style="font-size:14px;"><a href="<会议主题>_transcript.txt" style="color:#3b82f6;">📄 完整转录文本</a></p>
    <p style="font-size:14px; margin-top:4px;"><a href="<会议主题>_transcript.srt" style="color:#3b82f6;">📝 字幕文件 (SRT)</a></p>
  </div>

  <footer>Generated by video-analyzer · <生成时间>（纯转录模式）</footer>
</div>
</body>
</html>
```
