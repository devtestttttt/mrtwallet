import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/ada/ada.dart';

class CardanoContact extends ContactCore<ADAAddress> {
  CardanoContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory CardanoContact.newContact(
      {required ADAAddress address, required String name}) {
    return CardanoContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory CardanoContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.cardanoContct);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final ADAAddress cardanoAddr = ADAAddress.fromAddress(address);

      return CardanoContact._(
          addressObject: cardanoAddr, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  String get address => addressObject.address;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address, CborEpochIntValue(created), name]),
        CborTagsConst.cardanoContct);
  }

  @override
  String? get type => addressObject.addressType.name;
}
