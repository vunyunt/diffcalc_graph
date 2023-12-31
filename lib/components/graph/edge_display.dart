import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/graph/ui_state_manager.dart';
import 'package:flutter/material.dart';

class BezierEdgeRenderBox extends RenderBox {
  Offset from;
  Offset to;
  Paint brush;

  BezierEdgeRenderBox(
      {required this.from, required this.to, required this.brush});

  @override
  void performLayout() {
    size = Size((to.dx - from.dx).abs(), (to.dy - from.dy).abs());
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final from = this.from + offset;
    final to = this.to + offset;
    final xDistance = to.dx - from.dx;
    final bezierDistance = xDistance.abs() / 2;

    Path path = Path();
    path.moveTo(from.dx, from.dy);
    path.cubicTo(from.dx + bezierDistance, from.dy, to.dx - bezierDistance,
        to.dy, to.dx, to.dy);
    context.canvas.drawPath(path, brush);
  }
}

final class BezierEdgeDisplay extends LeafRenderObjectWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Paint paint;

  const BezierEdgeDisplay(
      {super.key,
      required this.startPosition,
      required this.endPosition,
      required this.paint});

  @override
  void updateRenderObject(
      BuildContext context, covariant BezierEdgeRenderBox renderObject) {
    renderObject.from = startPosition;
    renderObject.to = endPosition;
    renderObject.brush = paint;
    renderObject.markNeedsPaint();
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return BezierEdgeRenderBox(
        from: startPosition, to: endPosition, brush: paint);
  }
}

final class EdgeDisplay extends StatefulWidget {
  final UiStateManager stateManager;
  final Edge edge;
  final GlobalObjectKey containerKey;
  final GlobalObjectKey fromPortKey;
  final GlobalObjectKey toPortKey;
  final Paint paint;

  const EdgeDisplay(
      {super.key,
      required this.stateManager,
      required this.edge,
      required this.containerKey,
      required this.fromPortKey,
      required this.toPortKey,
      required this.paint});

  @override
  State<EdgeDisplay> createState() {
    return EdgeDisplayState();
  }
}

class EdgeDisplayState extends State<EdgeDisplay> {
  Offset fromPosition = Offset.zero;
  Offset toPosition = Offset.zero;
  late final RenderBox containerRenderBox;
  late final EdgeState edgeState;

  void updatePosition() {
    final fromBox =
        widget.fromPortKey.currentContext!.findRenderObject() as RenderBox;
    final toBox =
        widget.toPortKey.currentContext!.findRenderObject() as RenderBox;
    final fromLocalPosition = fromBox
        .localToGlobal(Offset(fromBox.size.width, fromBox.size.height / 2));
    final toLocalPosition =
        toBox.localToGlobal(Offset(0, toBox.size.height / 2));
    fromPosition = containerRenderBox.globalToLocal(fromLocalPosition);
    toPosition = containerRenderBox.globalToLocal(toLocalPosition);
  }

  void redraw() {
    setState(() {
      updatePosition();
    });
  }

  @override
  void initState() {
    super.initState();
    containerRenderBox =
        widget.containerKey.currentContext!.findRenderObject() as RenderBox;
    updatePosition();
    edgeState = EdgeState(edge: widget.edge, displayState: this);
    widget.stateManager.registerEdgeState(edgeState: edgeState);
  }

  @override
  void dispose() {
    widget.stateManager.unregisterEdgeState(edgeState: edgeState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BezierEdgeDisplay(
        startPosition: fromPosition,
        endPosition: toPosition,
        paint: widget.paint);
  }
}
