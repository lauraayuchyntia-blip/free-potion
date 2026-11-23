import 'package:flutter/material.dart';

enum LayerType { video, image, text, shape, audio, effect }

enum BlendMode2 { normal, multiply, screen, overlay, add, darken, lighten }

class Keyframe {
  final double time; // in seconds
  final dynamic value;
  final String easing; // linear, ease, easeIn, easeOut, bounce

  Keyframe({required this.time, required this.value, this.easing = 'linear'});

  Map<String, dynamic> toJson() => {
    'time': time,
    'value': value,
    'easing': easing,
  };
}

class LayerProperty {
  double x;
  double y;
  double scaleX;
  double scaleY;
  double rotation;
  double opacity;
  List<Keyframe> xKeyframes;
  List<Keyframe> yKeyframes;
  List<Keyframe> opacityKeyframes;
  List<Keyframe> scaleKeyframes;
  List<Keyframe> rotationKeyframes;

  LayerProperty({
    this.x = 0,
    this.y = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.rotation = 0,
    this.opacity = 1,
    List<Keyframe>? xKeyframes,
    List<Keyframe>? yKeyframes,
    List<Keyframe>? opacityKeyframes,
    List<Keyframe>? scaleKeyframes,
    List<Keyframe>? rotationKeyframes,
  })  : xKeyframes = xKeyframes ?? [],
        yKeyframes = yKeyframes ?? [],
        opacityKeyframes = opacityKeyframes ?? [],
        scaleKeyframes = scaleKeyframes ?? [],
        rotationKeyframes = rotationKeyframes ?? [];
}

class EffectLayer {
  final String id;
  final String name;
  final String type; // blur, glow, colorCorrect, distort, shadow
  bool enabled;
  Map<String, dynamic> params;

  EffectLayer({
    required this.id,
    required this.name,
    required this.type,
    this.enabled = true,
    Map<String, dynamic>? params,
  }) : params = params ?? {};
}

class ProjectLayer {
  final String id;
  String name;
  LayerType type;
  bool visible;
  bool locked;
  bool solo;
  double startTime;
  double endTime;
  double duration;
  String? mediaPath;
  String? text;
  Color? color;
  String? fontFamily;
  double? fontSize;
  Color? fillColor;
  Color? strokeColor;
  double? strokeWidth;
  String? shapeType;
  LayerProperty properties;
  List<EffectLayer> effects;
  BlendMode2 blendMode;

  ProjectLayer({
    required this.id,
    required this.name,
    required this.type,
    this.visible = true,
    this.locked = false,
    this.solo = false,
    this.startTime = 0,
    this.endTime = 5,
    this.duration = 5,
    this.mediaPath,
    this.text,
    this.color,
    this.fontFamily = 'Inter',
    this.fontSize = 24,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth = 0,
    this.shapeType = 'rectangle',
    LayerProperty? properties,
    List<EffectLayer>? effects,
    this.blendMode = BlendMode2.normal,
  })  : properties = properties ?? LayerProperty(),
        effects = effects ?? [];
}

class Project {
  final String id;
  String name;
  int width;
  int height;
  double frameRate;
  double duration;
  List<ProjectLayer> layers;
  DateTime createdAt;
  DateTime updatedAt;
  String? thumbnailPath;
  Color backgroundColor;

  Project({
    required this.id,
    required this.name,
    this.width = 1080,
    this.height = 1920,
    this.frameRate = 30,
    this.duration = 10,
    List<ProjectLayer>? layers,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.thumbnailPath,
    Color? backgroundColor,
  })  : layers = layers ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        backgroundColor = backgroundColor ?? const Color(0xFF000000);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'width': width,
    'height': height,
    'frameRate': frameRate,
    'duration': duration,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'backgroundColor': backgroundColor.value,
  };
}
