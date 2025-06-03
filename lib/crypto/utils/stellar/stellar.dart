import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/wallet/constant/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarUtils {
  static StellarAsset? tryToAssets(AssetType type,
      {String? code, StellarPublicKey? issuer}) {
    if (type == AssetType.native) {
      return StellarAssetNative();
    }
    if (code == null || issuer == null) return null;
    final isValid = StellarHelper.isValidIssueAsset(code: code, type: type);
    if (!isValid) return null;
    if (type == AssetType.poolShare) {
      return StellarAssetPoolShare(BytesUtils.fromHexString(code));
    }
    switch (type) {
      case AssetType.creditAlphanum12:
        return StellarAssetCreditAlphanum12(issuer: issuer, code: code);
      case AssetType.creditAlphanum4:
        return StellarAssetCreditAlphanum4(issuer: issuer, code: code);
      default:
        return null;
    }
  }

  static BigInt? tryRationalNumberToOfferId(BigRational? rational) {
    if (rational == null) return null;
    final toBig = rational.toBigInt();
    if (toBig.isNegative || toBig > StellarConst.maxIssueAmount) return null;
    return toBig;
  }

  static List<int> stellarBase32SecretKeyToImportKey(String? secretKey) {
    if (secretKey == null) throw WalletExceptionConst.invalidPrivateKey;
    try {
      final key = XlmAddrDecoder()
          .decode(secretKey, {'addr_type': XlmAddrTypes.privKey});
      if (key.type != XlmAddrTypes.privKey) {
        throw const DartStellarPlugingException('Invalid key type.');
      }
      return key.pubKeyBytes;
    } catch (_) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }
}
