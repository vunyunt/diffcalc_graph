import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileInputNode extends Node with UiNodeMixin {
  String _filePath = '';

  FileInputNode(super.graph);

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() => [];

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() =>
      [OutPort(node: this, name: "output")];

  @override
  String get typeName => "FileInputNode";

  @override
  Widget? buildUiWidget(BuildContext context) {
    return _FileInputNodeUi(
      onPathChanged: (path) {
        _filePath = path;
      },
      onSendPressed: () {},
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
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: TextField(
              controller: _filePathController,
              onChanged: (value) {
                widget.onPathChanged(value);
              },
              maxLines: 1,
            )),
            ElevatedButton(onPressed: pickFile, child: const Text("Pick file")),
            ElevatedButton(onPressed: () {}, child: const Text("Send"))
          ],
        ));
  }
}
