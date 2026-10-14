import 'package:get/get.dart';

/// Selected bottom-nav tab: 0 Home, 1 Profile, 2 Weight, 3 History.
/// Lets other screens (e.g. Home's feature cards) switch tabs.
final RxInt mainTabIndex = 0.obs;

const int kProfileTab = 1;
