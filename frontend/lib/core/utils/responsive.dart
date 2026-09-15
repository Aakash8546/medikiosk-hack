import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';














class Responsive {
  final BuildContext context;
  final double width;
  final double height;

  Responsive._(this.context, this.width, this.height);

  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Responsive._(context, size.width, size.height);
  }

  

  bool get isPhone => width < DesignTokens.breakpointCompact;
  bool get isTablet =>
      width >= DesignTokens.breakpointCompact &&
      width < DesignTokens.breakpointTablet;
  bool get isKiosk => width >= DesignTokens.breakpointTablet;

  
  int get _tier => isKiosk ? 2 : (isTablet ? 1 : 0);

  

  
  double get horizontalPadding {
    switch (_tier) {
      case 0:
        return 16;
      case 1:
        return 24;
      case 2:
        return 32;
      default:
        return 16;
    }
  }

  EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: horizontalPadding);

  
  double get cardPadding {
    switch (_tier) {
      case 0:
        return 12;
      case 1:
        return 16;
      case 2:
        return 20;
      default:
        return 12;
    }
  }

  EdgeInsets get cardEdgeInsets =>
      EdgeInsets.all(cardPadding);

  
  double get sectionSpacing {
    switch (_tier) {
      case 0:
        return 12;
      case 1:
        return 16;
      case 2:
        return 20;
      default:
        return 12;
    }
  }

  
  double get optionSpacing {
    switch (_tier) {
      case 0:
        return 6;
      case 1:
        return 8;
      case 2:
        return 10;
      default:
        return 6;
    }
  }

  

  
  
  double fontSize(double base) {
    switch (_tier) {
      case 0:
        return base;
      case 1:
        return base + 1;
      case 2:
        return base + 2;
      default:
        return base;
    }
  }

  double get titleFontSize => fontSize(15);
  double get subtitleFontSize => fontSize(12);
  double get bodyFontSize => fontSize(13);
  double get captionFontSize => fontSize(11);
  double get smallFontSize => fontSize(10);
  double get optionTitleFontSize => fontSize(12);
  double get optionDescFontSize => fontSize(10);

  

  double get emojiSize {
    switch (_tier) {
      case 0:
        return 24;
      case 1:
        return 28;
      case 2:
        return 32;
      default:
        return 24;
    }
  }

  double get headerIconSize {
    switch (_tier) {
      case 0:
        return 20;
      case 1:
        return 22;
      case 2:
        return 24;
      default:
        return 20;
    }
  }

  

  
  int get optionColumns {
    switch (_tier) {
      case 0:
        return 3; 
      case 1:
        return 4; 
      case 2:
        return 4; 
      default:
        return 3;
    }
  }

  
  int get snapshotColumns {
    switch (_tier) {
      case 0:
        return 3;
      case 1:
        return 5;
      case 2:
        return 5;
      default:
        return 3;
    }
  }

  
  int get twoColumnThreshold => 360;

  

  double get optionCardHeight {
    switch (_tier) {
      case 0:
        return 100;
      case 1:
        return 110;
      case 2:
        return 120;
      default:
        return 100;
    }
  }

  double get iconCircleSize {
    switch (_tier) {
      case 0:
        return 40;
      case 1:
        return 48;
      case 2:
        return 56;
      default:
        return 40;
    }
  }

  double get borderRadius {
    switch (_tier) {
      case 0:
        return 12;
      case 1:
        return 14;
      case 2:
        return 16;
      default:
        return 12;
    }
  }

  

  double get buttonHeight {
    switch (_tier) {
      case 0:
        return 48;
      case 1:
        return 52;
      case 2:
        return 56;
      default:
        return 48;
    }
  }

  double get buttonFontSize => fontSize(14);

  

  double get progressDotSize {
    switch (_tier) {
      case 0:
        return 10;
      case 1:
        return 12;
      case 2:
        return 14;
      default:
        return 10;
    }
  }

  double get progressLabelFontSize => fontSize(9);

  

  
  
  double? get maxContentWidth {
    if (isKiosk) return 800;
    return null;
  }

  
  bool get useWideLayout => width > 500;

  
  bool get showProgressLabels => width > 360;
}