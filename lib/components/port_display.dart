import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:flutter/material.dart';

Widget buildName(BuildContext context, String name) {
  return Text(name);
}

class _PortIndicator extends StatefulWidget {
  final Port port;
  final void Function() onDragStarted;
  final void Function(DragUpdateDetails dragUpdateDetails) onDragUpdate;
  final void Function() onDragEnd;
  final void Function(Edge edge) onDragAccepted;

  const _PortIndicator(
      {super.key,
      required this.port,
      required this.onDragStarted,
      required this.onDragUpdate,
      required this.onDragEnd,
      required this.onDragAccepted});

  @override
  State<StatefulWidget> createState() {
    return _PortIndicatorState();
  }
}

class _PortIndicatorState extends State<_PortIndicator> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        onEnter: (e) => setState(() {
              hover = true;
            }),
        onExit: (e) => setState(() {
              hover = false;
            }),
        child: Draggable(
            data: widget.port,
            hitTestBehavior: HitTestBehavior.translucent,
            feedback: const SizedBox.shrink(),
            onDragStarted: () {
              widget.onDragStarted();
            },
            onDragUpdate: widget.onDragUpdate,
            onDragEnd: (e) => widget.onDragEnd(),
            child: DragTarget<Port<dynamic, Node>>(
              onWillAccept: (port) =>
                  (widget.port is InPort && port is OutPort) ||
                  (widget.port is OutPort && port is InPort),
              onAccept: (acceptingPort) {
                final currentPort = widget.port;
                if (currentPort is OutPort && acceptingPort is InPort) {
                  final edge = currentPort.connectTo(acceptingPort);
                  widget.onDragAccepted(edge);
                } else if (currentPort is InPort && acceptingPort is OutPort) {
                  final edge = acceptingPort.connectTo(currentPort);
                  widget.onDragAccepted(edge);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 8,
                  height: 6,
                  decoration: BoxDecoration(
                      color: hover
                          ? Theme.of(context).colorScheme.primary
                          : widget.port.connected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).disabledColor),
                );
              },
            )));
  }
}

abstract class PortDisplay extends StatefulWidget {
  final void Function(GlobalObjectKey, Port) onDragStarted;
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(GlobalObjectKey, Port) onDragEnd;
  final void Function(GlobalObjectKey, Port) onKeyReady;
  final void Function(Edge edge) onDragAccepted;

  Port<dynamic, UiNodeMixin> get port;

  const PortDisplay(
      {super.key,
      required this.onDragStarted,
      required this.onDragUpdate,
      required this.onDragEnd,
      required this.onDragAccepted,
      required this.onKeyReady});
}

abstract class _PortDisplayState<T extends PortDisplay> extends State<T> {
  late final GlobalObjectKey indicatorKey;

  @override
  void initState() {
    super.initState();
    indicatorKey = GlobalObjectKey(widget.port);
    widget.onKeyReady(indicatorKey, widget.port);
  }
}

final class InPortDisplay extends PortDisplay {
  final InPort<dynamic, UiNodeMixin> inPort;

  @override
  Port<dynamic, UiNodeMixin> get port => inPort;

  const InPortDisplay(
      {super.key,
      required this.inPort,
      required super.onDragStarted,
      required super.onDragUpdate,
      required super.onDragEnd,
      required super.onDragAccepted,
      required super.onKeyReady});

  @override
  State<StatefulWidget> createState() {
    return _InPortDisplayState();
  }
}

class _InPortDisplayState extends _PortDisplayState<InPortDisplay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PortIndicator(
              key: indicatorKey,
              port: widget.inPort,
              onDragStarted: () {
                widget.onDragStarted(indicatorKey, widget.inPort);
              },
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: () {
                widget.onDragEnd(indicatorKey, widget.inPort);
              },
              onDragAccepted: widget.onDragAccepted,
            ),
            const SizedBox(width: 8),
            buildName(context, widget.inPort.name)
          ],
        ));
  }
}

final class OutPortDisplay extends PortDisplay {
  final OutPort<dynamic, UiNodeMixin> outPort;

  @override
  Port<dynamic, UiNodeMixin> get port => outPort;

  const OutPortDisplay(
      {super.key,
      required this.outPort,
      required super.onDragStarted,
      required super.onDragUpdate,
      required super.onDragEnd,
      required super.onDragAccepted,
      required super.onKeyReady});

  @override
  State<StatefulWidget> createState() {
    return _OutPortDisplayState();
  }
}

final class _OutPortDisplayState extends _PortDisplayState<OutPortDisplay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildName(context, widget.outPort.name),
            const SizedBox(width: 8),
            _PortIndicator(
              key: indicatorKey,
              port: widget.outPort,
              onDragStarted: () {
                widget.onDragStarted(indicatorKey, widget.outPort);
              },
              onDragUpdate: widget.onDragUpdate,
              onDragEnd: () {
                widget.onDragEnd(indicatorKey, widget.outPort);
              },
              onDragAccepted: widget.onDragAccepted,
            )
          ],
        ));
  }
}
