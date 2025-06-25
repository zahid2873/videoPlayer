import 'package:flutter/material.dart';

typedef HeroBuilder = Widget Function(BuildContext context);

class HeroWidget extends StatelessWidget {
  HeroWidget({
    Key? key,
    required this.heroBuilder,
    required this.heroTag,
    this.width = 100,
    this.onTap,
  }) : super(key: key);
  final HeroBuilder heroBuilder;
  final Object heroTag;
  final double width;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
//    debugPrint("aaaaaa $he")
    return SizedBox(
      width: width,
      child: Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: () {}, child: heroBuilder(context)),
        ),
        flightShuttleBuilder:
            (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              final Hero hero = flightDirection == HeroFlightDirection.push
                  ? fromHeroContext.widget as Hero
                  : toHeroContext.widget as Hero;

              return FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
                child: RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut))
                      .animate(animation),
                  child: hero.child,
                ),
              );
            },
      ),
    );
  }
}
