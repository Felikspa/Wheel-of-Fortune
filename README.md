# Wheel of Fortune (Flutter)

一个基于 Flutter 的移动端随机转盘应用，支持多转盘管理、可配置抽取规则、项目详情、批量文本导入/导出、以及中英文本地化。

## 1. 功能概览

- 多转盘：新增、删除、编辑、切换多个转盘。
- 抽取逻辑：
  - 指针固定朝上；
  - 点击启动后以随机初速度旋转并减速停止；
  - 停止后高亮命中扇形，并在下方结果卡显示详情。
- 项目管理：
  - 每个转盘包含多个项目；
  - 每个扇形唯一对应一条项目；
  - 点击扇形可查看完整详情；
  - 支持拖拽排序。
- 概率模式：
  - `equal`：等概率；
  - `weighted`：权重模式（未填权重默认按 `1` 处理）。
- 快捷导入导出（DSL）：
  - 支持粘贴文本快速导入为新转盘；
  - 支持完整转盘代码导出（复制到剪贴板）；
  - 支持部分成功导入（有效项导入，错误项提示行号）。
- 设计与交互：
  - 极简 iOS 风格；
  - 主界面无顶部/底部导航栏；
  - 左右滑动切换双页；
  - 底部仅保留轻量分页点提示；
  - 旋转期间禁用切页与扇形点击，避免状态冲突。
- 本地化与主题：
  - 中英文全量文案；
  - 默认跟随系统语言，可手动覆盖；
  - 系统非中英时回退英文；
  - 主题支持系统/浅色/深色。

## 2. 技术栈

- Flutter 3.41.x / Dart 3.11.x
- 本地存储：Isar
- 状态管理：Provider + ChangeNotifier
- 本地化：Flutter `gen-l10n` (`arb`)
- 自定义绘制：`CustomPainter`（转盘）

## 3. 环境要求

- Flutter SDK（建议与项目一致的稳定版）
- Android Studio / Xcode
- Android 真机或模拟器 / iOS 真机或模拟器

可用命令检查环境：

```bash
flutter --version
flutter doctor
```

## 4. 快速开始

### 4.1 安装依赖

```bash
flutter pub get
```

### 4.2 生成代码（模型与本地化）

首次拉取或模型变化后，执行：

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### 4.3 运行

查看设备：

```bash
flutter devices
```

运行到指定设备（示例）：

```bash
flutter run -d <deviceId>
```

## 5. 应用使用说明

### 5.1 页面结构

- 第 1 页：转盘抽取页
- 第 2 页：管理 + 设置页
- 左右滑动切换页面

### 5.2 抽取页

1. 点击 `Spin/启动` 按钮开始抽取。
2. 转盘停止后，命中扇形高亮，结果卡显示抽中项目。
3. 点击任意扇形可查看该项目详情（标题、副标题、标签、备注、颜色、权重）。

约束：

- 项目数少于 2 时不可抽取。
- 旋转过程中禁止切页和扇形点击。

### 5.3 管理页

- 转盘：
  - `Add Wheel` 新增转盘；
  - `Delete Wheel` 删除当前转盘（有二次确认）；
  - 顶部 `ChoiceChip` 切换当前转盘。
- 当前转盘设置：
  - 名称；
  - 概率模式（等概率/权重）；
  - 旋转时长；
  - 配色主题。
- 项目管理：
  - 新增/编辑/删除项目；
  - 拖拽调整顺序。
- 应用设置：
  - 语言（系统/中文/英文）；
  - 主题（系统/浅色/深色）。

### 5.4 数据约束

- 单个转盘项目数限制：最少 `2` 项可抽取，最多 `100` 项存储。
- 同一转盘内允许标题重名。

## 6. DSL 导入/导出规范

### 6.1 总体规则

- 导入行为：始终新建转盘，不覆盖当前转盘。
- 支持两种格式：
  - `csv`：字段分隔 `,`，项目分隔 `;`（兼容换行分项）
  - `pipe`：字段分隔 `|`，按行分项
- 头部元信息格式：`@key:value`
- 字段顺序（位置型，最多 6 个）：
  1. `title`（必填）
  2. `subtitle`
  3. `tags`
  4. `note`
  5. `colorHex`（仅 `#RRGGBB` 或 `#AARRGGBB`）
  6. `weight`（正数）
- 中间字段跳过：使用空占位（连续分隔符）。
- 引号与转义：
  - 支持双引号包裹字段；
  - 支持反斜杠转义。

### 6.2 头部元信息

支持以下 key：

- `@format: csv | pipe`
- `@name: 转盘名称`
- `@mode: equal | weighted`
- `@spinDurationMs: 毫秒`
- `@palette: ocean | sunset | mint | mono`

无 `@format` 时会自动检测；若检测不出，默认按 `csv`。

### 6.3 CSV 示例

```text
@format:csv
@name:Lunch
@mode:weighted
@spinDurationMs:5200
@palette:sunset

"Chicken, Rice",Cafe,,today special,#FFAA00,3;
Noodle,,tag1|tag2,,#112233,;
```

### 6.4 Pipe 示例

```text
@format:pipe
@name:Dinner
@mode:equal
Steak|Hall A|||#AA3333|1
Pasta|Hall B|italian||#33AA99|2
```

### 6.5 导入错误策略

- 部分成功：有效项继续导入；
- 错误项会返回行号和错误类型（缺标题、字段过多、颜色/权重非法、元信息非法）。

## 7. 测试与质量

### 7.1 静态检查

```bash
flutter analyze
```

### 7.2 测试

```bash
flutter test
```

已包含测试：

- `test/spin_engine_test.dart`：抽取概率与权重逻辑
- `test/wheel_codec_test.dart`：DSL 解析/导出与错误处理
- `test/app_widget_test.dart`：双页滑动与旋转锁页行为

## 8. 目录结构（核心）

```text
lib/
  main.dart
  l10n/
    app_en.arb
    app_zh.arb
  src/
    data/       # Isar 实体、仓储实现
    domain/     # 领域模型
    services/   # SpinEngine / DSL Codec / i18n
    state/      # AppController
    ui/         # 页面与组件
test/
```

## 9. 已知问题与处理

如果 Android 构建报 `isar_flutter_libs` 的 `namespace` 或 `package` 清单错误（AGP 版本兼容问题），可按以下方式处理：

1. 项目已在 `android/build.gradle.kts` 中对 `isar_flutter_libs` 增加了 `namespace` 兼容补丁。
2. 若仍报 Manifest `package=` 错误，可清理缓存后重新拉依赖：

```bash
flutter clean
flutter pub get
```

3. 如果本机缓存依旧保留旧清单，删除 Pub 缓存中该包后重装：

```bash
# Windows PowerShell
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1"
flutter pub get
```

---

如需扩展到云同步、文件导入导出、或更丰富 UI 样式系统，可在当前仓储层与 DSL 编解码基础上继续演进。
