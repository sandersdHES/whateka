import 'package:flutter/material.dart';
import '../main.dart';

class FunLoadingWidget extends StatelessWidget {
  final String message;
  const FunLoadingWidget({
    super.key,
    this.message = "Nous concoctons votre sélection...",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _BouncingIcon(
                  icon: Icons.map,
                  color: AppColors.cyan,
                  delayMs: 0,
                ),
                const SizedBox(width: 20),
                const _BouncingIcon(
                  icon: Icons.favorite,
                  color: AppColors.orange,
                  delayMs: 200,
                ),
                const SizedBox(width: 20),
                const _BouncingIcon(
                  icon: Icons.explore,
                  color: AppColors.green,
                  delayMs: 400,
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int delayMs;

  const _BouncingIcon({
    required this.icon,
    required this.color,
    required this.delayMs,
  });

  @override
  State<_BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<_BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _localController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _localController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _localController, curve: Curves.easeOut),
    );

    _startLoop();
  }

  void _startLoop() async {
    await Future.delayed(Duration(milliseconds: widget.delayMs));
    if (mounted) {
      _runAnimation();
    }
  }

  void _runAnimation() async {
    if (!mounted) return;
    await _localController.forward();
    if (!mounted) return;
    await _localController.reverse();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    _runAnimation();
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _localController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          size: 32,
          color: widget.color,
        ),
      ),
    );
  }
}
