import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/messages/models/models/wallet_response.dart';
import 'package:on_chain_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';
import 'package:on_chain_wallet/wallet/web3/state/state.dart';
import 'package:on_chain_wallet/wallet/web3/utils/web3_validator_utils.dart';

mixin BitcoinWeb3StateHandler<
        STATEADDRESS,
        STATEACCOUNT extends Web3StateAccount<
            BitcoinBaseAddress,
            Web3BitcoinChainAccount,
            dynamic,
            Web3BitcoinChainIdnetifier,
            Web3StateAddress<BitcoinBaseAddress, Web3BitcoinChainAccount, dynamic,
                Web3BitcoinChainIdnetifier>>,
        RESPONSE,
        REQUEST extends Web3ClientRequest,
        EVENT>
    on Web3StateHandler<
        BitcoinBaseAddress,
        Web3BitcoinChainAccount,
        STATEADDRESS,
        Web3BitcoinChainIdnetifier,
        STATEACCOUNT,
        RESPONSE,
        REQUEST,
        EVENT> {
  @override
  NetworkType get networkType => NetworkType.bitcoinAndForked;

  @override
  List<Web3BitcoinRequestMethods> get methods =>
      Web3BitcoinRequestMethods.values;

  Web3BitcoinSignTransaction toSignPsbtRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3BitcoinRequestMethods method,
      Web3BitcoinChainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      const List<String> keys = ["psbt"];
      final param = params.paramsAsMap(keys: keys, method: method);
      final accounts = Web3ValidatorUtils.parseParams2(() {
        final accountsJson = param["account"] ?? param["accounts"];
        if (accountsJson == null) return null;
        if (accountsJson is List) {
          final accounts = accountsJson
              .map(DefaultStateAddress.parse)
              .cast<DefaultStateAddress>();
          if (accounts.isEmpty) return null;
          return accounts
              .map((e) => state.findAddressStrOrDefault(
                  address: e.address, network: network, networkStr: e.chain))
              .toList();
        }
        final account = DefaultStateAddress.parse(accountsJson);
        if (account == null) return null;
        return [
          state.findAddressStrOrDefault(
              address: account.address,
              networkStr: account.chain,
              network: network)
        ];
      }, error: Web3BitcoinExceptionConstant.invalidPSBT);

      final psbt = Web3ValidatorUtils.parseParams2(
          () => Psbt.deserialize(params.objectAsBytes(
              object: param["psbt"],
              name: "psbt",
              encoding: [StringEncoding.base64])),
          error: Web3BitcoinExceptionConstant.invalidPSBT);
      final inputs = psbt.input.length;
      final output = psbt.output.length;
      if (inputs == 0 || output == 0) {
        throw Web3BitcoinExceptionConstant.invalidPSBT;
      }
      final builder = PsbtBuilder.fromPsbt(psbt);
      bool hasAccount = false;
      for (int i = 0; i < inputs; i++) {
        final psbtInput = builder.psbtInput(i);
        hasAccount |= accounts
            .any((e) => e.address.toScriptPubKey() == psbtInput.scriptPubKey);
      }
      if (!hasAccount) {
        throw Web3BitcoinExceptionConstant.noRelatedInput;
      }
      return Web3BitcoinSignTransaction(accounts: accounts, psbt: psbt);
    });
  }

  Web3BitcoinSendTransaction parseTransferObject(
      {required Map<String, dynamic> param,
      required STATEACCOUNT state,
      required Web3BitcoinRequestMethods method,
      Web3BitcoinChainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      final accounts = Web3ValidatorUtils.parseParams2(() {
        final accountsJson = param["account"] ?? param["accounts"];
        if (accountsJson == null) return null;
        if (accountsJson is List) {
          final accounts = accountsJson
              .map(DefaultStateAddress.parse)
              .cast<DefaultStateAddress>();
          if (accounts.isEmpty) return null;
          return accounts
              .map((e) => state.findAddressStrOrDefault(
                  address: e.address, network: network, networkStr: e.chain))
              .toList();
        }
        final account = DefaultStateAddress.parse(accountsJson);
        if (account == null) return null;
        return [
          state.findAddressStrOrDefault(
              address: account.address,
              networkStr: account.chain,
              network: network)
        ];
      }, error: Web3BitcoinExceptionConstant.invalidPSBT);
      final BitcoinNetworkAddress? recipientAddress =
          Web3ValidatorUtils.parseAddress(
              onParse: (e) {
                return BitcoinNetworkAddress.parse(
                    address: e, network: accounts.first.baseNetwork);
              },
              key: "recipientAddress",
              method: method,
              json: param,
              network: network?.network.value ?? networkType.name);
      final Script? script = Web3ValidatorUtils.praseObject<Script?, String?>(
          onParse: (e) {
            final List<int>? scriptBytes = BytesUtils.tryFromHexString(e);
            final script = Script.deserialize(bytes: scriptBytes!);
            if (!BytesUtils.bytesEqual(scriptBytes, script.toBytes())) {
              throw Web3BitcoinExceptionConstant.parsingOutputScriptFailed(
                  script.toHex());
            }
            return script;
          },
          key: "script",
          method: method,
          json: param);
      if (script == null && recipientAddress == null) {
        throw Web3BitcoinExceptionConstant.invalidTransferOutput;
      }
      if (script != null && recipientAddress != null) {
        throw Web3BitcoinExceptionConstant.invalidTransferOutput;
      }
      Web3ValidatorUtils.parseString(
          key: "amount", method: method, json: param);
      final BigInt amount = Web3ValidatorUtils.parseBigInt(
          key: "amount",
          method: method,
          json: param,
          sign: false,
          error: Web3RequestExceptionConst.failedToParse("amount"));
      return Web3BitcoinSendTransaction(accounts: accounts, outputs: [
        Web3BitcoinSendTransactionOutput(
            value: amount,
            scriptPubKey:
                script ?? recipientAddress!.baseAddress.toScriptPubKey(),
            address: recipientAddress?.address)
      ]);
    });
  }

  Web3WalletResponseMessage toGetAccountAddressesRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3BitcoinRequestMethods method,
      Web3BitcoinChainIdnetifier? network}) {
    const List<String> keys = [];
    final param = params.paramsAsMap(keys: keys, method: method);
    final account = Web3ValidatorUtils.parseParams2(() {
      final addr = param['account'] ?? param['address'];
      final address = DefaultStateAddress.parse(addr);
      if (address == null) return null;
      return state.findAddressStrOrDefault(
          address: address.address,
          network: network,
          networkStr: address.chain);
    },
        error: Web3RequestExceptionConst.invalidAddressArgrument(
            key: 'account', network: networkType.name));
    // final account = Web3ValidatorUtils.parseAddress(
    //     onParse: (e) => network == null
    //         ? state.findAddressStrOrDefault(address: e)
    //         : state.findAddressOrDefault(
    //             address: BitcoinNetworkAddress.parse(
    //                     address: e, network: network.network)
    //                 .baseAddress),
    //     key: "account",
    //     method: method,
    //     json: param,
    //     network: network?.network.value ?? networkType.name);
    return createResponse([
      {
        "address": account.addressStr,
        "script": account.address.toScriptPubKey().toHex(),
        "witnessScript": account.witnessScript,
        "redeemScript": account.redeemScript,
        "type": account.type.value,
        "publicKey": BytesUtils.tryToHexString(account.publicKey)
      }
    ]);
  }

  Web3BitcoinSignMessage toSignMessageRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3BitcoinRequestMethods method,
      Web3BitcoinChainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      const List<String> keys = ["message"];
      final param = params.paramsAsMap(keys: keys, method: method);
      final account = Web3ValidatorUtils.parseParams2(() {
        final addr = param['account'] ?? param['address'];
        final address = DefaultStateAddress.parse(addr);
        if (address == null) return null;
        return state.findAddressStrOrDefault(
            address: address.address,
            network: network,
            networkStr: address.chain);
      },
          error: Web3RequestExceptionConst.invalidAddressArgrument(
              key: 'account', network: networkType.name));
      // final account = Web3ValidatorUtils.parseAddress(
      //     onParse: (e) => network == null
      //         ? state.findAddressStrOrDefault(address: e)
      //         : state.findAddressOrDefault(
      //             address: BitcoinNetworkAddress.parse(
      //                     address: e, network: network.network)
      //                 .baseAddress),
      //     key: "account",
      //     method: method,
      //     json: param,
      //     network: network?.network.value ?? networkType.name);
      if (account.keyIndex.isMultiSig ||
          account.type.isP2sh ||
          account.type == SegwitAddressType.p2wsh) {
        throw Web3BitcoinExceptionConstant.unsuportedSigningMessageAccount(
            account.addressStr);
      }

      final String message = Web3ValidatorUtils.parseString(
          key: "message", method: method, json: param);
      final String? messagePrefix = Web3ValidatorUtils.parseString(
          key: "messagePrefix", method: method, json: param);
      final messageBytes = StringUtils.toBytes(message);
      final content = StringUtils.tryDecode(messageBytes);
      return Web3BitcoinSignMessage(
          account: account,
          message: BytesUtils.toHexString(messageBytes),
          content: content,
          messagePrefix: messagePrefix,
          method: method);
    });
  }

  Web3BitcoinSendTransaction toTransferRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3BitcoinRequestMethods method,
      Web3BitcoinChainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      final List<Web3BitcoinSendTransaction> messages = [];
      const List<String> keys = ["account", "recipientAddress", "amount"];
      final data = params.getParams();
      for (int i = 0; i < data.length; i++) {
        final elem = params.elementAsMap(i, method: method, keys: keys);
        final message = parseTransferObject(
            param: elem, state: state, network: network, method: method);
        messages.add(message);
      }
      return Web3BitcoinSendTransaction(
          accounts: messages.expand((e) => e.accounts).toList(),
          outputs: messages.expand((e) => e.outputs).toList());
    });
  }

  @override
  Future<Web3MessageCore> request(REQUEST message,
      {Web3BitcoinChainIdnetifier? network}) async {
    final method = Web3BitcoinRequestMethods.fromName(message.method);
    final state = await getState();
    if (method == null) {
      throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    switch (method) {
      case Web3BitcoinRequestMethods.requestAccounts:
        return onConnect_(message);
      case Web3BitcoinRequestMethods.sendTransaction:
        return toTransferRequest(
            params: message, state: state, method: method, network: network);
      case Web3BitcoinRequestMethods.signMessage:
        return toSignMessageRequest(
            params: message, state: state, method: method, network: network);
      case Web3BitcoinRequestMethods.signTransaction:
        return toSignPsbtRequest(
            params: message, state: state, method: method, network: network);
      case Web3BitcoinRequestMethods.getAccountAddresses:
        return toGetAccountAddressesRequest(
            params: message, state: state, method: method, network: network);
      default:
        throw Web3RequestExceptionConst.methodDoesNotSupport;
    }
  }
}
