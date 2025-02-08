// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class KListTile extends StatelessWidget {
  const KListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTapHandler,
    this.showSubtitle = true,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final Function? onTapHandler;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTapHandler!(),
      title: Text(
        textDirection: TextDirection.rtl,
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: showSubtitle ? Text(subtitle!) : null,
      trailing: Icon(
        icon,
        color: primaryColor,
      ),
    );
  }
}
