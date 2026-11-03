import 'package:flutter/widgets.dart';

bool isRtl(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl;
double dirSign(BuildContext context) => isRtl(context) ? -1 : 1;

class MirrorOnRtl extends StatelessWidget {
  final Widget child;
  const MirrorOnRtl({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      isRtl(context) ? Transform.flip(flipX: true, child: child) : child;
}
