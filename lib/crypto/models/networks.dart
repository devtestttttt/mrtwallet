import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/crypto/constant/tags.dart';

class NetworkType {
  final String name;
  final List<int> tag;
  final int mainNetworkId;
  final int value;
  final String caip2;
  static const int tagLength = 3;
  bool get isBitcoin =>
      this == NetworkType.bitcoinAndForked || this == NetworkType.bitcoinCash;

  const NetworkType._({
    required this.name,
    required this.tag,
    required this.mainNetworkId,
    required this.value,
    required this.caip2,
  });
  static const NetworkType bitcoinAndForked = NetworkType._(
      name: "Bitcoin",
      tag: CryptoKeyConst.bitconNetwork,
      mainNetworkId: 0,
      value: 0,
      caip2: "bip122");
  static const NetworkType bitcoinCash = NetworkType._(
      name: "BitcoinCash",
      tag: CryptoKeyConst.bitcoinCashNetwork,
      mainNetworkId: 0,
      value: 1,
      caip2: "bch");
  static const NetworkType xrpl = NetworkType._(
      name: "XRPL",
      tag: CryptoKeyConst.xrpNetwork,
      mainNetworkId: 30,
      value: 2,
      caip2: "xrpl");
  static const NetworkType ethereum = NetworkType._(
      name: "Ethereum",
      tag: CryptoKeyConst.evmNetwork,
      mainNetworkId: 100,
      value: 3,
      caip2: 'eip155');
  static const NetworkType tron = NetworkType._(
      name: "Tron",
      tag: CryptoKeyConst.tvmNetwork,
      mainNetworkId: 1001,
      value: 4,
      caip2: 'tron');
  static const NetworkType solana = NetworkType._(
      name: "Solana",
      tag: CryptoKeyConst.solanaNetwork,
      mainNetworkId: 33,
      value: 5,
      caip2: 'solana');
  static const NetworkType cardano = NetworkType._(
      name: "Cardano",
      tag: CryptoKeyConst.cardanoNetwork,
      mainNetworkId: 50,
      value: 6,
      caip2: 'cardano');
  static const NetworkType cosmos = NetworkType._(
      name: "Cosmos",
      tag: CryptoKeyConst.cosmosNetwork,
      mainNetworkId: 200,
      value: 7,
      caip2: 'cosmos');
  static const NetworkType ton = NetworkType._(
      name: "TON",
      tag: CryptoKeyConst.tonNetwork,
      mainNetworkId: 300,
      value: 8,
      caip2: 'tvm');
  static const NetworkType substrate = NetworkType._(
      name: "Substrate",
      tag: CryptoKeyConst.substrateNetwork,
      mainNetworkId: 400,
      value: 9,
      caip2: 'polkadot');
  static const NetworkType stellar = NetworkType._(
      name: "Stellar",
      tag: CryptoKeyConst.stellar,
      mainNetworkId: 600,
      value: 10,
      caip2: 'stellar');
  static const NetworkType monero = NetworkType._(
      name: "Monero",
      tag: CryptoKeyConst.monero,
      mainNetworkId: 700,
      value: 11,
      caip2: 'monero');
  static const NetworkType aptos = NetworkType._(
      name: "Aptos",
      tag: CryptoKeyConst.aptos,
      mainNetworkId: 810,
      value: 12,
      caip2: 'aptos');

  static const NetworkType sui = NetworkType._(
      name: "Sui",
      tag: CryptoKeyConst.sui,
      mainNetworkId: 800,
      value: 13,
      caip2: 'sui');

  static const List<NetworkType> values = [
    bitcoinAndForked,
    bitcoinCash,
    xrpl,
    ethereum,
    tron,
    solana,
    cardano,
    ton,
    cosmos,
    substrate,
    stellar,
    monero,
    aptos,
    sui
  ];

  static NetworkType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.incorrectNetwork);
  }

  static NetworkType fromTag(List<int>? tag) {
    if (tag != null && tag.length > tagLength) {
      tag = tag.sublist(0, tagLength);
    }
    return values.firstWhere((e) => BytesUtils.bytesEqual(tag, e.tag),
        orElse: () => throw WalletExceptionConst.incorrectNetwork);
  }

  static NetworkType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletExceptionConst.incorrectNetwork);
  }

  @override
  String toString() {
    return "NetworkType.$name";
  }
}
