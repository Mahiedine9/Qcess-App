import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class BottomNavBarWidget extends StatelessWidget{
  final int currentIndex;
  final Function(int) onTap;


  const BottomNavBarWidget({super.key,required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context){
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.cardBackground,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
    );
  }



}