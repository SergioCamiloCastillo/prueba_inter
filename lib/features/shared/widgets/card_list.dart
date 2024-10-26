import 'package:flutter/material.dart';
import 'dart:io';

import 'package:prueba_inter/config/helpers/functions.dart';

class CardList extends StatelessWidget {
  final String? photo;
  final String title;
  final String subTitle;
  final Color colorCard;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final IconData icon;

  const CardList({
    super.key,
    this.photo,
    required this.title,
    required this.subTitle,
    required this.onDelete,
    required this.colorCard,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorCard.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: photo != null && photo!.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: FileImage(File(photo!)),
                )
              : CircleAvatar(
                  backgroundColor: colorCard.withOpacity(0.2),
                  child: Icon(icon, color: colorCard),
                ),
          title: Text(capitalizeFirstLetter(title)),
          subtitle: Text(capitalizeFirstLetter(subTitle)),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
