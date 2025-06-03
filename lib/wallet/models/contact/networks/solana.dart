import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaContact extends ContactCore<SolAddress> {
  SolanaContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory SolanaContact.newContact(
      {required SolAddress address, required String name}) {
    return SolanaContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory SolanaContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.solanaContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final SolAddress solanaAddress = SolAddress(address);

      return SolanaContact._(
          addressObject: solanaAddress, created: created, name: name);
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
        CborTagsConst.solanaContact);
  }

  @override
  final String? type = null;
}
