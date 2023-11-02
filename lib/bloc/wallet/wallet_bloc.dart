import 'package:cutfx/model/user/salon_user.dart';
import 'package:cutfx/model/wallet/wallet_statement.dart';
import 'package:cutfx/service/api_service.dart';
import 'package:cutfx/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wallet_event.dart';

part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    scrollController.addListener(() {
      if (scrollController.offset ==
              scrollController.position.maxScrollExtent &&
          !isFetching) {
        add(FetchWalletStatementsEvent());
      }
    });
    on<FetchSalonDataEvent>(
      (event, emit) async {
        SharePref sharePref = await SharePref().init();
        salonUser = sharePref.getSalonUser();
        emit(SalonDataFoundState());
        walletStatements = [];
        add(FetchWalletStatementsEvent());
      },
    );
    on<FetchWalletStatementsEvent>(
      (event, emit) async {
        WalletStatement walletStatement = await ApiService()
            .fetchSalonWalletStatement(walletStatements.length);
        walletStatements.addAll(walletStatement.data ?? []);
        emit(WalletStatementDataFoundState());
      },
    );
    add(FetchSalonDataEvent());
  }

  ScrollController scrollController = ScrollController();
  SalonUser? salonUser;
  bool isFetching = false;
  int count = 0;
  List<WalletStatementData> walletStatements = [];
}
