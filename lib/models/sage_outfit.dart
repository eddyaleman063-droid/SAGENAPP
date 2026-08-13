import 'package:flutter/material.dart';

enum AccessorySlot { head, face, neck, body }

/// A single wearable accessory for the Sage mascot.
class SageAccessory {
  final String id;
  final AccessorySlot slot;
  final String label;
  final String assetPath;
  final Color tint;

  const SageAccessory({
    required this.id,
    required this.slot,
    required this.label,
    this.assetPath = '',
    this.tint = Colors.transparent,
  });

  bool get hasAsset => assetPath.isNotEmpty;

  static const none = SageAccessory(
    id: '',
    slot: AccessorySlot.head,
    label: '',
  );
}

/// Complete outfit configuration for the Sage mascot.
class SageOutfit {
  final SageAccessory? head;
  final SageAccessory? face;
  final SageAccessory? neck;
  final SageAccessory? body;

  const SageOutfit({this.head, this.face, this.neck, this.body});

  static const empty = SageOutfit();

  bool get isEmpty =>
      head == null && face == null && neck == null && body == null;
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SageOutfit &&
          runtimeType == other.runtimeType &&
          head?.id == other.head?.id &&
          face?.id == other.face?.id &&
          neck?.id == other.neck?.id &&
          body?.id == other.body?.id;

  @override
  int get hashCode => Object.hash(head?.id, face?.id, neck?.id, body?.id);
}
