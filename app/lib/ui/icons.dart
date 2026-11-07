import 'dart:ui';

import 'package:prism_ui/icons/icons.dart';

/// 自绘的 24×24 线性图标，避免复制 Salt Player 的素材。
abstract final class SonoraGlyphs {
  static const songs = Glyph([
    GlyphCircle(7.5, 17.5, 2.5),
    GlyphCircle(17, 15.5, 2.5),
    GlyphLink(Offset(10, 17.5), Offset(10, 6.5), 0),
    GlyphLink(Offset(19.5, 15.5), Offset(19.5, 4.5), 0),
    GlyphLink(Offset(10, 6.5), Offset(19.5, 4.5), 0),
  ]);

  static const genre = Glyph([
    GlyphLink(Offset(5, 14), Offset(5, 10), 0),
    GlyphLink(Offset(9.5, 18), Offset(9.5, 6), 0),
    GlyphLink(Offset(14, 16), Offset(14, 8), 0),
    GlyphLink(Offset(18.5, 13), Offset(18.5, 11), 0),
  ]);

  static const album = Glyph([
    GlyphCircle(12, 12, 8),
    GlyphCircle(12, 12, 2.5, solid: true),
  ]);

  static const artist = Glyph([
    GlyphBox(9, 4, 15, 13, 3),
    GlyphArc(12, 16, 6, 0.15, 2.84),
    GlyphLink(Offset(12, 17.5), Offset(12, 20), 0),
    GlyphLink(Offset(8.5, 20), Offset(15.5, 20), 0),
  ]);

  static const folder = Glyph([
    GlyphPath(
      'M4 7.5C4 6.7 4.7 6 5.5 6h4l2 2h7'
      'c0.8 0 1.5 0.7 1.5 1.5v8'
      'c0 0.8-0.7 1.5-1.5 1.5h-13C4.7 19 4 18.3 4 17.5z',
    ),
  ]);

  static const library = Glyph([
    GlyphBox(4.5, 5.5, 8.5, 19, 1.5),
    GlyphBox(10.5, 4.5, 14.5, 19, 1.5),
    GlyphBox(16, 7, 19.5, 19, 1.5),
  ]);

  static const settings = Glyph([
    GlyphLink(Offset(4.5, 7.5), Offset(19.5, 7.5), 0),
    GlyphLink(Offset(4.5, 12), Offset(19.5, 12), 0),
    GlyphLink(Offset(4.5, 16.5), Offset(19.5, 16.5), 0),
    GlyphCircle(9, 7.5, 2.2),
    GlyphCircle(15, 12, 2.2),
    GlyphCircle(9, 16.5, 2.2),
  ]);

  static const star = Glyph([
    GlyphPath(
      'M12 4.5l2.3 4.7 5.2 0.8-3.8 3.7 0.9 5.2'
      '-4.6-2.4-4.6 2.4 0.9-5.2L4.5 10l5.2-0.8z',
    ),
  ]);

  static const heart = Glyph([
    GlyphPath(
      'M12 20C12 20 4 15 4 9.5'
      'C4 6.5 6.5 4.5 9 4.5'
      'C10.5 4.5 11.5 5.2 12 6'
      'C12.5 5.2 13.5 4.5 15 4.5'
      'C17.5 4.5 20 6.5 20 9.5'
      'C20 15 12 20 12 20Z',
    ),
  ]);

  static const plus = Glyph([
    GlyphPath('M12 5.5v13', role: GlyphRole.line),
    GlyphPath('M5.5 12h13', role: GlyphRole.line),
  ]);

  static const play = Glyph([
    GlyphPath('M8.5 5.5L18.5 12L8.5 18.5Z', solid: true),
  ]);

  static const pause = Glyph([
    GlyphPath('M8 5.5h3v13H8zM13 5.5h3v13h-3z', solid: true),
  ]);

  static const previous = Glyph([
    GlyphPath('M6.5 5.5v13', role: GlyphRole.line),
    GlyphPath('M18.5 6L9.5 12l9 6z', solid: true),
  ]);

  static const next = Glyph([
    GlyphPath('M17.5 5.5v13', role: GlyphRole.line),
    GlyphPath('M5.5 6L14.5 12l-9 6z', solid: true),
  ]);

  static const repeat = Glyph([
    GlyphPath('M7 7.5h9.5c1.7 0 3 1.3 3 3v0.5', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(16.5, 5),
      GlyphVertex(19, 7.5),
      GlyphVertex(16.5, 10),
    ], role: GlyphRole.line),
    GlyphPath('M17 16.5H7.5c-1.7 0-3-1.3-3-3V13', role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(7.5, 10.5),
      GlyphVertex(5, 13),
      GlyphVertex(7.5, 15.5),
    ], role: GlyphRole.line),
  ]);

  static const shuffle = Glyph([
    GlyphPolyline([
      GlyphVertex(4.5, 8),
      GlyphVertex(9, 8),
      GlyphVertex(15, 16),
      GlyphVertex(19.5, 16),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(16.5, 13.5),
      GlyphVertex(19.5, 16),
      GlyphVertex(16.5, 18.5),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(4.5, 16),
      GlyphVertex(9, 16),
      GlyphVertex(15, 8),
      GlyphVertex(19.5, 8),
    ], role: GlyphRole.line),
    GlyphPolyline([
      GlyphVertex(16.5, 5.5),
      GlyphVertex(19.5, 8),
      GlyphVertex(16.5, 10.5),
    ], role: GlyphRole.line),
  ]);

  static const queue = Glyph([
    GlyphLink(Offset(4.5, 7), Offset(14, 7), 0),
    GlyphLink(Offset(4.5, 12), Offset(12, 12), 0),
    GlyphLink(Offset(4.5, 17), Offset(10, 17), 0),
    GlyphPath('M16.5 11.5L21 14.5l-4.5 3z', solid: true),
  ]);

  static const volume = Glyph([
    GlyphPath('M4.5 10h3l4-3v10l-4-3h-3z', role: GlyphRole.line),
    GlyphPath('M15 9.5c1.2 1.4 1.2 3.6 0 5', role: GlyphRole.line),
    GlyphPath('M17.5 7.5c2.4 2.5 2.4 6.5 0 9', role: GlyphRole.line),
  ]);

  static const mute = Glyph([
    GlyphPath('M4.5 10h3l4-3v10l-4-3h-3z', role: GlyphRole.line),
    GlyphPath('M15 9.5l4 5', role: GlyphRole.line),
    GlyphPath('M19 9.5l-4 5', role: GlyphRole.line),
  ]);

  static const minimize = Glyph([GlyphPath('M6 12h12', role: GlyphRole.line)]);

  static const maximize = Glyph([GlyphBox(6, 6, 18, 18, 1.5)]);

  static const restore = Glyph([
    GlyphBox(6, 9, 15, 18, 1.5),
    GlyphBox(9, 6, 18, 15, 1.5),
  ]);
}
