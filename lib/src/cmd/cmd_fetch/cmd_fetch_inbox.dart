import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../../account/account_model.dart';
import '../../account/account_service.dart';
import '../../email/msg/email_msg_model.dart';
import '../../fetch/fetch_model_part.dart';
import '../../fetch/fetch_model_status.dart';
import '../../fetch/fetch_service.dart';
import '../../intg/intg_context_email.dart';
import '../cmd_mgr/cmd_mgr_cmd.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import 'cmd_fetch_inbox_notification.dart';

class CmdFetchInbox extends CmdMgrCmd{
  final Logger _log = Logger('FetchInboxCommand');
  final AccountModel _account;
  final DateTime? _since;
  String? _page;
  final IntgContextEmail _intgContextEmail;
  final FetchService _fetchService;

  Amplitude? _amplitude;

  CmdFetchInbox(
      FetchService this._fetchService,
      AccountModel this._account,
      DateTime? this._since,
      String? this._page,
      AccountService accountService,
      Httpp? httpp,
      Amplitude? amplitude
    ) :
      _amplitude = amplitude,
      _intgContextEmail = IntgContextEmail(accountService, httpp: httpp);

  Future<void> index() async {

    int currentAmount = (await _fetchService.getStatus(_account))!.amount_fetched!;
    _log.info("PRE INDEX AMOUNT...: ${currentAmount}");

    await _intgContextEmail.countInbox(
        account: _account,
        since: _since,
        onResult: (amount) {
          _fetchService.saveStatus(_account, total: amount);
          _log.fine('Saved status as ${amount} for ${_account.email}');
        },
        onFinish: () => {});

    _log.fine('email index ${_account.email} on ${DateTime.now().toIso8601String()}');
    _intgContextEmail.getInbox(
        account: _account,
        since: _since,
        onResult: _saveParts,
        onFinish: _onFinish
    );
  }

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onPause() async {
    if(_page != null) {
      await _fetchService.savePage(_page!, _account);
    }
  }

  @override
  Future<void> onResume() async {
    _page = await _fetchService.getPage(_account);
    index();
  }

  @override
  Future<void> onStart() async{
    index();
  }

  @override
  Future<void> onStop() async {
    if(_page != null) {
      await _fetchService.savePage(_page!, _account);
    }
  }

  static String generateId(AccountModel account) {
    int id = account.accountId!;
    String prov = account.emailApi!.value;
    return "CmdFetchInbox.$prov.$id";
  }

  Future<void> _saveParts(List<EmailMsgModel> messages, {String? page}) async {

      List<FetchModelPart<EmailMsgModel>> parts = messages.map((message) =>
          FetchModelPart(
              extId: message.extMessageId,
              account: _account,
              api: _account.emailApi,
              obj: message))
          .toList();
      await _fetchService.saveParts(parts, _account);
      _page = page;
      if(_page !=null) await _fetchService.savePage(_page!, _account);
      if(_amplitude != null){
        _amplitude!.logEvent("EMAILS_INDEXED", eventProperties: {
          "count" : parts.length
        });
        _amplitude!.logEvent("EMAIL_MSG_INDEXED");
      }

      notify(CmdFetchInboxNotification(_account, messages));
      _log.fine('indexed ${messages.length} messages');

      FetchModelStatus<EmailMsgModel>? status = await _fetchService.getStatus(_account);
      int currentAmount = status?.amount_indexed == null ? 0 : status!.amount_indexed!;
      int totalAmount = status?.amount_indexed == null ? 0 : status!.total_to_fetch!;

      _log.info("CURRENT AMOUNT INDEXED SAVED: ${currentAmount}/${totalAmount}");

      _log.info("Adding ${messages.length}");

      _fetchService.saveStatus(_account, amount_indexed: (currentAmount + messages.length));
  }

  Future<void> _onFinish() async {
      _log.fine('finished email index for ${_account.email}.');

      if(_page !=null) await _fetchService.savePage(_page!, _account);
      notify(CmdMgrCmdNotifFinish(id));
  }
}