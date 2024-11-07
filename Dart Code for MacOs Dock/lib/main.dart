import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Main App Widget - Sets up the basic structure with a centered Dock layout
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Mac OS Dock',
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
            ],
            itemBuilder: (icon) => DockItem(icon: icon),
          ),
        ),
      ),
    );
  }
}

// Dock Item Widget - Style each icon item uniquely within the Dock
class DockItem extends StatelessWidget {
  const DockItem({Key? key, required this.icon}) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length].withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// Dock Class - Handles arrangement and interactivity for draggable icons
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.itemBuilder,
  });

  final List<T> items;
  final Widget Function(T) itemBuilder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _dockItems = List.from(widget.items);
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(6),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_dockItems.length, (index) => _buildDraggableItem(index)),
      ),
    );
  }

  // Create a draggable item with smooth animations and visual feedback
  Widget _buildDraggableItem(int index) {
    final item = _dockItems[index];
    final isBeingDragged = _draggingIndex == index;
    final isHoverTarget = _hoverIndex == index && _draggingIndex != null;

    return DragTarget<int>(
      onWillAccept: (draggedIndex) {
        setState(() {
          _hoverIndex = index;
        });
        return true;
      },
      onLeave: (_) => _clearHoverState(),
      onAccept: (draggedIndex) {
        setState(() {
          final movedItem = _dockItems.removeAt(draggedIndex);
          _dockItems.insert(index, movedItem);
          _resetDragState();
        });
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: isHoverTarget ? 4 : 50, // Resize for visual feedback
          child: Draggable<int>(
            data: index,
            onDragStarted: () => setState(() => _draggingIndex = index),
            onDraggableCanceled: (_, __) => _resetDragState(),
            onDragCompleted: _resetDragState,
            feedback: Opacity(
              opacity: 0.75,
              child: widget.itemBuilder(item),
            ),
            childWhenDragging: Container(), // Placeholder for space retention
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isBeingDragged ? 0.0 : 1.0, // Fade out while dragging
              child: widget.itemBuilder(item),
            ),
          ),
        );
      },
    );
  }

  // Reset state variables once dragging is finished
  void _resetDragState() {
    setState(() {
      _draggingIndex = null;
      _hoverIndex = null;
    });
  }

  // Clear hover state when an item is no longer a potential drop target
  void _clearHoverState() {
    setState(() {
      _hoverIndex = null;
    });
  }
}
