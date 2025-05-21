//
//  Generated code. Do not modify.
//  source: landmark.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// A landmark that can have 1 to 3 dimensions. Use x for 1D points, (x, y) for
/// 2D points and (x, y, z) for 3D points. For more dimensions, consider using
/// matrix_data.proto.
class Landmark extends $pb.GeneratedMessage {
  factory Landmark({
    $core.double? x,
    $core.double? y,
    $core.double? z,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
    }
    if (z != null) {
      $result.z = z;
    }
    return $result;
  }
  Landmark._() : super();
  factory Landmark.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Landmark.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Landmark', package: const $pb.PackageName(_omitMessageNames ? '' : 'mediapipe'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'z', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Landmark clone() => Landmark()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Landmark copyWith(void Function(Landmark) updates) => super.copyWith((message) => updates(message as Landmark)) as Landmark;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Landmark create() => Landmark._();
  Landmark createEmptyInstance() => create();
  static $pb.PbList<Landmark> createRepeated() => $pb.PbList<Landmark>();
  @$core.pragma('dart2js:noInline')
  static Landmark getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Landmark>(create);
  static Landmark? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get z => $_getN(2);
  @$pb.TagNumber(3)
  set z($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasZ() => $_has(2);
  @$pb.TagNumber(3)
  void clearZ() => $_clearField(3);
}

/// Group of Landmark protos.
class LandmarkList extends $pb.GeneratedMessage {
  factory LandmarkList({
    $core.Iterable<Landmark>? landmark,
  }) {
    final $result = create();
    if (landmark != null) {
      $result.landmark.addAll(landmark);
    }
    return $result;
  }
  LandmarkList._() : super();
  factory LandmarkList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LandmarkList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LandmarkList', package: const $pb.PackageName(_omitMessageNames ? '' : 'mediapipe'), createEmptyInstance: create)
    ..pc<Landmark>(1, _omitFieldNames ? '' : 'landmark', $pb.PbFieldType.PM, subBuilder: Landmark.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LandmarkList clone() => LandmarkList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LandmarkList copyWith(void Function(LandmarkList) updates) => super.copyWith((message) => updates(message as LandmarkList)) as LandmarkList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LandmarkList create() => LandmarkList._();
  LandmarkList createEmptyInstance() => create();
  static $pb.PbList<LandmarkList> createRepeated() => $pb.PbList<LandmarkList>();
  @$core.pragma('dart2js:noInline')
  static LandmarkList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LandmarkList>(create);
  static LandmarkList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Landmark> get landmark => $_getList(0);
}

/// A normalized version of above Landmark proto. All coordiates should be within
/// [0, 1].
class NormalizedLandmark extends $pb.GeneratedMessage {
  factory NormalizedLandmark({
    $core.double? x,
    $core.double? y,
    $core.double? z,
  }) {
    final $result = create();
    if (x != null) {
      $result.x = x;
    }
    if (y != null) {
      $result.y = y;
    }
    if (z != null) {
      $result.z = z;
    }
    return $result;
  }
  NormalizedLandmark._() : super();
  factory NormalizedLandmark.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NormalizedLandmark.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NormalizedLandmark', package: const $pb.PackageName(_omitMessageNames ? '' : 'mediapipe'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'x', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'z', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NormalizedLandmark clone() => NormalizedLandmark()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NormalizedLandmark copyWith(void Function(NormalizedLandmark) updates) => super.copyWith((message) => updates(message as NormalizedLandmark)) as NormalizedLandmark;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NormalizedLandmark create() => NormalizedLandmark._();
  NormalizedLandmark createEmptyInstance() => create();
  static $pb.PbList<NormalizedLandmark> createRepeated() => $pb.PbList<NormalizedLandmark>();
  @$core.pragma('dart2js:noInline')
  static NormalizedLandmark getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NormalizedLandmark>(create);
  static NormalizedLandmark? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get z => $_getN(2);
  @$pb.TagNumber(3)
  set z($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasZ() => $_has(2);
  @$pb.TagNumber(3)
  void clearZ() => $_clearField(3);
}

/// Group of NormalizedLandmark protos.
class NormalizedLandmarkList extends $pb.GeneratedMessage {
  factory NormalizedLandmarkList({
    $core.Iterable<NormalizedLandmark>? landmark,
  }) {
    final $result = create();
    if (landmark != null) {
      $result.landmark.addAll(landmark);
    }
    return $result;
  }
  NormalizedLandmarkList._() : super();
  factory NormalizedLandmarkList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NormalizedLandmarkList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NormalizedLandmarkList', package: const $pb.PackageName(_omitMessageNames ? '' : 'mediapipe'), createEmptyInstance: create)
    ..pc<NormalizedLandmark>(1, _omitFieldNames ? '' : 'landmark', $pb.PbFieldType.PM, subBuilder: NormalizedLandmark.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NormalizedLandmarkList clone() => NormalizedLandmarkList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NormalizedLandmarkList copyWith(void Function(NormalizedLandmarkList) updates) => super.copyWith((message) => updates(message as NormalizedLandmarkList)) as NormalizedLandmarkList;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NormalizedLandmarkList create() => NormalizedLandmarkList._();
  NormalizedLandmarkList createEmptyInstance() => create();
  static $pb.PbList<NormalizedLandmarkList> createRepeated() => $pb.PbList<NormalizedLandmarkList>();
  @$core.pragma('dart2js:noInline')
  static NormalizedLandmarkList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NormalizedLandmarkList>(create);
  static NormalizedLandmarkList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NormalizedLandmark> get landmark => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
