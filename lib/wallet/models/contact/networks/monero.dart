import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';

class MoneroContact extends ContactCore<MoneroAddress> {
  MoneroContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory MoneroContact.newContact(
      {required MoneroAddress address, required String name}) {
    return MoneroContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory MoneroContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.moneroContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final MoneroAddress moneroAddress = MoneroAddress(address);

      return MoneroContact._(
          addressObject: moneroAddress, created: created, name: name);
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
        CborTagsConst.moneroContact);
  }

  @override
  String? get type => addressObject.type.name;
}
