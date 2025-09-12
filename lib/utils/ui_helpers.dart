import 'package:flutter/widgets.dart';
import '../constants/theme_constants.dart';

class UIHelpers {
  // Gaps
  static const SizedBox gapXS = SizedBox(height: ThemeConstants.spacingXS, width: ThemeConstants.spacingXS);
  static const SizedBox gapS = SizedBox(height: ThemeConstants.spacingS, width: ThemeConstants.spacingS);
  static const SizedBox gapM = SizedBox(height: ThemeConstants.spacingM, width: ThemeConstants.spacingM);
  static const SizedBox gapL = SizedBox(height: ThemeConstants.spacingL, width: ThemeConstants.spacingL);
  static const SizedBox gapXL = SizedBox(height: ThemeConstants.spacingXL, width: ThemeConstants.spacingXL);

  // Vertical gaps
  static const SizedBox vXS = SizedBox(height: ThemeConstants.spacingXS);
  static const SizedBox vS = SizedBox(height: ThemeConstants.spacingS);
  static const SizedBox vM = SizedBox(height: ThemeConstants.spacingM);
  static const SizedBox vL = SizedBox(height: ThemeConstants.spacingL);
  static const SizedBox vXL = SizedBox(height: ThemeConstants.spacingXL);

  // Horizontal gaps
  static const SizedBox hXS = SizedBox(width: ThemeConstants.spacingXS);
  static const SizedBox hS = SizedBox(width: ThemeConstants.spacingS);
  static const SizedBox hM = SizedBox(width: ThemeConstants.spacingM);
  static const SizedBox hL = SizedBox(width: ThemeConstants.spacingL);
  static const SizedBox hXL = SizedBox(width: ThemeConstants.spacingXL);

  // Paddings
  static const EdgeInsets paddingAllM = EdgeInsets.all(ThemeConstants.spacingM);
  static const EdgeInsets paddingAllL = EdgeInsets.all(ThemeConstants.spacingL);
  static const EdgeInsets paddingSymmetricPage = EdgeInsets.symmetric(
    horizontal: ThemeConstants.spacingL,
    vertical: ThemeConstants.spacingM,
  );
}


