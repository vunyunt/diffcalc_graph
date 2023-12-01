import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/edge_display.dart';
import 'package:diffcalc_graph/components/node_display.dart';
import 'package:diffcalc_graph/components/ui_state_manager.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

/// Diffcalc graph display. [graph] should already be initialized before being
/// passed to this widget.
class GraphDisplay extends StatefulWidget {
  final UiGraph graph;

  const GraphDisplay({Key? key, required this.graph}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GraphDisplayState();
  }
}

class _GraphDisplayState extends State<GraphDisplay> {
  RenderBox? draggingPortRenderBox;
  late GlobalObjectKey containerKey;
  Offset cursorPosition = Offset.zero;
  UiStateManager stateManager = UiStateManager();
  Port? currentDraggingPort;

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
    super.initState();

    containerKey = GlobalObjectKey(widget.graph);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createEdgeDisplays(widget.graph);
    });

    widget.graph.onEdgeConnected.listen((edge) {
      setState(() {
        edgeWidgets[edge] = createEdgeDisplay(widget.graph, edge);
      });
    });

    widget.graph.onEdgeDisconnected.listen((edge) {
      setState(() {
        edgeWidgets.remove(edge);
      });
    });
  }

  Widget buildDraggingEdge(BuildContext context) {
    RenderBox containerRenderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;

    final fromLocalPosition = draggingPortRenderBox!.localToGlobal(Offset(
        draggingPortRenderBox!.size.width,
        draggingPortRenderBox!.size.height / 2));

    return BezierEdgeDisplay(
      startPosition: containerRenderBox.globalToLocal(fromLocalPosition),
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
        onPortDragStarted: (indicatorKey, port) {
          setState(() {
            currentDraggingPort = port;
            draggingPortRenderBox =
                indicatorKey.currentContext!.findRenderObject() as RenderBox;
          });
        },
        onPortDragUpdate: (e) {
          final containerRenderBox =
              containerKey.currentContext!.findRenderObject() as RenderBox;

          setState(() {
            cursorPosition = containerRenderBox.globalToLocal(e.globalPosition);
          });
        },
        onPortDragEnd: (indicatorKey, port) {
          setState(() {
            currentDraggingPort = null;
            draggingPortRenderBox = null;
          });
        },
        onPortDragAccepted: (edge) {
          setState(() {
            edgeWidgets[edge] = createEdgeDisplay(graph, edge);
          });
        },
      );
    });
  }

  Widget createEdgeDisplay(UiGraph graph, Edge edge) {
    final fromIndicator = stateManager.getPortIndicatorKey(
        edge.from.node as UiNodeMixin, edge.from);
    final toIndicator =
        stateManager.getPortIndicatorKey(edge.to.node as UiNodeMixin, edge.to);

    return EdgeDisplay(
        key: ObjectKey(edge),
        stateManager: stateManager,
        edge: edge,
        containerKey: containerKey,
        fromPortKey: fromIndicator,
        toPortKey: toIndicator,
        paint: edgePaint);
  }

  void createEdgeDisplays(UiGraph graph) {
    final nodes = widget.graph.nodes.values;

    for (final toNode in nodes) {
      for (final inPort in toNode.inPorts.values) {
        if (inPort.connected) {
          setState(() {
            edgeWidgets[inPort.edge!] = createEdgeDisplay(graph, inPort.edge!);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    widgets.addAll(createNodeDisplays(widget.graph));

    if (draggingPortRenderBox != null) {
      widgets.add(buildDraggingEdge(context));
    }

    return InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(480),
        minScale: 0.1,
        maxScale: 2.0,
        child: Stack(
            key: containerKey, children: [...widgets, ...edgeWidgets.values]));
  }
}
