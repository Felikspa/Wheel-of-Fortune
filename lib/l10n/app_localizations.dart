import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wheel of Fortune'**
  String get appTitle;

  /// No description provided for @tabWheel.
  ///
  /// In en, this message translates to:
  /// **'Wheel'**
  String get tabWheel;

  /// No description provided for @tabManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get tabManage;

  /// No description provided for @noWheelsYet.
  ///
  /// In en, this message translates to:
  /// **'No wheels yet'**
  String get noWheelsYet;

  /// No description provided for @createFirstWheelHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first wheel from the manage page.'**
  String get createFirstWheelHint;

  /// No description provided for @goToManage.
  ///
  /// In en, this message translates to:
  /// **'Go to Manage'**
  String get goToManage;

  /// No description provided for @spin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spin;

  /// No description provided for @spinning.
  ///
  /// In en, this message translates to:
  /// **'Spinning...'**
  String get spinning;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @noResultYet.
  ///
  /// In en, this message translates to:
  /// **'No result yet'**
  String get noResultYet;

  /// No description provided for @tapSliceForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a slice to view details'**
  String get tapSliceForDetails;

  /// No description provided for @atLeastTwoItems.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 items to spin'**
  String get atLeastTwoItems;

  /// No description provided for @wheels.
  ///
  /// In en, this message translates to:
  /// **'Wheels'**
  String get wheels;

  /// No description provided for @addWheel.
  ///
  /// In en, this message translates to:
  /// **'Add Wheel'**
  String get addWheel;

  /// No description provided for @deleteWheel.
  ///
  /// In en, this message translates to:
  /// **'Delete Wheel'**
  String get deleteWheel;

  /// No description provided for @deleteWheelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this wheel?'**
  String get deleteWheelConfirmTitle;

  /// No description provided for @deleteWheelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteWheelConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @wheelName.
  ///
  /// In en, this message translates to:
  /// **'Wheel Name'**
  String get wheelName;

  /// No description provided for @probabilityMode.
  ///
  /// In en, this message translates to:
  /// **'Probability Mode'**
  String get probabilityMode;

  /// No description provided for @modeEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get modeEqual;

  /// No description provided for @modeWeighted.
  ///
  /// In en, this message translates to:
  /// **'Weighted'**
  String get modeWeighted;

  /// No description provided for @modeSoftAntiRepeat.
  ///
  /// In en, this message translates to:
  /// **'Soft Anti-Repeat'**
  String get modeSoftAntiRepeat;

  /// No description provided for @spinDuration.
  ///
  /// In en, this message translates to:
  /// **'Spin Duration'**
  String get spinDuration;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsShort(String seconds);

  /// No description provided for @palette.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get palette;

  /// No description provided for @paletteOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get paletteOcean;

  /// No description provided for @paletteSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get paletteSunset;

  /// No description provided for @paletteMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get paletteMint;

  /// No description provided for @paletteMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get paletteMono;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get itemTitle;

  /// No description provided for @itemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get itemSubtitle;

  /// No description provided for @itemTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get itemTags;

  /// No description provided for @itemNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get itemNote;

  /// No description provided for @itemColorHex.
  ///
  /// In en, this message translates to:
  /// **'Color Hex'**
  String get itemColorHex;

  /// No description provided for @itemWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get itemWeight;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @invalidColorHex.
  ///
  /// In en, this message translates to:
  /// **'Use #RRGGBB or #AARRGGBB'**
  String get invalidColorHex;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight must be a positive number'**
  String get invalidWeight;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @quickImport.
  ///
  /// In en, this message translates to:
  /// **'Quick Import'**
  String get quickImport;

  /// No description provided for @quickImportItems.
  ///
  /// In en, this message translates to:
  /// **'Quick Add Items'**
  String get quickImportItems;

  /// No description provided for @quickImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste quick item syntax here...'**
  String get quickImportHint;

  /// No description provided for @quickImportExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example Input'**
  String get quickImportExampleLabel;

  /// No description provided for @quickImportExampleText.
  ///
  /// In en, this message translates to:
  /// **'apple;banana;grape;\n\n苹果,site:楼下,color:blue;香蕉,超市,red;梨,淘宝,orange;'**
  String get quickImportExampleText;

  /// No description provided for @syntaxGuideEntry.
  ///
  /// In en, this message translates to:
  /// **'Syntax Guide'**
  String get syntaxGuideEntry;

  /// No description provided for @syntaxGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Import Syntax'**
  String get syntaxGuideTitle;

  /// No description provided for @syntaxGuideOverview.
  ///
  /// In en, this message translates to:
  /// **'Use this to append items to the current wheel only.'**
  String get syntaxGuideOverview;

  /// No description provided for @syntaxGuideRule1.
  ///
  /// In en, this message translates to:
  /// **'1. Use semicolon or newline to separate items. Chinese/English and full/half punctuation are all supported.'**
  String get syntaxGuideRule1;

  /// No description provided for @syntaxGuideRule2.
  ///
  /// In en, this message translates to:
  /// **'2. The first segment of each item is always the title.'**
  String get syntaxGuideRule2;

  /// No description provided for @syntaxGuideRule3.
  ///
  /// In en, this message translates to:
  /// **'3. In the first item, you can define extra fields with key:value, such as site:xxx,color:xxx.'**
  String get syntaxGuideRule3;

  /// No description provided for @syntaxGuideRule4.
  ///
  /// In en, this message translates to:
  /// **'4. Later items can omit keys and follow the same order from the first item.'**
  String get syntaxGuideRule4;

  /// No description provided for @syntaxGuideExample1Title.
  ///
  /// In en, this message translates to:
  /// **'Example 1 (title only)'**
  String get syntaxGuideExample1Title;

  /// No description provided for @syntaxGuideExample1Value.
  ///
  /// In en, this message translates to:
  /// **'apple;banana;grape;'**
  String get syntaxGuideExample1Value;

  /// No description provided for @syntaxGuideExample2Title.
  ///
  /// In en, this message translates to:
  /// **'Example 2 (site + color)'**
  String get syntaxGuideExample2Title;

  /// No description provided for @syntaxGuideExample2Value.
  ///
  /// In en, this message translates to:
  /// **'苹果,site:楼下,color:blue;香蕉,超市,red;梨,淘宝,orange;'**
  String get syntaxGuideExample2Value;

  /// No description provided for @quickImportAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {count} item(s) to current wheel'**
  String quickImportAdded(int count);

  /// No description provided for @quickImportSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) skipped due to max item limit'**
  String quickImportSkipped(int count);

  /// No description provided for @quickExport.
  ///
  /// In en, this message translates to:
  /// **'Quick Export'**
  String get quickExport;

  /// No description provided for @importWheelCode.
  ///
  /// In en, this message translates to:
  /// **'Import Wheel Code'**
  String get importWheelCode;

  /// No description provided for @pasteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste wheel code here...'**
  String get pasteCodeHint;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @exportCopied.
  ///
  /// In en, this message translates to:
  /// **'Wheel code copied'**
  String get exportCopied;

  /// No description provided for @importCreatedWheel.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} item(s), created new wheel'**
  String importCreatedWheel(int count);

  /// No description provided for @importFailedNoValidItem.
  ///
  /// In en, this message translates to:
  /// **'No valid items found'**
  String get importFailedNoValidItem;

  /// No description provided for @importErrorSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} line(s) failed to import'**
  String importErrorSummary(int count);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dslErrorMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing title'**
  String get dslErrorMissingTitle;

  /// No description provided for @dslErrorTooManyFields.
  ///
  /// In en, this message translates to:
  /// **'Too many fields (max 6)'**
  String get dslErrorTooManyFields;

  /// No description provided for @dslErrorInvalidColor.
  ///
  /// In en, this message translates to:
  /// **'Invalid color format'**
  String get dslErrorInvalidColor;

  /// No description provided for @dslErrorInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight'**
  String get dslErrorInvalidWeight;

  /// No description provided for @dslErrorInvalidHeader.
  ///
  /// In en, this message translates to:
  /// **'Invalid metadata header'**
  String get dslErrorInvalidHeader;

  /// No description provided for @dslErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: {message}'**
  String dslErrorLabel(int line, String message);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @newWheelDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New Wheel'**
  String get newWheelDefaultName;

  /// No description provided for @newItemDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItemDefaultTitle;

  /// No description provided for @currentWheelSettings.
  ///
  /// In en, this message translates to:
  /// **'Current Wheel Settings'**
  String get currentWheelSettings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @drawMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get drawMode;

  /// No description provided for @displayModeWheel.
  ///
  /// In en, this message translates to:
  /// **'Wheel'**
  String get displayModeWheel;

  /// No description provided for @displayModeCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get displayModeCoin;

  /// No description provided for @displayModeDice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get displayModeDice;

  /// No description provided for @displayModeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get displayModeCard;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @modeCoinHint.
  ///
  /// In en, this message translates to:
  /// **'Pick two items from this wheel and toss a coin.'**
  String get modeCoinHint;

  /// No description provided for @modeDiceHint.
  ///
  /// In en, this message translates to:
  /// **'Map each face to an item, then roll to get the top face.'**
  String get modeDiceHint;

  /// No description provided for @modeCardHint.
  ///
  /// In en, this message translates to:
  /// **'Shuffle to turn cards face-down, then tap one card to reveal.'**
  String get modeCardHint;

  /// No description provided for @coinSideA.
  ///
  /// In en, this message translates to:
  /// **'Coin Side A'**
  String get coinSideA;

  /// No description provided for @coinSideB.
  ///
  /// In en, this message translates to:
  /// **'Coin Side B'**
  String get coinSideB;

  /// No description provided for @coinAutoFilledPartner.
  ///
  /// In en, this message translates to:
  /// **'Second side auto-filled from previous partner.'**
  String get coinAutoFilledPartner;

  /// No description provided for @coinNeedSelection.
  ///
  /// In en, this message translates to:
  /// **'Select at least one coin side.'**
  String get coinNeedSelection;

  /// No description provided for @coinNeedManualSecond.
  ///
  /// In en, this message translates to:
  /// **'No valid previous partner. Select the second side manually.'**
  String get coinNeedManualSecond;

  /// No description provided for @coinNeedDistinct.
  ///
  /// In en, this message translates to:
  /// **'Coin sides must be two different items.'**
  String get coinNeedDistinct;

  /// No description provided for @coinToss.
  ///
  /// In en, this message translates to:
  /// **'Toss Coin'**
  String get coinToss;

  /// No description provided for @coinReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get coinReady;

  /// No description provided for @diceSides.
  ///
  /// In en, this message translates to:
  /// **'Dice Sides'**
  String get diceSides;

  /// No description provided for @diceMissingItem.
  ///
  /// In en, this message translates to:
  /// **'Missing item (select a replacement)'**
  String get diceMissingItem;

  /// No description provided for @diceFaceNumber.
  ///
  /// In en, this message translates to:
  /// **'Face {face}'**
  String diceFaceNumber(String face);

  /// No description provided for @diceDuplicateNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Each face must map to a different item.'**
  String get diceDuplicateNotAllowed;

  /// No description provided for @diceNeedCompleteMapping.
  ///
  /// In en, this message translates to:
  /// **'Complete all faces with valid items before rolling.'**
  String get diceNeedCompleteMapping;

  /// No description provided for @diceRoll.
  ///
  /// In en, this message translates to:
  /// **'Roll Dice'**
  String get diceRoll;

  /// No description provided for @cardRevealAllToggle.
  ///
  /// In en, this message translates to:
  /// **'Reveal all cards after pick'**
  String get cardRevealAllToggle;

  /// No description provided for @cardShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get cardShuffle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
