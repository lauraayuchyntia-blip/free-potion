import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';

class EditorProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // Projects
  List<Project> _projects = [];
  Project? _currentProject;

  // Editor state
  String? _selectedLayerId;
  double _currentTime = 0;
  bool _isPlaying = false;
  bool _showKeyframes = false;
  bool _showGrid = false;
  double _zoom = 1.0;
  double _timelineZoom = 1.0;
  String _activeTool = 'select';
  int selectedEffectIndex = -1;
  int _bottomTab = 0; // 0=layers, 1=effects, 2=keyframes

  // Undo/Redo stacks
  final List<List<ProjectLayer>> _undoStack = [];
  final List<List<ProjectLayer>> _redoStack = [];

  // Getters
  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  String? get selectedLayerId => _selectedLayerId;
  double get currentTime => _currentTime;
  bool get isPlaying => _isPlaying;
  bool get showKeyframes => _showKeyframes;
  bool get showGrid => _showGrid;
  double get zoom => _zoom;
  double get timelineZoom => _timelineZoom;
  String get activeTool => _activeTool;
  int get bottomTab => _bottomTab;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  ProjectLayer? get selectedLayer {
    if (_selectedLayerId == null || _currentProject == null) return null;
    try {
      return _currentProject!.layers.firstWhere((l) => l.id == _selectedLayerId);
    } catch (_) {
      return null;
    }
  }

  // ─── Project Management ───────────────────────────────────────────

  void createNewProject({
    String name = 'My Project',
    int width = 1080,
    int height = 1920,
    double duration = 10.0,
    double fps = 30.0,
  }) {
    final project = Project(
      id: _uuid.v4(),
      name: name,
      width: width,
      height: height,
      duration: duration,
      fps: fps,
    );
    _projects.insert(0, project);
    _currentProject = project;
    _selectedLayerId = null;
    _currentTime = 0;
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  void openProject(Project project) {
    _currentProject = project;
    _selectedLayerId = null;
    _currentTime = 0;
    _isPlaying = false;
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    if (_currentProject?.id == id) _currentProject = null;
    notifyListeners();
  }

  void renameProject(String id, String newName) {
    final proj = _projects.firstWhere((p) => p.id == id, orElse: () => _currentProject!);
    proj.name = newName;
    notifyListeners();
  }

  void duplicateProject(String id) {
    final orig = _projects.firstWhere((p) => p.id == id);
    final copy = Project(
      id: _uuid.v4(),
      name: '${orig.name} Copy',
      width: orig.width,
      height: orig.height,
      duration: orig.duration,
      fps: orig.fps,
      backgroundColor: orig.backgroundColor,
    );
    _projects.insert(0, copy);
    notifyListeners();
  }

  // ─── Layer Management ─────────────────────────────────────────────

  void _saveUndoState() {
    if (_currentProject == null) return;
    _undoStack.add(List.from(_currentProject!.layers));
    if (_undoStack.length > 50) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty || _currentProject == null) return;
    _redoStack.add(List.from(_currentProject!.layers));
    _currentProject!.layers = _undoStack.removeLast();
    _selectedLayerId = null;
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty || _currentProject == null) return;
    _undoStack.add(List.from(_currentProject!.layers));
    _currentProject!.layers = _redoStack.removeLast();
    notifyListeners();
  }

  void addLayer({
    required LayerType type,
    String? name,
    String? filePath,
    String? text,
    String? shapeType,
    String? svgContent,
  }) {
    if (_currentProject == null) return;
    _saveUndoState();
    final layer = ProjectLayer(
      id: _uuid.v4(),
      name: name ?? _defaultLayerName(type),
      type: type,
      startTime: _currentTime,
      endTime: _currentTime + 5,
      duration: 5,
      filePath: filePath,
      text: text ?? (type == LayerType.text ? 'Free Potion Text' : null),
      color: type == LayerType.shape
          ? const Color(0xFF8B5CF6)
          : (type == LayerType.text ? Colors.white : null),
      fontSize: type == LayerType.text ? 48.0 : null,
      fontFamily: type == LayerType.text ? 'Inter' : null,
      shapeType: shapeType ?? (type == LayerType.shape ? 'rectangle' : null),
      svgContent: svgContent,
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
    _saveUndoState();
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

  void duplicateLayer(String id) {
    final layer = _getLayer(id);
    if (layer == null || _currentProject == null) return;
    _saveUndoState();
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
      filePath: layer.filePath,
      shapeType: layer.shapeType,
    );
    final idx = _currentProject!.layers.indexWhere((l) => l.id == id);
    _currentProject!.layers.insert(idx, newLayer);
    _selectedLayerId = newLayer.id;
    notifyListeners();
  }

  // ─── Layer Properties ─────────────────────────────────────────────

  void updateLayerText(String id, String text) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.text = text;
      notifyListeners();
    }
  }

  void updateLayerColor(String id, Color color) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.color = color;
      notifyListeners();
    }
  }

  void updateLayerOpacity(String id, double opacity) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.properties.opacity = opacity.clamp(0.0, 1.0);
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

  void updateLayerFontSize(String id, double size) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.fontSize = size;
      notifyListeners();
    }
  }

  void updateLayerFontFamily(String id, String font) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.fontFamily = font;
      notifyListeners();
    }
  }

  void updateLayerShapeType(String id, String shape) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.shapeType = shape;
      notifyListeners();
    }
  }

  void updateLayerTiming(String id, double start, double end) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.startTime = start.clamp(0, _currentProject?.duration ?? 10);
      layer.endTime = end.clamp(0, _currentProject?.duration ?? 10);
      layer.duration = layer.endTime - layer.startTime;
      notifyListeners();
    }
  }

  void updateLayerVolume(String id, double volume) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.volume = volume.clamp(0.0, 1.0);
      notifyListeners();
    }
  }

  void updateLayerFilePath(String id, String path) {
    final layer = _getLayer(id);
    if (layer != null) {
      layer.filePath = path;
      notifyListeners();
    }
  }

  // ─── Effects ──────────────────────────────────────────────────────

  void addEffect(String layerId, EffectLayer effect) {
    final layer = _getLayer(layerId);
    if (layer != null) {
      layer.effects.add(effect);
      notifyListeners();
    }
  }

  void removeEffect(String layerId, String effectId) {
    final layer = _getLayer(layerId);
    if (layer != null) {
      layer.effects.removeWhere((e) => e.id == effectId);
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

  void updateEffectParam(String layerId, String effectId, String param, dynamic value) {
    final layer = _getLayer(layerId);
    if (layer != null) {
      final effect = layer.effects.firstWhere((e) => e.id == effectId);
      effect.params[param] = value;
      notifyListeners();
    }
  }

  // ─── Keyframes ────────────────────────────────────────────────────

  void addKeyframe(String layerId, String property, double time, dynamic value) {
    final layer = _getLayer(layerId);
    if (layer == null) return;
    final kf = Keyframe(time: time, value: value, property: property);
    // Add to flat list for panel display
    layer.keyframes.add(kf);
    // Also track per-property
    switch (property) {
      case 'x': layer.properties.xKeyframes.add(kf); break;
      case 'y': layer.properties.yKeyframes.add(kf); break;
      case 'opacity': layer.properties.opacityKeyframes.add(kf); break;
      case 'scale': layer.properties.scaleKeyframes.add(kf); break;
      case 'rotation': layer.properties.rotationKeyframes.add(kf); break;
      default: break;
    }
    notifyListeners();
  }

  // ─── Playback ─────────────────────────────────────────────────────

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
    _zoom = zoom.clamp(0.1, 10.0);
    notifyListeners();
  }

  void setTimelineZoom(double zoom) {
    _timelineZoom = zoom.clamp(0.5, 5.0);
    notifyListeners();
  }

  void setBottomTab(int tab) {
    _bottomTab = tab;
    notifyListeners();
  }

  void toggleShowKeyframes() {
    _showKeyframes = !_showKeyframes;
    notifyListeners();
  }

  void updateProjectBackground(Color color) {
    if (_currentProject != null) {
      _currentProject!.backgroundColor = color;
      notifyListeners();
    }
  }

  void updateProjectDuration(double duration) {
    if (_currentProject != null) {
      _currentProject!.duration = duration;
      notifyListeners();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  ProjectLayer? _getLayer(String id) {
    try {
      return _currentProject?.layers.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  String _defaultLayerName(LayerType type) {
    switch (type) {
      case LayerType.video: return 'Video';
      case LayerType.image: return 'Image';
      case LayerType.text: return 'Text';
      case LayerType.shape: return 'Shape';
      case LayerType.audio: return 'Audio';
      case LayerType.effect: return 'Effect';
      case LayerType.svg: return 'SVG';
    }
  }

  EffectLayer createEffect(String name, String type) {
    return EffectLayer(
      id: _uuid.v4(),
      name: name,
      type: type,
      params: _defaultEffectParams(type),
    );
  }

  Map<String, dynamic> _defaultEffectParams(String type) {
    switch (type) {
      case 'blur': return {'radius': 10.0};
      case 'glow': return {'radius': 15.0, 'intensity': 0.8};
      case 'shadow': return {'offsetX': 4.0, 'offsetY': 4.0, 'blur': 8.0, 'color': 0xFF000000};
      case 'brightness': return {'value': 0.0};
      case 'contrast': return {'value': 0.0};
      case 'saturation': return {'value': 0.0};
      case 'hue': return {'value': 0.0};
      case 'vignette': return {'intensity': 0.5};
      case 'grain': return {'intensity': 0.3};
      case 'chromatic': return {'offset': 5.0};
      default: return {};
    }
  }
}
