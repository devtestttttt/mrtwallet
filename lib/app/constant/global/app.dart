import 'package:on_chain_wallet/app/models/models/asset.dart';
import 'package:on_chain_wallet/app/models/models/image.dart';

class APPConst {
  static const String assetErc20Abi = "assets/solidity/erc20.json";
  static const String assetErc721Abi = "assets/solidity/erc721.json";
  static const String assetErc1155Abi = "assets/solidity/erc1155.json";
  static const APPAssetUri cosmosChains =
      APPAssetUri(url: "assets/chains.json", package: 'cosmos_sdk');
  static const String assetWebviewScript = "assets/webview/script.js";
  static const String assetWebviewPageScript = "assets/webview/script_page.js";
  static const String assetsTronWeb = "assets/webview/tron_web.js";
  static const String bnJs = "assets/webview/bn.js";
  static final APPImage logo = APPImage.local("assets/image/wallet.png");
  static final APPImage wc = APPImage.local("assets/image/wc.png");
  static final APPImage telegramLogo = APPImage.local("assets/image/t.png");
  static final APPImage githubLogo = APPImage.local("assets/image/g.png");
  static final APPImage ltc = APPImage.local("assets/image/ltc.png");
  static final APPImage bch = APPImage.local("assets/image/bch.png");
  static final APPImage btc = APPImage.local("assets/image/btc.png");
  static final APPImage doge = APPImage.local("assets/image/doge.png");
  static final APPImage pepecoin = APPImage.local("assets/image/pepecoin.png");
  static final APPImage bsv = APPImage.local("assets/image/bsv.png");
  static final APPImage dash = APPImage.local("assets/image/dash.png");
  static final APPImage xrp = APPImage.local("assets/image/xrp.png");
  static final APPImage eth = APPImage.local("assets/image/eth.png");
  static final APPImage matic = APPImage.local("assets/image/matic.png");
  static final APPImage bnb = APPImage.local("assets/image/bnb.png");
  static final APPImage trx = APPImage.local("assets/image/trx.png");
  static final APPImage sol = APPImage.local("assets/image/sol.png");
  static final APPImage ada = APPImage.local("assets/image/ada.png");
  static final APPImage atom = APPImage.local("assets/image/atom.png");
  static final APPImage cacao = APPImage.local("assets/image/cacao.png");
  static final APPImage avalance = APPImage.local("assets/image/avax.png");
  static final APPImage arbitrum = APPImage.local("assets/image/arb.png");
  static final APPImage base = APPImage.local("assets/image/base.png");
  static final APPImage optimistic = APPImage.local("assets/image/op.png");

  static final APPImage thor = APPImage.local("assets/image/thor.png");
  static final APPImage kujira = APPImage.local("assets/image/kujira.png");
  static final APPImage osmo = APPImage.local("assets/image/osmo.png");
  static final APPImage ton = APPImage.local("assets/image/ton.png");
  static final APPImage polkadot = APPImage.local("assets/image/polkadot.png");
  static final APPImage substrate =
      APPImage.local("assets/image/substrate.png");
  static final APPImage moonbeam = APPImage.local("assets/image/moonbeam.png");
  static final APPImage moonriver =
      APPImage.local("assets/image/moonriver.png");
  static final APPImage astar = APPImage.local("assets/image/astar.png");
  static final APPImage cf = APPImage.local("assets/image/cf.png");
  static final APPImage centrifuge = APPImage.local("assets/image/cfg.png");
  static final APPImage acala = APPImage.local("assets/image/acala.png");

  static final APPImage kusama = APPImage.local("assets/image/ksm.png");
  static final APPImage stellar = APPImage.local("assets/image/xlm.png");
  static final APPImage monero = APPImage.local("assets/image/monero.png");
  static final APPImage aptos = APPImage.local("assets/image/aptos.png");
  static final APPImage sui = APPImage.local("assets/image/sui.png");
  static const String name = "OnChain";
  static const Duration animationDuraion = Duration(milliseconds: 400);
  static const Duration milliseconds100 = Duration(milliseconds: 100);
  static const Duration milliseconds200 = Duration(milliseconds: 200);
  static const Duration oneSecoundDuration = Duration(seconds: 1);
  static const Duration twoSecoundDuration = Duration(seconds: 2);
  static const Duration tenSecoundDuration = Duration(seconds: 10);
  static const Duration futureTimeout = Duration(seconds: 10);

  static const double double80 = 80;
  static const double double40 = 40;
  static const double double20 = 20;
  static const double iconSize = 24;
  static const double largeIconSize = 80;
  static const double tooltipConstrainedWidth = 300;
  static const double dialogWidth = 650;
  static const double maxViewWidth = 650;
  static const double maxDialogHeight = 600;
  static const double maxTextFieldWidth = 400;
  static const double qrCodeWidth = 300;
  static const int maxNameLength = 20;
  static final RegExp accountNameRegExp = RegExp(r'^[^\n]{0,20}$');
  static final RegExp keyNameRegex = RegExp(r'^[^\n]{0,20}$');
  static final RegExp hex32Bytes = RegExp(r'^(0x)?[0-9a-fA-F]{64}$');
  static final hrpRegex = RegExp(r'^[a-z][a-z0-9]*$');
  static const double circleRadius25 = 25;
  static const double circleRadius12 = 12.5;
  static const double elevation = 2;
  static const double desktopAppWidth = 1200;
  static const double desktopAppHeight = 768;
  static const double naviationRailWidth = 80;
  static const String exampleBase58 = "sEd7FSsSXz9CGy....";
  static const String exampleBase32 = "GD2YLIOLNVQXNA....";
  static const String exampleHex = "0xa3f1df47";

  static const String exampleAuthenticatedHeader = "Authorization";
  static const String exampleAuthenticatedQuery = "api_key";
  static const String exampleDouble = "0.0025";

  static const String exampleAuthenticatedHeaderValue =
      "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==";
  static const String exampleAuthenticatedQueryValue = "api_key";

  static const String exampleAuthenticatedDigestAuthRealm = "monero-rpc";
  static const String exampleChannelId = "channel-1441";
  static const int defaultDecimalPlaces = 8;

  static const int maximumHeaderValue = 400;

  static const double largeCircleRadius = 60;
  static const double largeCircleRadius120 = 120;

  static const double disabledOpacity = 0.3;
}
