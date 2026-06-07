# Plantory — AGENTS.md

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
├── AGENTS.md                     # 本文件
├── Documents/
│   └── PRD.markdown              # 产品需求文档
├── Plantory/                     # 主 App Target
│   ├── PlantoryApp.swift         # App 入口，ModelContainer 配置
│   ├── Fundation/                # App 环境、通用状态、Mock 数据
│   ├── Models/                   # SwiftData 模型
│   ├── Navigation/               # 导航协调器
│   ├── Pages/                    # 页面模块
│   ├── Resources/                # 资源、字体、本地化
│   ├── Services/                 # 跨页面业务服务
│   ├── Utilities/                # 通用工具与扩展
│   ├── Views/                    # 全局可复用 UI 组件
│   ├── Info.plist
│   └── Plantory.entitlements     # CloudKit 等权限
├── PlantoryTests/
└── PlantoryUITests/
```

> 当前工程已从 Xcode 默认模板演进为模块化结构。新增页面时优先放入 `Plantory/Pages/`，共享组件才放入 `Plantory/Views/`。

### Pages 目录约定

页面按业务域分组，再按具体页面分组：

```
Plantory/Pages/
├── Home/
│   └── Home/
│       ├── HomePage.swift
│       └── Views/               # HomePage 私有/局部子视图
├── Plant/
│   ├── Plant/
│   │   ├── PlantPage.swift
│   │   └── Views/               # PlantPage 私有/局部子视图
│   └── Notifications/
│       └── PlantNotificationsPage.swift
├── AddPlant/
├── AddRecord/
├── Diagnosis/
├── PlantInformation/
└── Debug/
```

- `Pages/<Feature>/<PageName>/<PageName>Page.swift` 放页面入口，例如 `Pages/Home/Home/HomePage.swift`。
- 只服务于某个页面的组件放在该页面旁的 `Views/` 下，例如 `Pages/Plant/Plant/Views/PlantStatusView.swift`。
- 同一业务域下的独立页面放在同一个 feature 文件夹下，例如 `Pages/Plant/Plant/` 和 `Pages/Plant/Notifications/`。
- 多个页面共享、或跨业务域复用的组件放入根级 `Plantory/Views/`。
- 页面文件命名保留 `Page` 后缀，局部组件使用清晰的语义名，不要把大型子视图继续嵌套在页面文件里。

---

## 数据模型（SwiftData）

### Plant（核心模型）
```swift
id, nickname, plantInformation, photoData, createdAt, note, activeIssues
// plantInformation 通过 SwiftData relationship 关联 PlantInformation 原始信息；不要在 Plant 中重复保存 species/commonName/care levels 等快照字段
// healthStatus 从 activeIssues 派生：healthy | warning | critical
```

### PlantInformation（植物百科原始信息）
```swift
catalogID, species, commonName, overview, imageData, care levels, localizedContentsJSON
// CloudKit Public Database 是远端 source of truth；本地 SwiftData 缓存用于优先展示，再异步刷新 CloudKit 并更新本地数据库
// 多语言 commonName/overview/tips 存在 localizedContentsJSON，不要新增按语言展开的顶层文本字段
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
- 像素主题颜色直接使用 `.pixelPaper`、`.pixelInk`、`.pixelLeaf` 等简写，禁止写成 `Color(.pixelPaper)` 这类包装形式。
- `Page` 页面有加载/成功/失败等异步状态时，必须统一使用 `ViewState<T>` 管理状态；页面初始化器需要支持外部传入初始 `ViewState` 来控制状态，`#Preview` 必须 mock 出 `.loading`、`.loaded`、`.failed` 三种状态。
- 页面失败/空内容状态必须使用 `PixelContentUnavailableView` 表达，必要操作通过其 `actions` 区域提供；不要在页面里临时拼普通错误 `Text` 卡片。
- SwiftUI 类型的私有方法统一放在 `private extension` 中，并将该 extension 放在 `#Preview` 后面。

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
