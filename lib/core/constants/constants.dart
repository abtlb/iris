import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// === PRIMARY COLORS ===
const Color kPrimaryColor = Color(0xFF014597); // Material Design Blue
const Color kSecondaryColor = Color(0xFFB1C9EF); // Light Blue
const Color kAccentColor = Color(0xFFCB63FF); // Purple (RGB 203, 99, 255)

// === BACKGROUND COLORS ===
const Color kBackgroundColor = Color(0xFFF4F4F4); // Light Gray
const Color kSurfaceColor = Color(0xFFFFFFFF); // White
const Color kCardColor = Color(0xFFFFFFFF); // White

// === BLUE PALETTE ===
const Color kBlueLight = Color(0xFFADD8E6); // Light Blue (RGB 173, 216, 230)
const Color kBlueMedium = Color(0xFF71B8FF); // Medium Blue
const Color kBlueDark = Color(0xFF1B66D3); // Dark Blue

// === FUNCTIONAL COLORS ===
const Color kSuccessColor = Color(0xFF1F6C23); // Green
const Color kWarningColor = Color(0xFFA55605); // Orange (notification color)
const Color kErrorColor = Color(0xFF970C00); // Red
const Color kInfoColor = Color(0xFF034C85); // Blue

// === TEXT COLORS ===
const Color kTextPrimary = Color(0xFF212121); // Dark Gray
const Color kTextSecondary = Color(0xFF757575); // Medium Gray
const Color kTextHint = Color(0xFFBDBDBD); // Light Gray
const Color kTextLight = Color(0xFFFFFFFF); // White
const Color kTextDisabled = Color(0xFF9E9E9E); // Disabled Gray

// === UI ELEMENT COLORS ===
const Color kDrawerColor = Color(0xFF363533); // Dark Gray
const Color kDividerColor = Color(0xFFE0E0E0); // Light Gray
const Color kBorderColor = Color(0xFFE0E0E0); // Light Gray
const Color kShadowColor = Color(0x1F000000); // Black with transparency

// === DYNAMIC COLORS (with transparency) ===
Color kContainerColor = Colors.grey.withOpacity(0.4); // 40% opacity
Color kOverlayColor = kPrimaryColor.withOpacity(0.4); // 40% opacity
Color kShimmerBase = Colors.grey.shade300;
Color kShimmerHighlight = Colors.grey.shade100;

// === STATE COLORS ===
const Color kDisabledColor = Color(0xFFE0E0E0); // Light Gray
const Color kSelectedColor = Color(0xFFE3F2FD); // Very Light Blue
const Color kHoverColor = Color(0xFFF5F5F5); // Light Gray
const Color kFocusColor = Color(0xFFBBDEFB); // Light Blue

// === BRAND COLORS ===
const Color kBrandPrimary = Color(0xFF2196F3); // Same as primary
const Color kBrandSecondary = Color(0xFFCB63FF); // Purple accent

// === GRADIENTS ===
const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryColor, kBlueMedium],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kSecondaryGradient = LinearGradient(
  colors: [kAccentColor, kBlueDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// === FONT FAMILY ===
String kFont = GoogleFonts.playfairDisplay().fontFamily!;

// === COLOR SCHEME ===
const ColorScheme kLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: kPrimaryColor,
  onPrimary: kTextLight,
  secondary: kSecondaryColor,
  onSecondary: kTextPrimary,
  error: kErrorColor,
  onError: kTextLight,
  background: kBackgroundColor,
  onBackground: kTextPrimary,
  surface: kSurfaceColor,
  onSurface: kTextPrimary,
);

const ColorScheme kDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kPrimaryColor,
  onPrimary: kTextLight,
  secondary: kSecondaryColor,
  onSecondary: kTextPrimary,
  error: kErrorColor,
  onError: kTextLight,
  background: Color(0xFF121212),
  onBackground: kTextLight,
  surface: Color(0xFF1E1E1E),
  onSurface: kTextLight,
);

const int triggerOnPeriod = 200;
const int triggerOnDelay = 80;
const int triggerOffPeriod = 500;
const int triggerCycleEnd = 500;