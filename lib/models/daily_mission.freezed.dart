// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_mission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyMission _$DailyMissionFromJson(Map<String, dynamic> json) {
  return _DailyMission.fromJson(json);
}

/// @nodoc
mixin _$DailyMission {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  set description(String value) => throw _privateConstructorUsedError;
  MissionType get type => throw _privateConstructorUsedError;
  set type(MissionType value) => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  set xpReward(int value) => throw _privateConstructorUsedError;
  int get target => throw _privateConstructorUsedError;
  set target(int value) => throw _privateConstructorUsedError;
  MissionDifficulty get difficulty => throw _privateConstructorUsedError;
  set difficulty(MissionDifficulty value) => throw _privateConstructorUsedError;
  MissionRarity get rarity => throw _privateConstructorUsedError;
  set rarity(MissionRarity value) => throw _privateConstructorUsedError;
  int get xpBonus => throw _privateConstructorUsedError;
  set xpBonus(int value) => throw _privateConstructorUsedError;
  int get streakBonus => throw _privateConstructorUsedError;
  set streakBonus(int value) => throw _privateConstructorUsedError;
  MissionCategory get category => throw _privateConstructorUsedError;
  set category(MissionCategory value) => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  set progress(int value) => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  set completed(bool value) => throw _privateConstructorUsedError;

  /// Serializes this DailyMission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyMission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyMissionCopyWith<DailyMission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyMissionCopyWith<$Res> {
  factory $DailyMissionCopyWith(
    DailyMission value,
    $Res Function(DailyMission) then,
  ) = _$DailyMissionCopyWithImpl<$Res, DailyMission>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    MissionType type,
    int xpReward,
    int target,
    MissionDifficulty difficulty,
    MissionRarity rarity,
    int xpBonus,
    int streakBonus,
    MissionCategory category,
    int progress,
    bool completed,
  });
}

/// @nodoc
class _$DailyMissionCopyWithImpl<$Res, $Val extends DailyMission>
    implements $DailyMissionCopyWith<$Res> {
  _$DailyMissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyMission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? xpReward = null,
    Object? target = null,
    Object? difficulty = null,
    Object? rarity = null,
    Object? xpBonus = null,
    Object? streakBonus = null,
    Object? category = null,
    Object? progress = null,
    Object? completed = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MissionType,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            target: null == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as int,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as MissionDifficulty,
            rarity: null == rarity
                ? _value.rarity
                : rarity // ignore: cast_nullable_to_non_nullable
                      as MissionRarity,
            xpBonus: null == xpBonus
                ? _value.xpBonus
                : xpBonus // ignore: cast_nullable_to_non_nullable
                      as int,
            streakBonus: null == streakBonus
                ? _value.streakBonus
                : streakBonus // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as MissionCategory,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as int,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyMissionImplCopyWith<$Res>
    implements $DailyMissionCopyWith<$Res> {
  factory _$$DailyMissionImplCopyWith(
    _$DailyMissionImpl value,
    $Res Function(_$DailyMissionImpl) then,
  ) = __$$DailyMissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    MissionType type,
    int xpReward,
    int target,
    MissionDifficulty difficulty,
    MissionRarity rarity,
    int xpBonus,
    int streakBonus,
    MissionCategory category,
    int progress,
    bool completed,
  });
}

/// @nodoc
class __$$DailyMissionImplCopyWithImpl<$Res>
    extends _$DailyMissionCopyWithImpl<$Res, _$DailyMissionImpl>
    implements _$$DailyMissionImplCopyWith<$Res> {
  __$$DailyMissionImplCopyWithImpl(
    _$DailyMissionImpl _value,
    $Res Function(_$DailyMissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyMission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? xpReward = null,
    Object? target = null,
    Object? difficulty = null,
    Object? rarity = null,
    Object? xpBonus = null,
    Object? streakBonus = null,
    Object? category = null,
    Object? progress = null,
    Object? completed = null,
  }) {
    return _then(
      _$DailyMissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MissionType,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        target: null == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as int,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as MissionDifficulty,
        rarity: null == rarity
            ? _value.rarity
            : rarity // ignore: cast_nullable_to_non_nullable
                  as MissionRarity,
        xpBonus: null == xpBonus
            ? _value.xpBonus
            : xpBonus // ignore: cast_nullable_to_non_nullable
                  as int,
        streakBonus: null == streakBonus
            ? _value.streakBonus
            : streakBonus // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as MissionCategory,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as int,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyMissionImpl extends _DailyMission {
  _$DailyMissionImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.xpReward = 30,
    this.target = 1,
    this.difficulty = MissionDifficulty.easy,
    this.rarity = MissionRarity.common,
    this.xpBonus = 0,
    this.streakBonus = 0,
    this.category = MissionCategory.learning,
    this.progress = 0,
    this.completed = false,
  }) : super._();

  factory _$DailyMissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyMissionImplFromJson(json);

  @override
  String id;
  @override
  String title;
  @override
  String description;
  @override
  MissionType type;
  @override
  @JsonKey()
  int xpReward;
  @override
  @JsonKey()
  int target;
  @override
  @JsonKey()
  MissionDifficulty difficulty;
  @override
  @JsonKey()
  MissionRarity rarity;
  @override
  @JsonKey()
  int xpBonus;
  @override
  @JsonKey()
  int streakBonus;
  @override
  @JsonKey()
  MissionCategory category;
  @override
  @JsonKey()
  int progress;
  @override
  @JsonKey()
  bool completed;

  @override
  String toString() {
    return 'DailyMission(id: $id, title: $title, description: $description, type: $type, xpReward: $xpReward, target: $target, difficulty: $difficulty, rarity: $rarity, xpBonus: $xpBonus, streakBonus: $streakBonus, category: $category, progress: $progress, completed: $completed)';
  }

  /// Create a copy of DailyMission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyMissionImplCopyWith<_$DailyMissionImpl> get copyWith =>
      __$$DailyMissionImplCopyWithImpl<_$DailyMissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyMissionImplToJson(this);
  }
}

abstract class _DailyMission extends DailyMission {
  factory _DailyMission({
    required String id,
    required String title,
    required String description,
    required MissionType type,
    int xpReward,
    int target,
    MissionDifficulty difficulty,
    MissionRarity rarity,
    int xpBonus,
    int streakBonus,
    MissionCategory category,
    int progress,
    bool completed,
  }) = _$DailyMissionImpl;
  _DailyMission._() : super._();

  factory _DailyMission.fromJson(Map<String, dynamic> json) =
      _$DailyMissionImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override
  String get title;
  set title(String value);
  @override
  String get description;
  set description(String value);
  @override
  MissionType get type;
  set type(MissionType value);
  @override
  int get xpReward;
  set xpReward(int value);
  @override
  int get target;
  set target(int value);
  @override
  MissionDifficulty get difficulty;
  set difficulty(MissionDifficulty value);
  @override
  MissionRarity get rarity;
  set rarity(MissionRarity value);
  @override
  int get xpBonus;
  set xpBonus(int value);
  @override
  int get streakBonus;
  set streakBonus(int value);
  @override
  MissionCategory get category;
  set category(MissionCategory value);
  @override
  int get progress;
  set progress(int value);
  @override
  bool get completed;
  set completed(bool value);

  /// Create a copy of DailyMission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyMissionImplCopyWith<_$DailyMissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
