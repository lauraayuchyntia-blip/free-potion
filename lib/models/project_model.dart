import 'package:flutter/material.dart';

enum LayerType { video, image, text, shape, audio, effect, svg }

enum ShapeType { rectangle, circle, triangle, star, polygon }

enum BlendMode2 { normal, multiply, screen, overlay, darken, lighten, colorDodge, colorBurn, hardLight, softLight, difference, exclusion }

enum EasingType { linear, easeIn, easeOut, easeInOut, spring, bounce }

class Keyframe {
  double time;
  dynamic value;
  EasingType easing;
  String property;

  Keyframe({
    required this.time,
    required this.value,
    this.easing = EasingType.linear,
    this.property = 'position',
  });
}

class LayerProperties {
  double x;
  double y;
  double scaleX;
  double scaleY;
  double rotation;
  double opacity;
  double anchorX;
  double anchorY;

  List<Keyframe> xKeyframes;
  List<Keyframe> yKeyframes;
  List<Keyframe> opacityKeyframes;
  List<Keyframe> scaleKeyframes;
  List<Keyframe> rotationKeyframes;

  LayerProperties({
    this.x = 0,
    this.y = 0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.rotation = 0,
    this.opacity = 1.0,
    this.anchorX = 0,
    this.anchorY = 0,
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
  String name;
  String type; // blur, glow, shadow, colorCorrection, etc.
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
  double startTime;
  double endTime;
  double duration;
  bool visible;
  bool locked;
  String? filePath;
  String? text;
  Color? color;
  String? fontFamily;
  double? fontSize;
  String? shapeType;
  double? strokeWidth;
  Color? strokeColor;
  bool? isFilled;
  BlendMode2 blendMode;
  LayerProperties properties;
  List<EffectLayer> effects;
  List<Keyframe> keyframes;
  double? volume; // for audio/video
  bool? loop;    // for audio/video
  String? svgContent;
  double? width;
  double? height;

  ProjectLayer({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.visible = true,
    this.locked = false,
    this.filePath,
    this.text,
    this.color,
    this.fontFamily,
    this.fontSize,
    this.shapeType,
    this.strokeWidth,
    this.strokeColor,
    this.isFilled = true,
    this.blendMode = BlendMode2.normal,
    this.volume = 1.0,
    this.loop = false,
    this.svgContent,
    this.width,
    this.height,
    LayerProperties? properties,
    List<EffectLayer>? effects,
    List<Keyframe>? keyframes,
  })  : properties = properties ?? LayerProperties(),
        effects = effects ?? [],
        keyframes = keyframes ?? [];
}

class Project {
  final String id;
  String name;
  int width;
  int height;
  double duration;
  double fps;
  Color backgroundColor;
  List<ProjectLayer> layers;
  DateTime createdAt;
  DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.width = 1080,
    this.height = 1920,
    this.duration = 10.0,
    this.fps = 30.0,
    this.backgroundColor = Colors.black,
    List<ProjectLayer>? layers,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : layers = layers ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
