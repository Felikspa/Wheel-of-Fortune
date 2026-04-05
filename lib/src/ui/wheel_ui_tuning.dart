import 'package:flutter/material.dart';

class WheelUiTuning {
  const WheelUiTuning._();

  // Page layout
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 0, 16, 45);
  static const double wheelSizeByWidthFactor = 1.38;
  static const double wheelVerticalAlignmentY = -0.14;
  static const double wheelBoundaryMarginFactor = 1.4;
  static const double wheelMaxScale = 3.2;
  static const double panEnableScaleThreshold = 1.01;
  static const double detailScaleRepaintStep = 0.02;
  static const double spinControlsTopGap = 22;
  static const double spinCompleteMinTurns = 2;

  // Wheel geometry
  static const double paintedWheelRadiusFactor = 0.97;

  // Text policy
  static const double densityBaseCount = 10;
  static const double densitySpanCount = 90;
  static const double baseFontStart = 16.0;
  static const double baseFontDensityDrop = 4.6;
  static const double baseFontMin = 9.6;
  static const double baseFontMax = 16.0;
  static const double zoomFontGainStart = 0.24;
  static const double zoomFontGainDensityDrop = 0.24;
  static const double zoomFontGainMin = 0.12;
  static const double zoomFontGainMax = 0.24;
  static const double maxFontStart = 14.8;
  static const double maxFontDensityDrop = 3.2;
  static const double maxFontClampMin = 11.4;
  static const double maxFontClampMax = 16.0;
  static const double maxFontBaseExtra = 0.6;

  static const double arcZoomGainStart = 1.0;
  static const double arcZoomGainPerZoom = 0.95;
  static const double arcZoomGainMax = 3.1;
  static const int lowItemCountThreshold = 16;
  static const double minArcFactorLowBase = 0.66;
  static const double minArcFactorLowDensity = 0.2;
  static const double minArcFactorHighBase = 0.72;
  static const double minArcFactorHighDensity = 0.42;

  static const int strictSingleCharMinItems = 120;
  static const double strictSingleCharBase = 0.16;
  static const double strictSingleCharDensity = 0.04;
  static const int minRelaxedChars = 6;
  static const double relaxedCharsWidthFactor = 0.10;

  static const double labelRadiusBase = 0.58;
  static const double labelRadiusDensityGain = 0.22;
  static const double labelRadiusZoomGain = 0.03;
  static const double labelRadiusMin = 0.52;
  static const double labelRadiusMax = 0.86;
  static const double labelRadiusSingleCharBoost = 0.14;
  static const double labelRadiusSingleCharMax = 0.88;

  static const double innerBoundaryBase = 0.22;
  static const double innerBoundaryDensityGain = 0.18;
  static const double outerBoundaryFactor = 0.9;
  static const double radialWidthMin = 14.0;

  static const double lowZoomWidthBoostStart = 1.28;
  static const double lowZoomWidthBoostPerZoom = 0.12;
  static const double lowZoomWidthBoostMin = 1.0;
  static const double arcWidthCapFactor = 1.4;
  static const double arcWidthCapMinFontFactor = 2.0;
  static const double arcWidthCapMaxWheelFactor = 0.98;
  static const double singleCharWidthFactor = 1.9;
  static const int preTrimExtraChars = 8;

  // Edge gesture + unified spin physics
  static const double edgeTouchInnerRadiusFactor = 0.2;
  static const double edgeTouchOuterRadiusFactor = 1.04;
  static const double edgeTouchSideBandMinXFactor = 0.2;
  static const double flickTangentialVelocityThreshold = 240;
  static const double freeSpinAngularVelocityClamp = 18.0;
  static const double freeSpinAngularVelocityMin = 3.6;
  static const double freeSpinFlickImpulseFactor = 1.22;
  static const double freeSpinBaseFriction = 4.0;
  static const double freeSpinNaturalVelocityFrictionGain = 0.24;
  static const double freeSpinNaturalFrictionMax = 1000.0;
  static const double freeSpinBrakeFriction = 25;
  static const double freeSpinBrakeVelocityFrictionGain = 1;
  static const double freeSpinBrakeFrictionMax = 100000.0;
  static const double freeSpinStopVelocity = 0.16;
  static const int brakePressDelayMs = 150;
  static const int brakeHapticIntervalMs = 120;
  static const double targetSpinBrakeSpeedScale = 2.15;
  static const double targetSpinBrakeVelocityScaleGain = 0.24;
  static const double targetSpinBrakeSpeedScaleMax = 12.0;
  static const double targetSpinMinDurationSeconds = 0.18;
  static const double targetSpinMaxDurationSeconds = 12.0;
  static const double targetSpinFlickAccelFactor = 1.08;
  static const double targetSpinFlickDecelFactor = 0.9;

  // High-speed instability (wobble) simulation
  static const double spinInstabilityStartRpm = 800.0;
  static const double spinInstabilityRampRpm = 4200.0;
  static const double spinInstabilityVisualHzBase = 2.0;
  static const double spinInstabilityVisualHzGain = 15.0;
  static const double spinInstabilityRotationAmpBase = 0.002;
  static const double spinInstabilityRotationAmpGain = 0.048;
  static const double spinInstabilityTranslationAmpBaseFactor = 0.001;
  static const double spinInstabilityTranslationAmpGainFactor = 0.015;
  static const double spinInstabilityTranslationAmpMaxFactor = 0.5;
  static const double spinInstabilityDecayRate = 14.0;
  static const double spinInstabilityHapticStartRpm = 500.0;
  static const double spinInstabilityHapticRampRpm = 5600.0;
  static const double spinInstabilityHapticStrongIntensity = 0.56;
  static const int spinInstabilityHapticMaxIntervalMs = 300;
  static const int spinInstabilityHapticMinIntervalMs = 8;
  static const int spinInstabilityHapticContinuousIntervalMs = 8;
}
