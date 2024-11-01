import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/responsive.dart';

class MyPositiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const MyPositiveButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
    );
  }
}

class MyNegativeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const MyNegativeButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: SizeConfig.width(30), // Adjust this value as needed
        height: SizeConfig.height(6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(SizeConfig.width(5)),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: SizeConfig.width(0.3),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: SizeConfig.text(4),
            ),
          ),
        ),
      ),
    );
  }
}
