import 'package:flutter/material.dart';



abstract final class DesignTokens {
  
  static const Color primary900 = Color(0xFF064E5B);
  static const Color primary700 = Color(0xFF087F8C);
  static const Color primary600 = Color(0xFF0B8A94);
  static const Color primary500 = Color(0xFF0F9FA8);
  static const Color primary100 = Color(0xFFDDF6F7);
  static const Color primary50 = Color(0xFFF1FBFB);

  
  static const Color neutral950 = Color(0xFF111827);
  static const Color neutral900 = Color(0xFF1A2332);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  
  static const Color success700 = Color(0xFF166534);
  static const Color success500 = Color(0xFF22C55E);
  static const Color success100 = Color(0xFFDCFCE7);

  
  static const Color warning700 = Color(0xFF92400E);
  static const Color warning600 = Color(0xFFD97706);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning50 = Color(0xFFFFFBEB);

  
  static const Color critical700 = Color(0xFF991B1B);
  static const Color critical500 = Color(0xFFDC2626);
  static const Color critical100 = Color(0xFFFEE2E2);

  
  static const Color info700 = Color(0xFF1D4ED8);
  static const Color info500 = Color(0xFF3B82F6);
  static const Color info100 = Color(0xFFDBEAFE);

  
  static const Color accent500 = Color(0xFF6366F1);
  static const Color accent600 = Color(0xFF5457E5);
  static const Color accent50 = Color(0xFFEEF0FF);

  
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacing2XL = 48;
  static const double spacing3XL = 64;
  static const double spacing4XL = 96;

  
  static const double defaultHorizontalPadding = 32;
  static const double kioskHorizontalPadding = 48;
  static const double largeKioskHorizontalPadding = 64;

  
  static const double radiusSmall = 8;
  static const double radiusInput = 12;
  static const double radiusButton = 12;
  static const double radiusCard = 16;
  static const double radiusModal = 20;
  static const double radiusLargeCard = 24;

  
  static const double elevationCard = 1;
  static const double elevationModal = 12;
  static const double elevationFAB = 6;

  
  static const double buttonHeight = 56;
  static const double buttonHorizontalPadding = 24;
  static const double voiceButtonMinSize = 64;

  
  static const double inputHeight = 56;

  
  static const double breakpointCompact = 600;
  static const double breakpointTablet = 1024;
  static const double breakpointKiosk = 1440;
}