import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/grpc/gen/taiko.pb.dart';

class TaikoDifficultyHitObject with Timed {
  final TaikoHitObject hitObject;

  final TaikoDifficultyHitObject? previous;

  TaikoDifficultyHitObject(this.hitObject, this.previous);

  @override
  get startTime => hitObject.startTime.toInt();
}
