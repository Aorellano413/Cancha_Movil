// lib/widgets/sede_card.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/sede_model.dart';

class SedeCard extends StatelessWidget {
  final SedeModel sede;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const SedeCard({
    super.key,
    required this.sede,
    required this.onEditar,
    required this.onEliminar,
  });

  Widget _buildImage() {
   
    if (sede.imagePath.startsWith('http://') || sede.imagePath.startsWith('https://')) {
      return Image.network(
        sede.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.stadium, size: 64, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
   
    if (!sede.imagePath.startsWith('/') && !sede.imagePath.contains(':\\')) {
      return Image.asset(
        sede.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.stadium, size: 64, color: Colors.grey),
          );
        },
      );
    }
    
    if (!kIsWeb) {
      return Image.file(
        File(sede.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.stadium, size: 64, color: Colors.grey),
          );
        },
      );
    }
    
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.stadium, size: 64, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
           
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  const Color(0xFF0083B0).withOpacity(0.35),
                  BlendMode.darken,
                ),
                child: _buildImage(),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sede.tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                    ),
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                    ),
                    onPressed: onEliminar,
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                sede.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}