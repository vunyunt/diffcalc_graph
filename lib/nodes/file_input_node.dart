import 'dart:io';
import 'dart:typed_data';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Reads a file and sends the binary data through the output port. Each
/// complete file will be sent as a single event of [Uint8List]
class FileInputNode extends Node with UiNodeMixin {
  static const qualifiedName = "FileInputNode";

  @override
  String get typeName => qualifiedName;

  static void registerFactoryTo(NodeDirectory directory) {
    directory.registerFactoryFor(
        qualifiedName,
        (graph, {attributes, id}) =>
            FileInputNode(graph, id: id)..loadAttributesFrom(attributes));
  }

  String _filePath = '';

  late final OutPort<Uint8List, FileInputNode> output;

  FileInputNode(super.graph, {super.id});

  @override
  Iterable<InPort<dynamic, FileInputNode>> createInPorts() => [];

  @override
  Iterable<OutPort<dynamic, FileInputNode>> createOutPorts() {
    output = OutPort(node: this, name: "output");

    return [output];
  }

  @override
  double get minWidth => 480;

  @override
  Widget? buildUiWidget(BuildContext context) {
    return _FileInputNodeUi(
      onPathChanged: (path) {
        _filePath = path;
      },
      onSendPressed: () async {
        final file = File.fromUri(Uri.file(_filePath));
        final bytes = await file.readAsBytes();
        sendTo(output, bytes);
      },
    );
  }
}

class _FileInputNodeUi extends StatefulWidget {
  final Function(String) onPathChanged;
  final Function() onSendPressed;

  const _FileInputNodeUi(
      {required this.onPathChanged, required this.onSendPressed});

  @override
  State<StatefulWidget> createState() {
    return _FileInputNodeUiState();
  }
}

class _FileInputNodeUiState extends State<_FileInputNodeUi> {
  final TextEditingController _filePathController = TextEditingController();

  @override
  initState() {
    super.initState();

    _filePathController.addListener(() {
      widget.onPathChanged(_filePathController.text);
    });
  }

  pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      setState(() {
        _filePathController.text = result.files.single.path ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: TextField(
              controller: _filePathController,
              maxLines: 1,
            )),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: pickFile, child: const Text("Pick file")),
            const SizedBox(width: 16),
            ElevatedButton(
                onPressed: () {
                  widget.onSendPressed();
                },
                child: const Text("Send"))
          ],
        ));
  }
}
