// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wheel of Fortune';

  @override
  String get tabWheel => 'Wheel';

  @override
  String get tabManage => 'Manage';

  @override
  String get noWheelsYet => 'No wheels yet';

  @override
  String get createFirstWheelHint =>
      'Create your first wheel from the manage page.';

  @override
  String get goToManage => 'Go to Manage';

  @override
  String get spin => 'Spin';

  @override
  String get spinning => 'Spinning...';

  @override
  String get result => 'Result';

  @override
  String get noResultYet => 'No result yet';

  @override
  String get tapSliceForDetails => 'Tap a slice to view details';

  @override
  String get atLeastTwoItems => 'Add at least 2 items to spin';

  @override
  String get wheels => 'Wheels';

  @override
  String get addWheel => 'Add Wheel';

  @override
  String get deleteWheel => 'Delete Wheel';

  @override
  String get deleteWheelConfirmTitle => 'Delete this wheel?';

  @override
  String get deleteWheelConfirmBody => 'This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get wheelName => 'Wheel Name';

  @override
  String get probabilityMode => 'Probability Mode';

  @override
  String get modeEqual => 'Equal';

  @override
  String get modeWeighted => 'Weighted';

  @override
  String get spinDuration => 'Spin Duration';

  @override
  String secondsShort(String seconds) {
    return '${seconds}s';
  }

  @override
  String get palette => 'Palette';

  @override
  String get paletteOcean => 'Ocean';

  @override
  String get paletteSunset => 'Sunset';

  @override
  String get paletteMint => 'Mint';

  @override
  String get paletteMono => 'Mono';

  @override
  String get items => 'Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get itemTitle => 'Title';

  @override
  String get itemSubtitle => 'Subtitle';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemNote => 'Note';

  @override
  String get itemColorHex => 'Color Hex';

  @override
  String get itemWeight => 'Weight';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidColorHex => 'Use #RRGGBB or #AARRGGBB';

  @override
  String get invalidWeight => 'Weight must be a positive number';

  @override
  String get save => 'Save';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get quickImport => 'Quick Import';

  @override
  String get quickExport => 'Quick Export';

  @override
  String get importWheelCode => 'Import Wheel Code';

  @override
  String get pasteCodeHint => 'Paste wheel code here...';

  @override
  String get importAction => 'Import';

  @override
  String get exportCopied => 'Wheel code copied';

  @override
  String importCreatedWheel(int count) {
    return 'Imported $count item(s), created new wheel';
  }

  @override
  String get importFailedNoValidItem => 'No valid items found';

  @override
  String importErrorSummary(int count) {
    return '$count line(s) failed to import';
  }

  @override
  String get details => 'Details';

  @override
  String get close => 'Close';

  @override
  String get dslErrorMissingTitle => 'Missing title';

  @override
  String get dslErrorTooManyFields => 'Too many fields (max 6)';

  @override
  String get dslErrorInvalidColor => 'Invalid color format';

  @override
  String get dslErrorInvalidWeight => 'Invalid weight';

  @override
  String get dslErrorInvalidHeader => 'Invalid metadata header';

  @override
  String dslErrorLabel(int line, String message) {
    return 'Line $line: $message';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get rename => 'Rename';

  @override
  String get newWheelDefaultName => 'New Wheel';

  @override
  String get newItemDefaultTitle => 'New Item';

  @override
  String get currentWheelSettings => 'Current Wheel Settings';

  @override
  String get appSettings => 'App Settings';
}
