import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarContact extends ContactCore<StellarAddress> {
  StellarContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory StellarContact.newContact(
      {required StellarAddress address, required String name}) {
    return StellarContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory StellarContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.stellarContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final StellarAddress solanaAddress =
          StellarAddress.fromBase32Addr(address);

      return StellarContact._(
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
        CborTagsConst.stellarContact);
  }

  @override
  final String? type = null;
}
