import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[800],
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // MacBook-like screen
              Container(
                width: 600,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dock(
                      items: const [
                        Icons.person,
                        Icons.message,
                        Icons.call,
                        Icons.camera,
                        Icons.photo,
                      ],
                      builder: (icon, scale) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 48),
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(child: Icon(icon, color: Colors.white)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock with draggable and animated items.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item and its scale.
  final Widget Function(T item, double scale) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  int? _hoveredIndex;
  T? _draggingItem;
  double _draggingX = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: List.generate(
          _items.length,
          (index) {
            final item = _items[index];
            final isDragging = _draggingItem == item;
            final scale = _calculateScale(index);

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDragging ? _draggingX : index * 64.0,
              top: isDragging ? -20 : 0,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _draggingItem = item;
                    _draggingX = index * 64.0;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _draggingX += details.delta.dx;
                    _reorderIfNeeded(index);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _draggingItem = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()..scale(scale),
                  child: widget.builder(item, scale),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Calculate the scale for an item based on its proximity to the hovered index.
  double _calculateScale(int index) {
    if (_draggingItem == null) return 1.0;
    final draggingIndex = _items.indexOf(_draggingItem!);
    final distance = (draggingIndex - index).abs();
    if (distance == 0) return 1.5; // Scale up the dragged item.
    if (distance == 1) return 1.2; // Slightly scale neighboring items.
    return 1.0;
  }

  /// Reorder the items if the dragging position overlaps another item.
  void _reorderIfNeeded(int draggedIndex) {
    final newIndex = (_draggingX / 64.0).round().clamp(0, _items.length - 1);
    if (newIndex != draggedIndex) {
      setState(() {
        final draggedItem = _items.removeAt(draggedIndex);
        _items.insert(newIndex, draggedItem);
      });
    }
  }
}
