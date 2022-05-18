/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiki_style/tiki_style.dart';

import '../../account/account_model.dart';
import '../../account/account_model_provider.dart';
import '../screen_service.dart';

class ScreenViewLayoutAccounts extends StatelessWidget {
   const ScreenViewLayoutAccounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenService service = Provider.of<ScreenService>(context);
    AccountModel? account = service.model.account;
    return Column(children: [
      account == null || account.provider == AccountModelProvider.google
          ? Container(
              margin: EdgeInsets.only(top: SizeProvider.instance.height(31)),
              child: service.intgContext.widget(
                  account: account,
                  provider: AccountModelProvider.google,
                  onLink: (account) => service.controller.saveAccount(account),
                  onUnlink: (email) => service.controller
                      .removeAccount(AccountModelProvider.google, email)))
          : Container(),
      account == null || account.provider == AccountModelProvider.microsoft
          ? Container(
              margin: EdgeInsets.only(top: SizeProvider.instance.height(15)),
              child: service.intgContext.widget(
                  account: account,
                  provider: AccountModelProvider.microsoft,
                  onLink: (account) => service.controller.saveAccount(account),
                  onUnlink: (email) => service.controller
                      .removeAccount(AccountModelProvider.microsoft, email)))
          : Container(),
    ]);
  }
}
