import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/signer/bitcoin/bitcoin_signer.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

class Web3BitcoinSignMessageForm extends BitcoinWeb3Form<BitcoinClient?,
    IBitcoinAddress, Web3BitcoinSignMessage> {
  Web3BitcoinSignMessageForm({required this.request});

  @override
  Web3BitcoinRequest<Web3BitcoinSignMessageResponse, Web3BitcoinSignMessage>
      request;
  List<int> challengeBytes() {
    return BytesUtils.fromHexString(request.params.message);
  }

  String get message => request.params.message;
  String? get content => request.params.content;
  late final String _messagePrefix =
      request.params.messagePrefix ?? BitcoinSignerUtils.signMessagePrefix;
  String get messagePrefix => _messagePrefix;
  BIP137Mode _mode = BIP137Mode.p2pkhCompressed;
  BIP137Mode get mode => _mode;
  // bool _isPersonalMessage = true;
  bool get isPersonalMessage => true;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(_mode);
  }

  @override
  Future<void> initForm(
      {required BitcoinChain account,
      required IBitcoinAddress address,
      required WalletBitcoinNetwork network,
      required BitcoinClient<IBitcoinAddress>? client}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    // if (request.params.method ==
    //     Web3BitcoinRequestMethods.signPersonalMessage) {
    //   _messagePrefix =

    //   _isPersonalMessage = true;
    // }

    switch (this.address.networkAddress.type) {
      case P2pkhAddressType.p2pkh:
      case P2pkhAddressType.p2pkhwt:
        if (!this.address.keyType.isCompressed) {
          _mode = BIP137Mode.p2pkhUncompressed;
        }
        break;
      case P2shAddressType.p2wpkhInP2sh:
        _mode = BIP137Mode.p2shP2wpkh;
        break;
      case SegwitAddressType.p2tr:
        break;
      case SegwitAddressType.p2wpkh:
        _mode = BIP137Mode.p2wpkh;
        break;
      default:
        throw Web3BitcoinExceptionConstant.unsuportedSigningMessageAccount(
            this.address.orginalAddress);
    }
  }
}
