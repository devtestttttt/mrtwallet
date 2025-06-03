import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';

class TronContact extends ContactCore<TronAddress> {
  TronContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory TronContact.newContact(
      {required TronAddress address, required String name}) {
    return TronContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory TronContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.tronContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final TronAddress ethAddress = TronAddress(address);

      return TronContact._(
          addressObject: ethAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  String get address => addressObject.toAddress();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address, CborEpochIntValue(created), name]),
        CborTagsConst.tronContact);
  }

  @override
  final String? type = null;
}
