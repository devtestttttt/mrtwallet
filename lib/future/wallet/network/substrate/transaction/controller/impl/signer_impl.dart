import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/models/metadata_fields.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';

mixin SubstrateSignerImpl {
  WalletProvider get walletProvider;
  Future<ExtrinsicInfo> buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
      required ISubstrateAddress address,
      List<String> memos = const []});

  Future<List<int>> _signTransaction({
    required ISubstrateAddress address,
    required WalletSubstrateNetwork network,
    required List<int> digest,
  }) async {
    final sig = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest<List<int>>(
      addresses: [address],
      network: network,
      sign: (generateSignature) async {
        final signature = await generateSignature(GlobalSignRequest.substrate(
            digest: digest, index: address.keyIndex));
        return signature.signature;
      },
    ));
    return sig.result;
  }

  Future<ExtrinsicInfo> signTransaction({
    required ISubstrateAddress address,
    required WalletSubstrateNetwork network,
  }) async {
    return await buildAndSignTransaction(
        onGenerateSignature: (digest) async {
          return await _signTransaction(
              address: address, network: network, digest: digest);
        },
        address: address);
  }
}
//// 050300b5cbfff515f8b28eb2cbba6f2387548dff7b728180a0e16d2f384bd711e396a60700b08ef01b770f780000c9550f001a000000e566d149729892a803c3c4b1e652f09445926234d956a0f166be4d4dea91f5361cb93796027beb46c02d90042fbc13a38326596a146c0004025b4cbe6c069e7200
///0ec957eab6625d125a38128f0c82c49d8d9dce6a4f9c307c0addcbfc7c9e2a9a533ca3a192ea45377fa073ab5bc352f9748c75af640be25d92cf0d025ffb1a0e
