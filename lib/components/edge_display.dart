import 'package:flutter/material.dart';

class BezierEdgeRenderBox extends RenderBox {
  Offset from;
  Offset to;
  Paint brush;

  BezierEdgeRenderBox(
      {required this.from, required this.to, required this.brush});

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Offset from = this.from + offset;
    Offset to = this.to + offset;

    Path path = Path();
    path.moveTo(from.dx, from.dy);
    path.cubicTo(from.dx + 200, from.dy, to.dx - 200, to.dy, to.dx, to.dy);
    context.canvas.drawPath(path, brush);
  }
}

final class DraggingEdgeDisplay extends LeafRenderObjectWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Paint paint;

  const DraggingEdgeDisplay(
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

final class EdgeDisplay extends LeafRenderObjectWidget {
  final GlobalObjectKey fromPortKey;
  final GlobalObjectKey toPortKey;
  final Paint paint;

  const EdgeDisplay(
      {super.key,
      required this.fromPortKey,
      required this.toPortKey,
      required this.paint});

  @override
  void updateRenderObject(
      BuildContext context, covariant BezierEdgeRenderBox renderObject) {
    final fromBox = fromPortKey.currentContext!.findRenderObject() as RenderBox;
    final toBox = toPortKey.currentContext!.findRenderObject() as RenderBox;

    renderObject.from = fromBox
        .localToGlobal(Offset(fromBox.size.width, fromBox.size.height / 2));
    renderObject.to = toBox.localToGlobal(Offset(0, toBox.size.height / 2));
    renderObject.brush = paint;
    renderObject.markNeedsPaint();
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    final fromBox = fromPortKey.currentContext!.findRenderObject() as RenderBox;
    final toBox = toPortKey.currentContext!.findRenderObject() as RenderBox;

    return BezierEdgeRenderBox(
        from: fromBox
            .localToGlobal(Offset(fromBox.size.width, fromBox.size.height / 2)),
        to: toBox.localToGlobal(Offset(0, toBox.size.height / 2)),
        brush: paint);
  }
}
