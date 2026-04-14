import 'package:json_annotation/json_annotation.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';

part 'campus_task_model.g.dart';

@JsonSerializable()
class CampusTaskModel extends CampusTask {
  const CampusTaskModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.completed,
  });

  factory CampusTaskModel.fromJson(Map<String, dynamic> json) =>
      _$CampusTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$CampusTaskModelToJson(this);
}
