# Smth

SwiftUI 打造的水木社区多端客户端（iOS / iPadOS / macOS）。2025 重构版围绕 MVVM + Repository 架构，补齐依赖注入、分页与多平台适配策略。

## 📱 功能亮点

### 核心功能
- ✅ **热门话题浏览** - 瀑布流展示，支持分页加载
- ✅ **版面导航** - 层级式版面/子版面导航
- ✅ **话题详情** - 完整的话题内容与楼层回复展示
- ✅ **用户登录** - 基于 WebView 的登录认证
- ✅ **收藏管理** - 收藏版面与话题，支持分类查看
- ✅ **消息中心** - 收件箱、@我的、回复我的、Like我的
- ✅ **个人中心** - 个人资料、我的话题、草稿、关注/粉丝、浏览历史
- ✅ **搜索功能** - 版面与话题搜索

### 用户体验
- 🎨 **现代化 UI** - 统一的主题系统，支持深色模式
- 📱 **多平台适配** - iOS、iPadOS、macOS 原生体验
- 🔄 **响应式布局** - 自适应不同屏幕尺寸
- ⚡ **流畅交互** - 优化的加载状态与错误处理
- 💾 **本地缓存** - 浏览历史与草稿本地存储

## 🏗️ 项目架构

### 目录结构

```
App/
├── Core/                    # 核心功能层
│   ├── Authentication/      # 登录状态管理
│   ├── Database/           # 本地数据存储（浏览历史）
│   ├── Dependency/         # 依赖注入容器
│   ├── Networking/         # 网络层
│   │   ├── APIService.swift
│   │   ├── APIEndpoint.swift
│   │   └── Repositories/   # 数据仓库层
│   ├── Pagination/          # 分页状态管理
│   └── Utils/              # 工具类（主题、字体、图片缓存）
├── Modules/                 # 业务模块（MVVM）
│   ├── Home/               # 首页模块
│   ├── Favorite/           # 收藏模块
│   ├── Message/            # 消息模块
│   ├── Profile/            # 个人中心模块
│   └── Search/             # 搜索模块
├── Components/             # 可复用 UI 组件
│   ├── CachedAsyncImage.swift
│   ├── ImageGroupView.swift
│   ├── ImageViewer.swift
│   └── GuestPromptView.swift
└── Model/                   # 数据模型

SmthTests/                   # 单元测试
```

### 架构设计

#### MVVM + Repository 模式

```
View (SwiftUI)
    ↓
ViewModel (ObservableObject)
    ↓
Repository (Protocol)
    ↓
APIService (Network Layer)
```

**核心组件：**

- **View**: SwiftUI 视图，负责 UI 展示与用户交互
- **ViewModel**: 业务逻辑层，管理状态（加载、错误、数据）
- **Repository**: 数据访问抽象层，统一数据源接口
- **APIService**: 网络请求封装，处理 HTTP 请求与响应

#### 依赖注入 (DI)

通过 `AppContainer` 实现依赖注入，统一管理所有服务：

```swift
final class AppContainer: DependencyContainer {
    private lazy var apiService: APIService = DefaultAPIService()
    private lazy var topicRepository: TopicRepositoryProtocol = TopicRepository(apiService: apiService)
    // ... 其他 Repository
}
```

**优势：**
- 便于单元测试（可替换依赖）
- 降低模块间耦合
- 统一管理依赖生命周期

#### 多平台适配策略

1. **布局适配**
   - iOS: `TabView` 底部导航
   - iPadOS: `NavigationSplitView` 三栏布局
   - macOS: `NavigationSplitView` 侧边栏 + 内容区

2. **组件适配**
   - 使用 `#if os(iOS)` / `#if os(macOS)` 条件编译
   - 统一的主题系统 (`AppTheme`) 适配不同平台
   - 响应式布局支持不同屏幕尺寸

3. **交互适配**
   - iOS: 手势导航、下拉刷新
   - macOS: 键盘快捷键、鼠标交互

## 📸 应用截图

### iOS 界面

| 首页 | 收藏 | 消息 |
|------|------|------|
| ![首页](./Snapshots/home.png) | ![收藏](./Snapshots/favorite.png) | ![消息](./Snapshots/message.png) |

| 个人中心 | 设置 | 登录 |
|----------|------|------|
| ![个人中心](./Snapshots/profile.png) | ![设置](./Snapshots/setting.png) | ![登录](./Snapshots/login.png) |

## 🎯 已实现功能列表

### 首页模块 (Home)
- [x] 热门话题列表（瀑布流）
- [x] 版面选择器
- [x] 话题详情页
- [x] 文章回复展示
- [x] 图片附件展示
- [x] 分页加载
- [x] 下拉刷新

### 收藏模块 (Favorite)
- [x] 收藏版面列表
- [x] 收藏话题列表
- [x] 版面/话题切换
- [x] 版面层级导航
- [x] 未登录提示

### 消息模块 (Message)
- [x] 收件箱
- [x] @我的
- [x] 回复我的
- [x] Like我的
- [x] 会话详情
- [x] 消息分页加载
- [x] 未登录提示

### 个人中心模块 (Profile)
- [x] 用户登录（WebView）
- [x] 个人资料展示
- [x] 我的话题列表
- [x] 草稿管理
- [x] 关注列表
- [x] 粉丝列表
- [x] 浏览历史
- [x] 设置页面
- [x] 未登录提示

### 搜索模块 (Search)
- [x] 版面搜索
- [x] 话题搜索

### 通用功能
- [x] 图片缓存
- [x] 浏览历史本地存储
- [x] 字体大小设置
- [x] 深色模式支持
- [x] 错误处理与重试
- [x] 加载状态指示

## 🚧 待实现功能

### 内容交互
- [ ] **翻页功能** - 话题详情页的翻页导航（上一页/下一页）
- [ ] **发帖功能** - 发布新话题
- [ ] **评论功能** - 回复话题和楼层
- [ ] **点赞功能** - 对话题和回复进行点赞/取消点赞

### 社交功能
- [ ] **关注功能** - 关注/取消关注用户（目前仅支持查看关注列表）
- [ ] **黑名单功能** - 管理黑名单用户

### 账户管理
- [ ] **修改密码** - 账户密码修改
- [ ] **绑定手机号** - 手机号绑定与验证

### 其他功能
- [ ] **编辑帖子** - 编辑已发布的帖子
- [ ] **删除帖子** - 删除自己发布的帖子
- [ ] **举报功能** - 举报不当内容
- [ ] **私信功能** - 用户间私信交流
- [ ] **推送通知** - 消息推送提醒

## 🖥️ 平台适配

### 支持的平台

| 平台 | 最低版本 | 状态 |
|------|---------|------|
| iOS | 18.0+ | ✅ 完全支持 |
| iPadOS | 18.0+ | ✅ 完全支持 |
| macOS | 15.0+ | ✅ 完全支持 |

### 平台特性

#### iOS / iPadOS
- **导航方式**: 底部 Tab 栏（iPhone）或侧边栏（iPad）
- **交互**: 手势导航、下拉刷新、长按菜单
- **布局**: 响应式布局，适配不同屏幕尺寸

#### macOS
- **导航方式**: 侧边栏导航，三栏布局
- **交互**: 键盘快捷键、鼠标操作、窗口管理
- **布局**: 固定侧边栏 + 可调整内容区

### 适配实现

1. **条件编译**
   ```swift
   #if os(iOS)
       // iOS 特定代码
   #elseif os(macOS)
       // macOS 特定代码
   #endif
   ```

2. **统一主题系统**
   - `AppTheme` 统一管理颜色、间距、圆角
   - 自动适配深色/浅色模式
   - 平台特定样式通过环境变量判断

3. **响应式布局**
   - 使用 `SizeClass` 判断设备类型
   - `NavigationSplitView` 自动适配大屏设备

## 🚀 使用指南

### 环境要求

- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS**: 18.0+
- **macOS**: 15.0+

### 快速开始

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd Smth
   ```

2. **安装依赖**
   ```bash
   # 使用 Swift Package Manager（已集成）
   # 依赖会自动下载
   ```

3. **打开项目**
   ```bash
   open Smth.xcodeproj
   ```

4. **选择目标平台**
   - iOS: 选择 `Smth` scheme，目标设备选择 iPhone/iPad
   - macOS: 选择 `Smth` scheme，目标选择 `My Mac`

5. **运行项目**
   - 按 `Cmd + R` 运行
   - 或使用菜单 `Product > Run`

### 开发指南

#### 代码规范

项目使用 SwiftLint 进行代码规范检查：

```bash
# 安装 SwiftLint（如果未安装）
brew install swiftlint

# 检查代码规范
swiftlint --config swiftlint.yml

# 自动修复部分问题
swiftlint --fix --config swiftlint.yml
```

#### 构建与测试

```bash
# 构建项目
xcodebuild -scheme Smth -project Smth.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# 运行测试
xcodebuild -scheme Smth -project Smth.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test

# 使用 Fastlane（如果配置了）
bundle exec fastlane ci
```

#### 添加新功能

1. **创建新模块**
   ```
   App/Modules/YourModule/
   ├── YourModuleView.swift
   └── ViewModels/
       └── YourModuleViewModel.swift
   ```

2. **创建 Repository**
   ```
   App/Core/Networking/Repositories/
   └── YourRepository.swift
   ```

3. **注册依赖**
   在 `AppContainer.swift` 中注册新的 Repository

4. **添加路由**
   在 `ContentView.swift` 中添加新的导航目标

### 常见问题

#### 构建失败

**问题**: 找不到模拟器
```bash
# 列出可用模拟器
xcrun simctl list devices available

# 使用可用的模拟器名称
xcodebuild -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**问题**: 权限问题
- 确保给予 Xcode 对 `~/Library` 目录的访问权限
- 在系统设置中检查 Xcode 的权限

#### 网络请求失败

- 检查网络连接
- 确认 API 端点配置正确
- 查看控制台错误日志

#### 登录问题

- 确保 WebView 可以正常加载登录页面
- 检查 Cookie 存储是否正常
- 查看 `LoginState` 的状态变化

## 🧪 测试

项目包含单元测试示例：

```bash
# 运行所有测试
xcodebuild test -scheme Smth -destination 'platform=iOS Simulator,name=iPhone 16'

# 运行特定测试
xcodebuild test -scheme Smth -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:SmthTests/TopicListViewModelTests
```

### 测试覆盖

- ✅ ViewModel 单元测试
- ✅ Repository 测试
- ✅ 数据模型测试
- ⏳ UI 测试（待完善）

## 📦 依赖管理

项目使用 Swift Package Manager (SPM) 管理依赖：

### 当前依赖

- **SwiftSoup** (2.6.1) - HTML 解析
- **Alamofire** (5.8.0) - 网络请求

### 添加新依赖

1. 在 Xcode 中：`File > Add Package Dependencies`
2. 输入包 URL 或搜索包名
3. 选择版本规则
4. 添加到对应 target

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码提交规范

- 使用清晰的提交信息
- 一个提交只做一件事
- 确保代码通过 SwiftLint 检查
- 添加必要的测试

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 感谢水木社区论坛
- 感谢所有贡献者的支持

## 📮 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 开启 Pull Request
- 发送邮件: [bitnpc@gmail.com](mailto:bitnpc@gmail.com)

---

**注意**: 本项目仅供学习交流使用，请遵守水木社区的使用条款。
