import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/edge_display.dart';
import 'package:diffcalc_graph/components/node_display.dart';
import 'package:diffcalc_graph/components/ui_state_manager.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:diffcalc_graph/data/ui_graph.dart';
import 'package:flutter/material.dart';

class GraphDisplay extends StatefulWidget {
  final UiGraph graph;

  const GraphDisplay({Key? key, required this.graph}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GraphDisplayState();
  }
}

class _GraphDisplayState extends State<GraphDisplay> {
  RenderBox? currentDraggingRenderBox;
  late GlobalObjectKey containerKey;
  Offset cursorPosition = Offset.zero;
  UiStateManager stateManager = UiStateManager();

  Map<Edge, Widget> edgeWidgets = {};

  final draggingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.red
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

  final edgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.lightBlue
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    containerKey = GlobalObjectKey(widget.graph);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createEdgeDisplays(widget.graph);
    });
  }

  Widget buildDraggingEdge(BuildContext context) {
    RenderBox containerRenderBox = context.findRenderObject() as RenderBox;

    return DraggingEdgeDisplay(
      startPosition: containerRenderBox.globalToLocal(currentDraggingRenderBox!
          .localToGlobal(Offset(currentDraggingRenderBox!.size.width,
              currentDraggingRenderBox!.size.height / 2))),
      endPosition: cursorPosition,
      paint: draggingPaint,
    );
  }

  Iterable<NodeDisplay> createNodeDisplays(UiGraph graph) {
    return graph.nodes.values.map((node) {
      return NodeDisplay(
        stateManager: stateManager,
        graph: widget.graph,
        node: node,
        onInPortTapDown: (indicatorKey) {
          setState(() {
            currentDraggingRenderBox =
                indicatorKey.currentContext!.findRenderObject() as RenderBox;
          });
        },
        onOutPortTapDown: (indicatorKey) {
          setState(() {
            currentDraggingRenderBox =
                indicatorKey.currentContext!.findRenderObject() as RenderBox;
          });
        },
      );
    });
  }

  void createEdgeDisplays(UiGraph graph) {
    final nodes = widget.graph.nodes.values;

    for (final node in nodes) {
      for (final inPort in node.inPorts.values) {
        if (inPort.connected) {
          OutPort<dynamic, UiNodeMixin> outPort =
              inPort.edge!.from as OutPort<dynamic, UiNodeMixin>;
          final fromIndicatorFuture =
              stateManager.getPortIndicatorKey(node, outPort);
          final toIndicatorFuture =
              stateManager.getPortIndicatorKey(node, inPort);

          Future.wait([fromIndicatorFuture, toIndicatorFuture]).then((value) {
            final fromIndicatorKey = value[0];
            final toIndicatorKey = value[1];

            setState(() {
              edgeWidgets[inPort.edge!] = EdgeDisplay(
                  fromPortKey: fromIndicatorKey,
                  toPortKey: toIndicatorKey,
                  paint: edgePaint);
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    widgets.addAll(createNodeDisplays(widget.graph));

    if (currentDraggingRenderBox != null) {
      widgets.add(buildDraggingEdge(context));
    }

    return GestureDetector(
        onPanUpdate: (e) {
          setState(() {
            cursorPosition = e.localPosition;
          });
        },
        onPanEnd: (e) => setState(() {
              currentDraggingRenderBox = null;
            }),
        child: Stack(
            key: containerKey, children: [...widgets, ...edgeWidgets.values]));
  }
}
