import 'package:flutter/material.dart';
import 'package:pfe_flutter/shared/app_colors.dart';

class HeaderBand extends StatelessWidget {
  final double height;
  const HeaderBand({this.height = 220, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
    );
  }
}