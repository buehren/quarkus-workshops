class WinnerScore {
  WinnerScore(this.name, this.score);

  String name;
  int score;

  WinnerScore.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        score = json['score'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
      };
}

/*

https://flutter.dev/docs/development/data-and-backend/json#serializing-json-using-code-generation-libraries

> flutter pub run build_runner watch --delete-conflicting-outputs
...
Generator cannot target libraries that have not been migrated to null-safety.


import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'winner_score.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

class WinnerScore {
  WinnerScore(this.name, this.score);

  String name;
  int score;

  /// A necessary factory constructor for creating a new instance
  /// from a map. Pass the map to the generated `_$...FromJson()` constructor.
  /// The constructor is named after the source class.
  factory WinnerScore.fromJson(Map<String, dynamic> json) => _$WinnerScoreFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$...ToJson`.
  Map<String, dynamic> toJson() => _$WinnerScoreToJson(this);
}
*/
