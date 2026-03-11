# Plantory Project Memory

## 项目基本信息
- **名称**: Plantory（AI Plant Doctor）
- **类型**: iOS App（苹果全平台）
- **定位**: 新手养花用户的 AI 植物助手
- **PRD**: [Documents/PRD.markdown](../Documents/PRD.markdown)

## 技术栈
- Swift 6 + Swift Concurrency + Default Main Actor
- SwiftUI + iOS 26 Liquid Glass
- SwiftData + CloudKit
- StoreKit 2（Freemium，$14.99/year）
- AI：后端代理 → GPT-4o mini vision

## 当前状态
- Xcode 项目为初始模板状态
- `Item.swift` 是占位模型，尚未开发实际功能
- CLAUDE.md 已生成（2026-03-11）

## 数据模型
- `Plant`: id, name, species, photoData, createdAt, note, healthStatus(healthy/warning/critical)
- `Diagnosis`: id, plantID, photoData, resultJSON, createdAt
- `PlantGuide`: 静态本地数据，MVP 20-30 种植物

## MVP 优先级
1. 数据模型（替换 Item.swift）
2. 植物列表首页
3. 添加植物流程
4. AI 诊断功能（核心）
5. 虚拟植物状态
6. 订阅系统

## 用户偏好
- 使用中文交流
- 遵循苹果最新设计规范（Liquid Glass）
