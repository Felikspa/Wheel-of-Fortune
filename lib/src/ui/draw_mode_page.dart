import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/models.dart';
import '../state/app_controller.dart';
import 'modes/card_mode_page.dart';
import 'modes/coin_mode_page.dart';
import 'modes/dice_mode_page.dart';
import 'wheel_page.dart';

class DrawModePage extends StatelessWidget {
  const DrawModePage({super.key, required this.onOpenManage});

  final VoidCallback onOpenManage;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        return switch (controller.selectedDisplayMode) {
          DrawDisplayMode.wheel => WheelPage(onOpenManage: onOpenManage),
          DrawDisplayMode.coin => CoinModePage(onOpenManage: onOpenManage),
          DrawDisplayMode.dice => DiceModePage(onOpenManage: onOpenManage),
          DrawDisplayMode.card => CardModePage(onOpenManage: onOpenManage),
        };
      },
    );
  }
}
