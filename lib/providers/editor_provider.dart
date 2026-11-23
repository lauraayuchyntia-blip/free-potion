import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';

class EditorProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  Project? _currentProject;
  String? _selectedLayerId;
  double _currentTime = 0;
  bool _isPlaying = false;
  bool _showKeyframes = false;
  double _zoom = 1.0;
  double _timelineZoom = 1.0;
  String _activeTool = 'select'; // select, text, shape, pen
  int _selectedEffectIndex = -1;

  Project? get currentProject => _currentProject;
  String? get selectedLayerId => _selectedLayerId;
  double get currentTime => _currentTime;
  bool get isPlaying => _isPlaying;
  bool get showKeyframes => _showKeyframes;
  double get zoom => _zoom;
  double get timelineZoom => _timelineZoom;
  String get activeTool => _activeTool;

  ProjectLayer? get selectedLayer {
    if (_selectedLayerId == null || _currentProject == null) return null;
    try {
      return _currentProject!.layers.firstWhere((l) => l.id == _selectedLayerId);
    } catch (_) {
      return null;
    }
  }

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  void createNewProject({String name = 'New Project', int width = 1080, int height = 1920}) {
    final project = Project(
      id: _uuid.v4(),
      name: name,
      width: width,
      height: height,
    );
    _projects.add(project);
    _currentProject = project;
    _selectedLayerId = null;
    _currentTime = 0;
    notifyListeners();
  }

  void openProject(Project project) {
    _currentProject = project;
    _selectedLayerId = null;
    _currentTime = 0;
    _isPlaying = false;
    notifyListeners();
  }

  void addLayer(LayerType type, {String? name}) {
    if (_currentProject == null) return;
    final layer = ProjectLayer(
      id: _uuid.v4(),
      name: name ?? _defaultLayerName(type),
      type: type,
      startTime: _currentTime,
      endTime: _currentTime + 5,
      duration: 5,
      text: type == LayerType.text ? 'Free Potion Text' : null,
      color: type == LayerType.shape ? const Color(0xFF8B5CF6) : null,
    );
    _currentProject!.layers.insert(0, layer);
    _selectedLayerId = layer.id;
    notifyListeners();
  }

  void selectLayer(String? id) {
    _selectedLayerId = id;
    notifyListeners();
  }

  void deleteLayer(String id) {
    _currentProject?.layers.removeWhere((l) => l.id == id);
    if (_selectedLayerId == id) _selectedLayerId = null;
    notifyListeners();
  }

  void toggleLayerVisibility(String id) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.visible = !layer.visible;
      notifyListeners();
    }
  }

  void toggleLayerLock(String id) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.locked = !layer.locked;
      notifyListeners();
    }
  }

  void reorderLayers(int oldIndex, int newIndex) {
    if (_currentProject == null) return;
    final layers = _currentProject!.layers;
    if (newIndex > oldIndex) newIndex--;
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);
    notifyListeners();
  }

  void setCurrentTime(double time) {
    _currentTime = time.clamp(0, _currentProject?.duration ?? 10);
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setActiveTool(String tool) {
    _activeTool = tool;
    notifyListeners();
  }

  void setZoom(double zoom) {
    _zoom = zoom.clamp(0.1, 5.0);
    notifyListeners();
  }

  void setTimelineZoom(double zoom) {
    _timelineZoom = zoom.clamp(0.5, 5.0);
    notifyListeners();
  }

  void updateLayerText(String id, String text) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.text = text;
      notifyListeners();
    }
  }

  void updateLayerOpacity(String id, double opacity) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.properties.opacity = opacity;
      notifyListeners();
    }
  }

  void updateLayerPosition(String id, double x, double y) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.properties.x = x;
      layer.properties.y = y;
      notifyListeners();
    }
  }

  void updateLayerScale(String id, double scaleX, double scaleY) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.properties.scaleX = scaleX;
      layer.properties.scaleY = scaleY;
      notifyListeners();
    }
  }

  void updateLayerRotation(String id, double rotation) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.properties.rotation = rotation;
      notifyListeners();
    }
  }

  void addEffect(String layerId, EffectLayer effect) {
    final layer = _getLayer(layerId);
    if (layer != null) {
      layer.effects.add(effect);
      notifyListeners();
    }
  }

  void toggleEffect(String layerId, String effectId) {
    final layer = _getLayer(layerId);
    if (layer != null) {
      final effect = layer.effects.firstWhere((e) => e.id == effectId);
      effect.enabled = !effect.enabled;
      notifyListeners();
    }
  }

  void addKeyframe(String layerId, String property, double time, dynamic value) {
    final layer = _getLayer(layerId);
    if (layer == null) return;
    final kf = Keyframe(time: time, value: value);
    switch (property) {
      case 'x': layer.properties.xKeyframes.add(kf); break;
      case 'y': layer.properties.yKeyframes.add(kf); break;
      case 'opacity': layer.properties.opacityKeyframes.add(kf); break;
      case 'scale': layer.properties.scaleKeyframes.add(kf); break;
      case 'rotation': layer.properties.rotationKeyframes.add(kf); break;
    }
    notifyListeners();
  }

  void duplicateLayer(String id) {
    final layer = _getLayer(id);
    if (layer == null || _currentProject == null) return;
    final newLayer = ProjectLayer(
      id: _uuid.v4(),
      name: '${layer.name} Copy',
      type: layer.type,
      startTime: layer.startTime,
      endTime: layer.endTime,
      duration: layer.duration,
      text: layer.text,
      color: layer.color,
      fontFamily: layer.fontFamily,
      fontSize: layer.fontSize,
    );
    final idx = _currentProject!.layers.indexWhere((l) => l.id == id);
    _currentProject!.layers.insert(idx, newLayer);
    _selectedLayerId = newLayer.id;
    notifyListeners();
  }

  ProjectLayer? _getLayer(String id) {
    try {
      return _currentProject?.layers.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  String _defaultLayerName(LayerType type) {
    switch (type) {
      case LayerType.video: return 'Video Layer';
      case LayerType.image: return 'Image Layer';
      case LayerType.text: return 'Text Layer';
      case LayerType.shape: return 'Shape Layer';
      case LayerType.audio: return 'Audio Layer';
      case LayerType.effect: return 'Effect Layer';
    }
  }
}
