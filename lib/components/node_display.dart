import 'dart:math';

import 'package:boxy/boxy.dart';
import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/port_display.dart';
import 'package:diffcalc_graph/components/ui_state_manager.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

final class NodeDisplay extends StatefulWidget {
  final UiStateManager stateManager;
  final UiGraph graph;
  final UiNodeMixin node;
  final Function(GlobalObjectKey, Port) onPortDragStarted;
  final Function(DragUpdateDetails) onPortDragUpdate;
  final Function(GlobalObjectKey, Port) onPortDragEnd;
  final Function(Edge edge) onPortDragAccepted;

  const NodeDisplay(
      {super.key,
      required this.stateManager,
      required this.graph,
      required this.node,
      required this.onPortDragStarted,
      required this.onPortDragUpdate,
      required this.onPortDragEnd,
      required this.onPortDragAccepted});

  @override
  State<StatefulWidget> createState() {
    return _NodeDisplayState();
  }
}

enum _NodeDisplayChildren { title, ports, nodeUi }

class _NodeDisplayLayoutDelegate extends BoxyDelegate {
  double minWidth;

  _NodeDisplayLayoutDelegate({required this.minWidth});

  @override
  Size layout() {
    final title = getChild(_NodeDisplayChildren.title);
    final ports = getChild(_NodeDisplayChildren.ports);

    var titleSize =
        title.render.getDryLayout(BoxConstraints.loose(Size.infinite));
    var portsSize =
        ports.render.getDryLayout(BoxConstraints.loose(Size.infinite));

    final width = max(max(titleSize.width, portsSize.width), minWidth);
    final constraints = BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0,
      maxHeight: double.infinity,
    );

    title.layout(constraints);
    ports.layout(constraints);
    ports.position(title.rect.bottomLeft + const Offset(0, 16));

    var bottom = ports.rect.bottom;

    if (hasChild(_NodeDisplayChildren.nodeUi)) {
      final nodeUi = getChild(_NodeDisplayChildren.nodeUi);
      nodeUi.layout(BoxConstraints.loose(Size(width, double.infinity)));
      nodeUi.position(ports.rect.bottomLeft + const Offset(0, 16));

      bottom = nodeUi.rect.bottom;
    }

    return Size(width, bottom);
  }
}

class _NodeDisplayState extends State<NodeDisplay> {
  @override
  void initState() {
    super.initState();

    // Register the node ui state on the state manager
    widget.stateManager
        .registerNodeState(nodeState: NodeState(node: widget.node));
  }

  Widget buildBody(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: const BorderRadiusDirectional.only(
            bottomStart: Radius.circular(8), bottomEnd: Radius.circular(8)),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.node.inPorts.values
                  .cast<InPort<dynamic, UiNodeMixin>>()
                  .map((e) => InPortDisplay(
                        key: Key(e.name),
                        inPort: e,
                        onDragStarted: (indicatorKey, inPort) {
                          widget.onPortDragStarted(indicatorKey, inPort);
                        },
                        onDragUpdate: widget.onPortDragUpdate,
                        onDragEnd: (indicatorKey, inPort) {
                          widget.onPortDragEnd(indicatorKey, inPort);
                        },
                        onKeyReady: (indicatorKey, inPort) {
                          widget.stateManager.registerPortIndicatorKey(
                              widget.node, inPort, indicatorKey);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.node.outPorts.values
                  .cast<OutPort<dynamic, UiNodeMixin>>()
                  .map((e) => OutPortDisplay(
                        key: Key(e.name),
                        outPort: e,
                        onDragStarted: (indicatorKey, outPort) {
                          widget.onPortDragStarted(indicatorKey, outPort);
                        },
                        onDragUpdate: widget.onPortDragUpdate,
                        onDragEnd: (indicatorKey, outPort) {
                          widget.onPortDragEnd(indicatorKey, outPort);
                        },
                        onKeyReady: (indicatorKey, outPort) {
                          widget.stateManager.registerPortIndicatorKey(
                              widget.node, outPort, indicatorKey);
                        },
                      ))
                  .toList(),
            )
          ]),
    );
  }

  Widget buildTitle(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onPanUpdate: (e) {
        for (final renderBox in widget.node.uiState.updateOnDrag) {
          renderBox.markNeedsPaint();
        }

        setState(() {
          widget.node.x = max(0, widget.node.x + e.delta.dx);
          widget.node.y = max(0, widget.node.y + e.delta.dy);
        });

        widget.stateManager.getNodeState(widget.node).redrawConnectedEdges();
      },
      onPanEnd: (e) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          widget.stateManager.getNodeState(widget.node).redrawConnectedEdges();
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(8), topEnd: Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(widget.node.id,
              style: TextStyle(color: colorScheme.onPrimaryContainer))),
    );
  }

  Widget buildContent(BuildContext context, ColorScheme colorScheme) {
    // According to flutter's doc, IntrinsicWidth is relatively expensive and
    // should be avoided if possible. If layout performance ever becomes an
    // issue, this is probably worth looking into.
    final content = [
      BoxyId(
          id: _NodeDisplayChildren.title,
          child: buildTitle(context, colorScheme)),
      BoxyId(
          id: _NodeDisplayChildren.ports,
          child: buildBody(context, colorScheme))
    ];

    final nodeUi = widget.node.buildUiWidget(context);
    if (nodeUi != null) {
      content.add(BoxyId(id: _NodeDisplayChildren.nodeUi, child: nodeUi));
    }

    return CustomBoxy(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        delegate: _NodeDisplayLayoutDelegate(minWidth: widget.node.minWidth),
        children: content);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;

    // Register the [setState] function for [UiNodeMixin]. [setState] called from
    // [UiNodeMixin]'s subclasses will be forwarded to this widget's [setState]
    widget.node.uiState.onSetState = setState;

    return Container(
      margin: EdgeInsets.only(left: widget.node.x, top: widget.node.y),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.secondaryContainer,
          boxShadow: [
            BoxShadow(
                color: colorScheme.shadow, blurRadius: 8, spreadRadius: -4)
          ]),
      child: buildContent(context, colorScheme),
    );
  }
}
