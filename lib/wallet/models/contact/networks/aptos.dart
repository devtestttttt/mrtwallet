import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/on_chain.dart';

class AptosContact extends ContactCore<AptosAddress> {
  AptosContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory AptosContact.newContact(
      {required AptosAddress address, required String name}) {
    return AptosContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory AptosContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.aptosContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final AptosAddress networkAddress = AptosAddress(address);

      return AptosContact._(
          addressObject: networkAddress, created: created, name: name);
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
        CborTagsConst.aptosContact);
  }

  @override
  final String? type = null;
}
