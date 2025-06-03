import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/crypto/utils/address/utils.dart';

class BitcoinContact extends ContactCore<BitcoinBaseAddress> {
  BitcoinContact._(
      {required super.addressObject,
      required this.address,
      required super.created,
      required super.name});
  factory BitcoinContact.newContact(
      {required BitcoinBaseAddress address,
      required WalletBitcoinNetwork network,
      required String name}) {
    return BitcoinContact._(
        addressObject: address,
        address: address.toAddress(network.coinParam.transacationNetwork),
        created: DateTime.now(),
        name: name);
  }
  factory BitcoinContact.deserialize(WalletBitcoinNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.bitcoinContact);
      final String address = cbor.elementAs(0);
      final BitcoinAddressType type =
          BitcoinAddressType.fromValue(cbor.elementAs(1));
      final DateTime created = cbor.elementAs(2);
      final String name = cbor.elementAs(3);
      final bitcoinAddress = BlockchainAddressUtils.toBitcoinAddressFromType(
          bitcoinAddress: address, addressType: type, network: network);
      if (bitcoinAddress.toAddress(network.coinParam.transacationNetwork) !=
          address) {
        throw WalletExceptionConst.invalidContactDetails;
      }
      return BitcoinContact._(
          addressObject: bitcoinAddress,
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
        CborListValue.fixedLength([
          address,
          addressObject.type.value,
          CborEpochIntValue(created),
          name
        ]),
        CborTagsConst.bitcoinContact);
  }

  @override
  late final String type = addressObject.type.value;
}
