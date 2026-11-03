import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps the app in debug mode with a floating draggable button to switch
/// between simulated devices on the fly without needing DevTools open.
/// In release mode, this widget is completely inert and renders only [child].
///
/// It is meant for `MaterialApp.builder`, which sits above the app's
/// Navigator, so the device picker sheet is opened through [navigatorKey].
class DevicePreviewControl extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const DevicePreviewControl({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<DevicePreviewControl> createState() => _DevicePreviewControlState();
}

class _DevicePreviewControlState extends State<DevicePreviewControl> {
  // Distance from the right and bottom edges. Null until dragged: the button
  // starts halfway up the right edge, clear of bottom CTAs and the nav bar.
  Offset? _buttonPosition;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return widget.child;
    }

    final controller = DevicePreview.maybeController;
    if (controller == null) {
      return widget.child;
    }

    final position =
        _buttonPosition ?? Offset(8, MediaQuery.sizeOf(context).height * 0.5);

    return Stack(
      children: [
        widget.child,
        Positioned(
          right: position.dx,
          bottom: position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              final size = MediaQuery.sizeOf(context);
              setState(() {
                _buttonPosition = Offset(
                  (position.dx - details.delta.dx).clamp(
                    8.0,
                    size.width - 56.0,
                  ),
                  (position.dy - details.delta.dy).clamp(
                    24.0,
                    size.height - 56.0,
                  ),
                );
              });
            },
            child: Material(
              color: Colors.transparent,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final isSimulating = controller.simulation != null;
                  // Translucent so it doesn't hide the screen being checked.
                  return Opacity(
                    opacity: 0.6,
                    child: FloatingActionButton.small(
                      heroTag: 'device_preview_floating_button',
                      backgroundColor: isSimulating
                          ? const Color(0xFF00BD8E)
                          : const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      // No tooltip: there is no Overlay above MaterialApp.builder.
                      onPressed: () => _showPicker(controller),
                      child: Icon(
                        isSimulating
                            ? Icons.devices
                            : Icons.devices_other_outlined,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(DevicePreviewController controller) {
    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) return;
    showModalBottomSheet(
      context: navigatorContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _DevicePreviewSheet(controller: controller);
      },
    );
  }
}

class _DevicePreviewSheet extends StatefulWidget {
  final DevicePreviewController controller;

  const _DevicePreviewSheet({required this.controller});

  @override
  State<_DevicePreviewSheet> createState() => _DevicePreviewSheetState();
}

class _DevicePreviewSheetState extends State<_DevicePreviewSheet> {
  static const List<DevicePreset> _popularPresets = [
    DevicePresets.iPhone16,
    DevicePresets.iPhone16ProMax,
    DevicePresets.iPhoneSe3,
    DevicePresets.pixel9,
    DevicePresets.galaxyS24,
    DevicePresets.iPad10,
    DevicePresets.iPadMini,
    DevicePresets.iPadAir11M2,
    DevicePresets.iPadPro11M4,
    DevicePresets.iPadPro13M4,
    DevicePresets.smallDesktopWindow,
  ];

  @override
  Widget build(BuildContext context) {
    final simulation = widget.controller.simulation;
    final isSimulating = simulation != null;
    final orientation = simulation?.orientation ?? Orientation.portrait;
    final isLandscape = orientation == Orientation.landscape;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Device Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                if (isSimulating)
                  TextButton.icon(
                    onPressed: () async {
                      await widget.controller.reset();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset Native'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick Toolbar: Orientation, Frame, Keyboard
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: Icon(
                    isLandscape
                        ? Icons.stay_current_landscape
                        : Icons.stay_current_portrait,
                    size: 16,
                  ),
                  label: Text(isLandscape ? 'Landscape' : 'Portrait'),
                  onPressed: isSimulating
                      ? () {
                          widget.controller.setOrientation(
                            isLandscape
                                ? Orientation.portrait
                                : Orientation.landscape,
                          );
                          setState(() {});
                        }
                      : null,
                ),
                ActionChip(
                  avatar: Icon(
                    simulation?.showSystemUi == true
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 16,
                  ),
                  label: Text(
                    simulation?.showSystemUi == true
                        ? 'System UI: On'
                        : 'System UI: Off',
                  ),
                  onPressed: isSimulating
                      ? () {
                          final current = simulation.showSystemUi;
                          widget.controller.update(
                            (s) => s.copyWith(showSystemUi: !current),
                          );
                          setState(() {});
                        }
                      : null,
                ),
                ActionChip(
                  avatar: const Icon(Icons.brightness_medium, size: 16),
                  label: Text(
                    simulation?.platformBrightness == Brightness.dark
                        ? 'Dark'
                        : 'Light',
                  ),
                  onPressed: isSimulating
                      ? () {
                          final isDark =
                              simulation.platformBrightness == Brightness.dark;
                          widget.controller.update(
                            (s) => s.copyWith(
                              platformBrightness: isDark
                                  ? Brightness.light
                                  : Brightness.dark,
                            ),
                          );
                          setState(() {});
                        }
                      : null,
                ),
              ],
            ),
            const Divider(height: 20),

            const Text(
              'Select Device Preset',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: _popularPresets.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final preset = _popularPresets[index];
                  final isSelected = simulation?.presetId == preset.id;

                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(
                      _iconForKind(preset.kind),
                      color: isSelected
                          ? const Color(0xFF00BD8E)
                          : const Color(0xFF6B7280),
                    ),
                    title: Text(
                      preset.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF00BD8E)
                            : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      '${preset.portraitSize.width.toInt()}x${preset.portraitSize.height.toInt()} (${preset.platform.name})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00BD8E),
                            size: 20,
                          )
                        : null,
                    onTap: () async {
                      await widget.controller.applyPreset(preset);
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForKind(DeviceKind kind) {
    switch (kind) {
      case DeviceKind.tablet:
        return Icons.tablet_mac;
      case DeviceKind.desktop:
        return Icons.desktop_windows;
      case DeviceKind.phone:
      default:
        return Icons.phone_iphone;
    }
  }
}
