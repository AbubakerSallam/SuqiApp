import 'package:flutter/material.dart';

import '../constants/colors.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, required this.onpressed});
  final Function? onpressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/sad.png',
            width: 120,
          ),
          const SizedBox(height: 10),
          const Text(
            'لا إنترنت',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(15),
            ),
            icon: const Icon(
              Icons.replay_outlined,
              color: Colors.white,
            ),
            onPressed: () => onpressed!(),
            label: const Text(
              '',
              style: TextStyle(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
