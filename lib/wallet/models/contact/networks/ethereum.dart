import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class EthereumContact extends ContactCore<ETHAddress> {
  EthereumContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory EthereumContact.newContact(
      {required ETHAddress address, required String name}) {
    return EthereumContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory EthereumContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.ethereumContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final ETHAddress ethAddress = ETHAddress(address);

      return EthereumContact._(
          addressObject: ethAddress, created: created, name: name);
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
        CborTagsConst.ethereumContact);
  }

  @override
  final String? type = null;
}
