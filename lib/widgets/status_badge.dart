// lib/widgets/status_badge.dart (Flutter)

import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String estado;
  
  const StatusBadge({
    Key? key,
    required this.estado,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Configurar apariencia según el estado
    final Map<String, dynamic> config = _getStatusConfig(estado);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            color: config['textColor'],
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            config['label'],
            style: TextStyle(
              color: config['textColor'],
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  
  // Obtener configuración según el estado
  Map<String, dynamic> _getStatusConfig(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return {
          'backgroundColor': Colors.orange.withOpacity(0.2),
          'textColor': Colors.orange[800],
          'label': 'Pendiente',
          'icon': Icons.hourglass_empty,
        };
      case 'en camino':
        return {
          'backgroundColor': Colors.blue.withOpacity(0.2),
          'textColor': Colors.blue[800],
          'label': 'En Camino',
          'icon': Icons.directions_bike,
        };
      case 'entregado':
        return {
          'backgroundColor': Colors.green.withOpacity(0.2),
          'textColor': Colors.green[800],
          'label': 'Entregado',
          'icon': Icons.check_circle,
        };
      case 'cancelado':
        return {
          'backgroundColor': Colors.red.withOpacity(0.2),
          'textColor': Colors.red[800],
          'label': 'Cancelado',
          'icon': Icons.cancel,
        };
      default:
        return {
          'backgroundColor': Colors.grey.withOpacity(0.2),
          'textColor': Colors.grey[800],
          'label': estado,
          'icon': Icons.help_outline,
        };
    }
  }
}