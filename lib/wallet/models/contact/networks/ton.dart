import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart';

class TonContact extends ContactCore<TonAddress> {
  TonContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory TonContact.newContact(
      {required TonAddress address, required String name}) {
    return TonContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory TonContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.tonContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final TonAddress solanaAddress = TonAddress(address);

      return TonContact._(
          addressObject: solanaAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  String get address => addressObject.toString();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address, CborEpochIntValue(created), name]),
        CborTagsConst.tonContact);
  }

  @override
  String get type => addressObject.type.name;
}
