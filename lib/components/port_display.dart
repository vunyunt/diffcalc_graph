import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:flutter/material.dart';

Widget buildName(BuildContext context, String name) {
  return Text(name);
}

class _PortIndicator extends StatefulWidget {
  final Port port;
  final void Function() onTapDown;
  final void Function() onTapUp;

  const _PortIndicator(
      {super.key,
      required this.port,
      required this.onTapDown,
      required this.onTapUp});

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
        onEnter: (e) => setState(() {
              hover = true;
            }),
        onExit: (e) => setState(() {
              hover = false;
            }),
        child: GestureDetector(
            onTapDown: (e) {
              widget.onTapDown();
            },
            onTapUp: (e) {
              widget.onTapUp();
            },
            child: Container(
                width: 8,
                height: 6,
                decoration: BoxDecoration(
                  color: hover
                      ? Theme.of(context).colorScheme.primary
                      : widget.port.connected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).disabledColor,
                  borderRadius: const BorderRadiusDirectional.only(
                      topEnd: Radius.circular(2),
                      bottomEnd: Radius.circular(2)),
                ))));
  }
}

abstract class PortDisplay extends StatefulWidget {
  final void Function(GlobalObjectKey, Port) onTapDown;
  final void Function(GlobalObjectKey, Port) onTapUp;
  final void Function(GlobalObjectKey, Port) onKeyReady;

  Port<dynamic, UiNodeMixin> get port;

  const PortDisplay(
      {super.key,
      required this.onTapDown,
      required this.onTapUp,
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
      required super.onTapDown,
      required super.onTapUp,
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
              onTapDown: () {
                widget.onTapDown(indicatorKey, widget.inPort);
              },
              onTapUp: () {
                widget.onTapUp(indicatorKey, widget.inPort);
              },
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
      required super.onTapDown,
      required super.onTapUp,
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
                onTapDown: () {
                  widget.onTapDown(indicatorKey, widget.outPort);
                },
                onTapUp: () {
                  widget.onTapUp(indicatorKey, widget.outPort);
                })
          ],
        ));
  }
}
