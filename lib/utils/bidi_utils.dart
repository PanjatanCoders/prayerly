import 'package:flutter/material.dart';

/// Picks [TextDirection.rtl] when [text]'s first strong-directional
/// character is in the Arabic/Urdu script block, [TextDirection.ltr]
/// otherwise (digits/punctuation/spaces are direction-neutral and skipped).
///
/// Needed because [Dhikr.translation]/[Dhikr.meaning] hold plain English for
/// most entries but Urdu script for others (e.g. the daily wazifa set) -
/// without this, a `Text` widget with no explicit `textDirection` inherits
/// the app's ambient (LTR) `Directionality`, which left-aligns Urdu
/// paragraphs instead of right-aligning them.
TextDirection autoTextDirection(String text) {
  for (final rune in text.runes) {
    if (rune >= 0x0600 && rune <= 0x06FF) return TextDirection.rtl; // Arabic
    if (rune >= 0x0750 && rune <= 0x077F) return TextDirection.rtl; // Arabic Supplement
    if (rune >= 0xFB50 && rune <= 0xFDFF) return TextDirection.rtl; // Arabic Presentation Forms-A
    if (rune >= 0xFE70 && rune <= 0xFEFF) return TextDirection.rtl; // Arabic Presentation Forms-B
    if ((rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A)) {
      return TextDirection.ltr;
    }
  }
  return TextDirection.ltr;
}
