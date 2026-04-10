// ============================================================
//  HEALIO — EMERGENCY VIDEO LINKS
//  Edit this file to change any tutorial video.
//
//  HOW TO FIND A WORKING LINK:
//  1. Open YouTube on your phone/browser
//  2. Search e.g. "CPR tutorial first aid"
//  3. Open any video and copy the full URL from the address bar
//     Example: https://www.youtube.com/watch?v=XXXXXXXXXXX
//  4. Paste it below between the single quotes
//
//  Any YouTube URL works — long or short (youtu.be/...) both fine.
// ============================================================

class VideoLinks {
  // ── Paste your YouTube URLs below ──────────────────────────

  static const String cpr =
      'https://www.youtube.com/watch?v=cosVBV96E2g';
  //   ^ CPR & Cardiac Arrest tutorial

  static const String severeBleedingControl =
      'https://www.youtube.com/watch?v=NxO5LvgqZe0';
  //   ^ Severe Bleeding / wound control tutorial

  static const String choking =
      'https://www.youtube.com/watch?v=PA9hpOnvtCk';
  //   ^ Choking / Heimlich manoeuvre tutorial

  static const String burns =
      'https://www.youtube.com/watch?v=XJGPzl3ENKo';
  //   ^ Burns first aid tutorial

  static const String snakeBite =
      'https://www.youtube.com/watch?v=kFbvJkbUukQ';
  //   ^ Snake bite first aid tutorial

  static const String fracture =
      'https://www.youtube.com/watch?v=2v8vlXgGXwE';
  //   ^ Fracture / broken bone first aid tutorial

  static const String electricShock =
      'https://www.youtube.com/watch?v=xDQi1I04mXc';
  //   ^ Electric shock first aid tutorial

  static const String stroke =
      'https://www.youtube.com/watch?v=PhH9a0kIwmk';
  //   ^ Stroke recognition (FAST) tutorial

  static const String seizure =
      'https://www.youtube.com/watch?v=Ovsw7tdneqE';
  //   ^ Seizure first aid tutorial

  // ── Do NOT edit below this line ────────────────────────────

  /// Returns the URL for a given emergency title.
  /// Falls back to a YouTube search if the title isn't recognised.
  static String forEmergency(String title) {
    final t = title.toLowerCase();
    if (t.contains('cpr') || t.contains('cardiac')) return cpr;
    if (t.contains('bleed')) return severeBleedingControl;
    if (t.contains('chok')) return choking;
    if (t.contains('burn')) return burns;
    if (t.contains('snake')) return snakeBite;
    if (t.contains('fracture') || t.contains('broken')) return fracture;
    if (t.contains('electric') || t.contains('shock')) return electricShock;
    if (t.contains('stroke')) return stroke;
    if (t.contains('seizure')) return seizure;
    // Fallback — opens a YouTube search for the emergency
    return 'https://www.youtube.com/results?search_query=${Uri.encodeComponent('$title first aid tutorial')}';
  }
}
