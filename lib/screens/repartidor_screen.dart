import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RepartidorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Repartidor'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Text('Panel de Repartidor - En construcción'),
      ),
    );
  }
}