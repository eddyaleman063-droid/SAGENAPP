// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  LessonType get type => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int get correctIndex => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError;

  /// Serializes this Challenge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call({
    String id,
    String question,
    LessonType type,
    List<String> options,
    int correctIndex,
    String explanation,
    String lessonId,
    int difficulty,
  });
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? type = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
    Object? lessonId = null,
    Object? difficulty = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as LessonType,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctIndex: null == correctIndex
                ? _value.correctIndex
                : correctIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonId: null == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
    _$ChallengeImpl value,
    $Res Function(_$ChallengeImpl) then,
  ) = __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String question,
    LessonType type,
    List<String> options,
    int correctIndex,
    String explanation,
    String lessonId,
    int difficulty,
  });
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
    _$ChallengeImpl _value,
    $Res Function(_$ChallengeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? type = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
    Object? lessonId = null,
    Object? difficulty = null,
  }) {
    return _then(
      _$ChallengeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as LessonType,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctIndex: null == correctIndex
            ? _value.correctIndex
            : correctIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonId: null == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl extends _Challenge {
  const _$ChallengeImpl({
    required this.id,
    required this.question,
    required this.type,
    required final List<String> options,
    required this.correctIndex,
    required this.explanation,
    this.lessonId = '',
    this.difficulty = 1,
  }) : _options = options,
       super._();

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String question;
  @override
  final LessonType type;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctIndex;
  @override
  final String explanation;
  @override
  @JsonKey()
  final String lessonId;
  @override
  @JsonKey()
  final int difficulty;

  @override
  String toString() {
    return 'Challenge(id: $id, question: $question, type: $type, options: $options, correctIndex: $correctIndex, explanation: $explanation, lessonId: $lessonId, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctIndex, correctIndex) ||
                other.correctIndex == correctIndex) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    question,
    type,
    const DeepCollectionEquality().hash(_options),
    correctIndex,
    explanation,
    lessonId,
    difficulty,
  );

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(this);
  }
}

abstract class _Challenge extends Challenge {
  const factory _Challenge({
    required final String id,
    required final String question,
    required final LessonType type,
    required final List<String> options,
    required final int correctIndex,
    required final String explanation,
    final String lessonId,
    final int difficulty,
  }) = _$ChallengeImpl;
  const _Challenge._() : super._();

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get question;
  @override
  LessonType get type;
  @override
  List<String> get options;
  @override
  int get correctIndex;
  @override
  String get explanation;
  @override
  String get lessonId;
  @override
  int get difficulty;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
