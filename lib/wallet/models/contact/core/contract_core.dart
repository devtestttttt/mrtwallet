import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/euqatable/equatable.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/aptos.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/bitcoin.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/cardano.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/cosmos.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/ethereum.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/monero.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/stellar.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/substrate.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/sui.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/xrp.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/solana.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/ton.dart';
import 'package:on_chain_wallet/wallet/models/contact/networks/tron.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';

abstract class ContactCore<T> with CborSerializable, Equatable {
  final T addressObject;
  String get address;
  final String name;
  final DateTime created;
  String? get type;

  String get identifier => address;
  @override
  List get variabels => [address];

  const ContactCore(
      {required this.addressObject, required this.name, required this.created});

  static T deserialize<T extends ContactCore>(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    ContactCore contact;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        contact = BitcoinContact.deserialize(network.toNetwork(),
            bytes: bytes, obj: obj);
        break;
      case NetworkType.ethereum:
        contact = EthereumContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.tron:
        contact = TronContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.solana:
        contact = SolanaContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.cardano:
        contact = CardanoContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.cosmos:
        contact = CosmosContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.ton:
        contact = TonContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.xrpl:
        contact = RippleContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.stellar:
        contact = StellarContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.substrate:
        contact = SubstrateContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.monero:
        contact = MoneroContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.sui:
        contact = SuiContact.deserialize(bytes: bytes, obj: obj);
        break;
      case NetworkType.aptos:
        contact = AptosContact.deserialize(bytes: bytes, obj: obj);
        break;
      default:
        throw WalletExceptionConst.networkDoesNotExist;
    }
    if (contact is! T) {
      throw WalletExceptionConst.invalidArgruments(
          "$T", contact.runtimeType.toString());
    }
    return contact;
  }

  static T newContact<T extends ContactCore>(
      {required WalletNetwork network,
      required dynamic address,
      required String name}) {
    ContactCore contact;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        contact = BitcoinContact.newContact(
            address: address, network: network.toNetwork(), name: name);
      case NetworkType.ethereum:
        contact = EthereumContact.newContact(address: address, name: name);
      case NetworkType.tron:
        contact = TronContact.newContact(address: address, name: name);
      case NetworkType.cardano:
        contact = CardanoContact.newContact(address: address, name: name);
      case NetworkType.cosmos:
        contact = CosmosContact.newContact(address: address, name: name);
      case NetworkType.solana:
        contact = SolanaContact.newContact(address: address, name: name);
      case NetworkType.ton:
        contact = TonContact.newContact(address: address, name: name);
      case NetworkType.substrate:
        contact = SubstrateContact.newContact(address: address, name: name);
      case NetworkType.xrpl:
        contact = RippleContact.newContact(address: address, name: name);
      case NetworkType.stellar:
        contact = StellarContact.newContact(address: address, name: name);
      case NetworkType.monero:
        contact = MoneroContact.newContact(address: address, name: name);
      case NetworkType.aptos:
        contact = AptosContact.newContact(address: address, name: name);
      case NetworkType.sui:
        contact = SuiContact.newContact(address: address, name: name);
      default:
        throw WalletExceptionConst.networkDoesNotExist;
    }
    if (contact is! T) {
      throw WalletExceptionConst.invalidArgruments(
          "$T", contact.runtimeType.toString());
    }
    return contact;
  }
}
