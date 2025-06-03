import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleContact extends ContactCore<XRPAddress> {
  RippleContact._(
      {required super.addressObject,
      required this.address,
      required super.created,
      required super.name});
  factory RippleContact.newContact(
      {required XRPAddress address, required String name}) {
    return RippleContact._(
        addressObject: address,
        address: address.tag == null ? address.toString() : address.toAddress(),
        created: DateTime.now(),
        name: name);
  }
  factory RippleContact.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.rippleContact);
      final String address = cbor.elementAs(0);
      final int? tag = cbor.elementAs(1);
      final DateTime created = cbor.elementAs(2);
      final String name = cbor.elementAs(3);
      final rippleAddress = XRPAddress(address);
      if (rippleAddress.tag != tag) {
        throw WalletExceptionConst.invalidContactDetails;
      }
      return RippleContact._(
          addressObject: rippleAddress,
          address: address,
          created: created,
          name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final String address;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [address, addressObject.tag, CborEpochIntValue(created), name]),
        CborTagsConst.rippleContact);
  }

  @override
  late final String type =
      addressObject.tag != null ? "x_address" : "classic_address";
}
