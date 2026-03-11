# Plantory — CLAUDE.md

## 项目概述

**Plantory**（副标题：AI Plant Doctor）是一款面向新手养花用户的 AI 植物助手 iOS App。

核心功能：拍照 → AI诊断植物问题 → 提供养护建议，同时支持植物管理、虚拟植物状态和订阅付费。

PRD 文档：[Documents/PRD.markdown](Documents/PRD.markdown)

---

## 技术栈

| 层级 | 技术 |
|------|------|
| 语言 | Swift 6，Swift Concurrency，Default Main Actor |
| UI | SwiftUI，iOS 26 Liquid Glass 设计风格 |
| 数据 | SwiftData + CloudKit 同步 |
| 相机/图像 | AVFoundation，Vision 框架 |
| AI 诊断 | 后端代理调用 GPT-4o mini (vision) |
| 付费 | StoreKit 2，Freemium 订阅模式 |
| 平台 | iPhone / iPad / Mac（苹果全平台） |

---

## 项目结构

```
Plantory/
├── CLAUDE.md                     # 本文件
├── Documents/
│   └── PRD.markdown              # 产品需求文档
├── Plantory/                     # 主 App Target
│   ├── PlantoryApp.swift         # App 入口，ModelContainer 配置
│   ├── ContentView.swift         # 根视图
│   ├── Item.swift                # 占位模型（待替换）
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── Plantory.entitlements     # CloudKit 等权限
├── PlantoryTests/
└── PlantoryUITests/
```

> 当前代码为 Xcode 默认模板，`Item.swift` 是占位模型，需替换为真实数据模型。

---

## 数据模型（SwiftData）

### Plant（核心模型）
```swift
id, name, species, photoData, createdAt, note, healthStatus
// healthStatus: healthy | warning | critical
```

### Diagnosis（AI诊断记录）
```swift
id, plantID, photoData, resultJSON, createdAt
```

### PlantGuide（养护指南，本地静态数据）
```swift
species, light, water, temperature, fertilizer
// MVP 支持 20-30 种常见植物
```

---

## 页面结构

| 页面 | 说明 |
|------|------|
| 首页（植物列表） | 卡通图+名称+健康状态，支持搜索，FAB 添加植物 |
| 植物详情 | 虚拟植物状态图 + 养护指南 + AI诊断历史 |
| 添加植物 | 拍照/相册 → AI识别 → 填写名称 → 保存 |
| AI诊断页 | 拍照 → 上传 → 分析中 → 诊断结果 |
| 订阅页 | Freemium 升级 Pro（$14.99/year） |

---

## 核心开发规范

### Swift 6 & Concurrency
- 所有类型默认 `@MainActor`，除非明确需要后台隔离
- 使用 `async/await`，禁止 `DispatchQueue.main.async` 混用
- SwiftData 操作在 `@ModelActor` 中执行（避免主线程阻塞）

### SwiftUI & Liquid Glass
- 使用 iOS 26 Liquid Glass 材质（`.glassEffect()`）
- 遵循苹果 HIG 设计规范
- 支持 Dynamic Type 和 Dark Mode

### 数据持久化
- 本地：SwiftData（SQLite 底层）
- 同步：CloudKit（`ModelConfiguration` 启用 cloud）
- 图片存储：文件系统（`FileManager`），SwiftData 只存路径

### AI 诊断
- **不在客户端直接调用 AI API**（保护 API Key）
- 通过后端代理（Cloudflare Workers / Firebase Functions）中转
- 请求包含：植物照片（base64）+ 语言偏好
- 响应格式：`{ species, problem, causes: [], suggestions: [] }`

### 付费限制（Freemium）
- 免费：最多 4 个植物，每天 3 次 AI 诊断
- Pro：无限植物 + 无限诊断
- 使用 StoreKit 2 实现，本地缓存订阅状态

---

## Axiom Skills 使用规则

这是一个 iOS Swift 项目，**在回答任何 iOS/Swift 问题前必须先检查 Axiom skills**：

- UI/SwiftUI 问题 → `axiom:axiom-ios-ui`
- SwiftData 问题 → `axiom:axiom-swiftdata`
- CloudKit 同步 → `axiom:axiom-cloud-sync`
- Swift Concurrency → `axiom:axiom-swift-concurrency`
- StoreKit/IAP → `axiom:axiom-in-app-purchases`
- 构建失败 → `axiom:axiom-ios-build`
- iOS 26 / Liquid Glass → `axiom:axiom-swiftui-26-ref` 或 `axiom:axiom-liquid-glass`
- 相机/Vision → `axiom:axiom-camera-capture`

---

## MVP 开发优先级

1. **数据模型** — 替换 `Item.swift`，建立 `Plant` + `Diagnosis` 模型
2. **植物列表首页** — 卡通虚拟植物卡片列表
3. **添加植物流程** — 拍照/相册 + 基本信息录入
4. **AI 诊断功能** — 拍照上传 + 结果展示（核心功能）
5. **虚拟植物状态** — 根据诊断结果更新状态图片
6. **订阅系统** — StoreKit 2 Freemium 限制

---

## 不在 MVP 范围内

- 社区/社交功能
- 复杂植物数据库（>30种）
- 浇水/施肥智能提醒（未来版本）
- 植物分享（未来版本）
- 位置/季节/气温联动提醒（未来版本）

---

## 常用命令

```bash
# 构建
xcodebuild -project Plantory.xcodeproj -scheme Plantory -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# 运行测试
xcodebuild test -project Plantory.xcodeproj -scheme Plantory -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
