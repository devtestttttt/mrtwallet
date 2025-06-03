import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';

class CosmosContact extends ContactCore<CosmosBaseAddress> {
  CosmosContact._(
      {required super.addressObject,
      required super.created,
      required super.name});
  factory CosmosContact.newContact(
      {required CosmosBaseAddress address, required String name}) {
    return CosmosContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory CosmosContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.cosmosContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final CosmosBaseAddress cardanoAddr = CosmosBaseAddress(address);

      return CosmosContact._(
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
        CborTagsConst.cosmosContact);
  }

  @override
  final String? type = null;
}
