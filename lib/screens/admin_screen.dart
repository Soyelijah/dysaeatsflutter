import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administrador'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Text('Panel de Administrador - En construcción'),
      ),
    );
  }
}