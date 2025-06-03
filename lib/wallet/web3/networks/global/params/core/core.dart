import 'package:on_chain_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/params.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/web_request.dart';

class Web3GlobalRequest<RESPONSE> extends Web3Request<RESPONSE,
    Web3GlobalRequestParams<RESPONSE>, Web3APPAuthentication> {
  Web3GlobalRequest(
      {required super.authenticated,
      required super.info,
      required super.params});
}
