//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncAlbumToAssetV1 {
  /// Returns a new [SyncAlbumToAssetV1] instance.
  SyncAlbumToAssetV1({
    required this.albumId,
    required this.assetId,
  });

  String albumId;

  String assetId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncAlbumToAssetV1 &&
    other.albumId == albumId &&
    other.assetId == assetId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (albumId.hashCode) +
    (assetId.hashCode);

  @override
  String toString() => 'SyncAlbumToAssetV1[albumId=$albumId, assetId=$assetId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'albumId'] = this.albumId;
      json[r'assetId'] = this.assetId;
    return json;
  }

  /// Returns a new [SyncAlbumToAssetV1] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncAlbumToAssetV1? fromJson(dynamic value) {
    upgradeDto(value, "SyncAlbumToAssetV1");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return SyncAlbumToAssetV1(
        albumId: mapValueOfType<String>(json, r'albumId')!,
        assetId: mapValueOfType<String>(json, r'assetId')!,
      );
    }
    return null;
  }

  static List<SyncAlbumToAssetV1> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncAlbumToAssetV1>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncAlbumToAssetV1.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncAlbumToAssetV1> mapFromJson(dynamic json) {
    final map = <String, SyncAlbumToAssetV1>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncAlbumToAssetV1.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncAlbumToAssetV1-objects as value to a dart map
  static Map<String, List<SyncAlbumToAssetV1>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncAlbumToAssetV1>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncAlbumToAssetV1.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'albumId',
    'assetId',
  };
}

