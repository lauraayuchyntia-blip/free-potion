# 🧪 Free Potion

**Free Potion** adalah aplikasi Motion Graphics & Video Editor untuk Android, terinspirasi dari Alight Motion.

> ✨ No watermark. No paywall. Free forever.

---

## Fitur

- 🎬 **Multi-layer editor** — Video, Image, Text, Shape, Audio, Effect layers
- ⏱️ **Timeline & Keyframes** — Animasi dengan keyframe per property
- ✨ **Visual Effects** — Glow, Blur, Color Correct, Distort, Shadow, Chromatic
- 📐 **Transform tools** — Position, Scale, Rotation, Opacity
- 🎨 **Dark theme** — UI elegan dengan warna ungu/teal magical
- 📱 **Multi aspect ratio** — 9:16 Reels, 16:9 Video, 1:1 Square, Custom
- 📤 **Export** — MP4, GIF, PNG Sequence, Still Image

---

## Build APK

### Via GitHub Actions (otomatis)
Setiap push ke `main` akan otomatis build APK. Download dari tab **Actions → Artifacts**.

### Manual (lokal)
```bash
# Install Flutter dulu: https://flutter.dev/docs/get-started/install
flutter pub get
flutter build apk --release
```

APK ada di: `build/app/outputs/flutter-apk/`

---

## Struktur Project

```
lib/
├── main.dart                 # Entry point
├── theme/
│   └── app_theme.dart        # Warna & typography
├── models/
│   └── project_model.dart    # Data model (Project, Layer, Keyframe)
├── providers/
│   └── editor_provider.dart  # State management
├── screens/
│   ├── home_screen.dart      # Project gallery
│   └── editor_screen.dart    # Main editor
└── widgets/
    ├── canvas_widget.dart    # Preview canvas
    ├── timeline_widget.dart  # Timeline & tracks
    ├── layers_panel.dart     # Layer management
    ├── toolbar_widget.dart   # Tools & zoom
    └── properties_panel.dart # Layer properties
```

---

## Tech Stack

- **Flutter** 3.19+ / Dart 3.0+
- **Provider** — State management
- **Google Fonts** — Typography
- **Image Picker** — Media import
- **Video Player** — Video preview

---

Made with 🧪 by Free Potion
