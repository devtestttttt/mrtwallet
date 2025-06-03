import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/app/utils/utils.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/permission/models/account.dart';

class Web3EthreumPersonalSign extends Web3EthereumRequestParam<String> {
  final Web3EthereumChainAccount accessAccount;
  final String message;
  final String? content;

  Web3EthreumPersonalSign._(
      {required this.accessAccount, required this.message, this.content});

  factory Web3EthreumPersonalSign(
      String message, Web3EthereumChainAccount account) {
    String? content = StringUtils.tryDecode(BytesUtils.fromHexString(message));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3EthreumPersonalSign._(
        accessAccount: account, message: message, content: content);
  }

  factory Web3EthreumPersonalSign.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final List<int> challeng = values.elementAs(2);
    return Web3EthreumPersonalSign._(
        accessAccount: Web3EthereumChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        message: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAs(3));
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.persoalSign;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          CborBytesValue(BytesUtils.fromHexString(message)),
          content
        ]),
        type.tag);
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(message);
  }

  @override
  Web3EthereumRequest<String, Web3EthreumPersonalSign> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3EthereumRequest<String, Web3EthreumPersonalSign>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3EthereumChainAccount> get requiredAccounts => [accessAccount];
}
