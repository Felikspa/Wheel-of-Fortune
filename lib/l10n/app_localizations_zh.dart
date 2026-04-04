// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Wheel of Fortune';

  @override
  String get tabWheel => '转盘';

  @override
  String get tabManage => '管理';

  @override
  String get noWheelsYet => '还没有转盘';

  @override
  String get createFirstWheelHint => '请先到管理页创建第一个转盘。';

  @override
  String get goToManage => '前往管理';

  @override
  String get spin => '启动';

  @override
  String get spinning => '转动中...';

  @override
  String get result => '抽取结果';

  @override
  String get noResultYet => '暂无结果';

  @override
  String get tapSliceForDetails => '点击扇形可查看详情';

  @override
  String get atLeastTwoItems => '至少添加 2 个项目才能抽取';

  @override
  String get wheels => '转盘列表';

  @override
  String get addWheel => '新增转盘';

  @override
  String get deleteWheel => '删除转盘';

  @override
  String get deleteWheelConfirmTitle => '确认删除该转盘？';

  @override
  String get deleteWheelConfirmBody => '删除后不可恢复。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get wheelName => '转盘名称';

  @override
  String get probabilityMode => '概率模式';

  @override
  String get modeEqual => '等概率';

  @override
  String get modeWeighted => '权重';

  @override
  String get spinDuration => '转动时长';

  @override
  String secondsShort(String seconds) {
    return '$seconds秒';
  }

  @override
  String get palette => '配色主题';

  @override
  String get paletteOcean => '海洋';

  @override
  String get paletteSunset => '日落';

  @override
  String get paletteMint => '薄荷';

  @override
  String get paletteMono => '极简灰';

  @override
  String get items => '项目';

  @override
  String get addItem => '新增项目';

  @override
  String get editItem => '编辑项目';

  @override
  String get itemTitle => '标题';

  @override
  String get itemSubtitle => '副标题';

  @override
  String get itemTags => '标签';

  @override
  String get itemNote => '备注';

  @override
  String get itemColorHex => '颜色 HEX';

  @override
  String get itemWeight => '权重';

  @override
  String get requiredField => '必填项';

  @override
  String get invalidColorHex => '请输入 #RRGGBB 或 #AARRGGBB';

  @override
  String get invalidWeight => '权重需为正数';

  @override
  String get save => '保存';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageChinese => '中文';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get quickImport => '快捷导入';

  @override
  String get quickImportItems => '快速添加项目';

  @override
  String get quickImportHint => '请粘贴简化语法项目文本...';

  @override
  String get quickImportExampleLabel => '输入示例';

  @override
  String get quickImportExampleText =>
      'apple;banana;grape;\n\n苹果，site:楼下，color:blue；香蕉，超市，red；梨，淘宝，orange；';

  @override
  String get syntaxGuideEntry => '语法说明';

  @override
  String get syntaxGuideTitle => '快速导入语法';

  @override
  String get syntaxGuideOverview => '该功能会把项目追加到当前转盘，不会新建或覆盖转盘。';

  @override
  String get syntaxGuideRule1 => '1. 用分号或换行分隔项目；中英文、全角半角的分号/逗号/冒号都可用。';

  @override
  String get syntaxGuideRule2 => '2. 每条项目的第一个字段固定是标题。';

  @override
  String get syntaxGuideRule3 =>
      '3. 第一条可用 key:value 定义额外字段，如 site:楼下,color:blue。';

  @override
  String get syntaxGuideRule4 => '4. 后续项目可省略 key，按第一条字段顺序自动匹配。';

  @override
  String get syntaxGuideExample1Title => '示例1（仅标题）';

  @override
  String get syntaxGuideExample1Value => 'apple;banana;grape;';

  @override
  String get syntaxGuideExample2Title => '示例2（site + color）';

  @override
  String get syntaxGuideExample2Value =>
      '苹果，site:楼下，color:blue；香蕉，超市，red；梨，淘宝，orange；';

  @override
  String quickImportAdded(int count) {
    return '已向当前转盘添加 $count 个项目';
  }

  @override
  String quickImportSkipped(int count) {
    return '有 $count 个项目因达到上限被跳过';
  }

  @override
  String get quickExport => '快捷导出';

  @override
  String get importWheelCode => '导入转盘代码';

  @override
  String get pasteCodeHint => '请粘贴转盘代码...';

  @override
  String get importAction => '导入';

  @override
  String get exportCopied => '已复制转盘代码';

  @override
  String importCreatedWheel(int count) {
    return '已导入 $count 项，并创建新转盘';
  }

  @override
  String get importFailedNoValidItem => '未解析到有效项目';

  @override
  String importErrorSummary(int count) {
    return '有 $count 行导入失败';
  }

  @override
  String get details => '详情';

  @override
  String get close => '关闭';

  @override
  String get dslErrorMissingTitle => '缺少标题';

  @override
  String get dslErrorTooManyFields => '字段过多（最多 6 个）';

  @override
  String get dslErrorInvalidColor => '颜色格式无效';

  @override
  String get dslErrorInvalidWeight => '权重格式无效';

  @override
  String get dslErrorInvalidHeader => '元信息格式无效';

  @override
  String dslErrorLabel(int line, String message) {
    return '第 $line 行：$message';
  }

  @override
  String get loading => '加载中...';

  @override
  String get rename => '重命名';

  @override
  String get newWheelDefaultName => '新转盘';

  @override
  String get newItemDefaultTitle => '新项目';

  @override
  String get currentWheelSettings => '当前转盘设置';

  @override
  String get appSettings => '应用设置';
}
