import 'package:freezed_annotation/freezed_annotation.dart';

part 'label.freezed.dart';
part 'label.g.dart';

/// A GitLab label: its name and, when the endpoint provides details, its
/// colour.
///
/// GitLab returns labels either as bare strings or, with
/// `with_labels_details=true`, as objects carrying a colour. Both are handled
/// so the colour reaches the UI's contrast calculation when it is available.
@freezed
abstract class Label with _$Label {
  const factory Label({
    required String name,
    String? color,
    @JsonKey(name: 'text_color') String? textColor,
  }) = _Label;

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);

  /// Parses one label list element, which GitLab returns as a string or object.
  static Label fromDynamic(Object? raw) {
    if (raw is String) {
      return Label(name: raw);
    }
    return Label.fromJson(raw as Map<String, dynamic>);
  }

  /// Parses a labels array whose elements may be strings or objects.
  static List<Label> listFromJson(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    return raw.map(Label.fromDynamic).toList(growable: false);
  }
}
