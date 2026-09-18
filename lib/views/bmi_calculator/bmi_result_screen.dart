import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/app_background.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class BMIResultScreen extends StatelessWidget {
  const BMIResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BMIRecord record =
        Get.arguments as BMIRecord? ??
        BMIRecord(
          id: '0',
          bmiValue: 22.4,
          weightKg: 70.0,
          heightCm: 175.0,
          age: 25,
          gender: 'Male',
          category: BMICategory.normal,
          date: DateTime.now(),
        );

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'BMI Result',
          trailing: Builder(
            builder: (btnContext) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _shareBMIResult(btnContext, record);
              },
              child: Container(
                width: 34.w,
                height: 34.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.share_outlined,
                    size: 17.sp,
                    color: const Color(0xFF1E2D2F),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 16.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Gauge & BMI Result Card
                CustomCard(
                  borderRadius: 22.r,
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
                  child: Stack(
                    children: [
                      // Top Right Heart Icon Badge
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: Image.asset(
                          AppAssets.hearticon,
                          height: 34.h,
                          width: 34.w,
                        ),
                      ),

                      Column(
                        children: [
                          // Gauge Widget
                          BMIGaugeWidget(
                            bmiValue: record.bmiValue,
                            size: 160.w,
                            showLabels: true,
                          ),
                          SizedBox(height: 4.h),

                          // BMI Numeric Value
                          Text(
                            record.bmiValue.toStringAsFixed(1),
                            style: TextStyle(
                              color: const Color(0xFF33D2AB),
                              fontSize: 28,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Your BMI',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          // Status Pill
                          Container(
                            width: 78.w,
                            height: 24.h,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF33D2AB)
                                  .withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                record.category.label,
                                style: TextStyle(
                                  color: const Color(0xFF07A981),
                                  fontSize: 11.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Status Feedback Message Card
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 42.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F9F7),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.shieldicon,
                                  width: 18.w,
                                  height: 18.w,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    record.category.feedbackMessage,
                                    style: TextStyle(
                                      color: const Color(0xFF1E2D2F),
                                      fontSize: 11.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Your Details Card
                CustomCard(
                  borderRadius: 20.r,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Details',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailColumn(
                            imageAsset: AppAssets.weighticon,
                            value: '${record.weightKg.toStringAsFixed(1)} kg',
                            label: 'Weight',
                            showUnderline: true,
                          ),
                          _buildDetailDivider(),
                          _buildDetailColumn(
                            imageAsset: AppAssets.heighticon,
                            value: '${record.heightCm.toStringAsFixed(0)} cm',
                            label: 'Height',
                          ),
                          _buildDetailDivider(),
                          _buildDetailColumn(
                            imageAsset: AppAssets.ageicon,
                            value: '${record.age} Yrs',
                            label: 'Age',
                          ),
                          _buildDetailDivider(),
                          _buildDetailColumn(
                            imageAsset: AppAssets.gendericon,
                            value: record.gender,
                            label: 'Gender',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Health Advice Card
                CustomCard(
                  borderRadius: 20.r,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Advice',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAdviceBullet(
                                  'Eat a balanced diet rich in nutrients.',
                                ),
                                SizedBox(height: 4.h),
                                _buildAdviceBullet(
                                  'Stay active for at least 30 minutes daily.',
                                ),
                                SizedBox(height: 4.h),
                                _buildAdviceBullet(
                                  'Drink plenty of water and get enough sleep.',
                                ),
                                SizedBox(height: 4.h),
                                _buildAdviceBullet(
                                  'Track your progress regularly.',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Image.asset(
                            AppAssets.bmiHearticon,
                            height: 64.h,
                            width: 64.w,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Recalculate Button
                CustomGradientButton(
                  text: 'Recalculate',
                  height: 52.h,
                  leadingIcon: Image.asset(
                    AppAssets.calcilatorIcon,
                    width: 16.w,
                    height: 16.w,
                  ),
                  backgroundImage: AppAssets.btnRectangle,
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Get.back();
                    } else {
                      Get.offNamed(AppRoutes.bmiCalculator);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shares the BMI result using the native share dialog
  void _shareBMIResult(BuildContext context, BMIRecord record) async {
    final shareText =
        '''
BMI Result
━━━━━━━━━━━━━━━━
• BMI: ${record.bmiValue.toStringAsFixed(1)} (${record.category.label})
• Weight: ${record.weightKg.toStringAsFixed(1)} kg
• Height: ${record.heightCm.toStringAsFixed(0)} cm
• Age: ${record.age} years
• Gender: ${record.gender}
━━━━━━━━━━━━━━━━
${record.category.feedbackMessage}
''';

    // Calculate bounding box for iPad/macOS popover presentation
    Rect? origin;
    try {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        origin = box.localToGlobal(Offset.zero) & box.size;
      }
    } catch (_) {}

    origin ??= Rect.fromLTWH(
      0,
      0,
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height / 2,
    );

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'My BMI Result - ${record.bmiValue.toStringAsFixed(1)}',
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('SharePlus error: $e');
      {
        Get.snackbar(
          'Share Error',
          'Could not open share dialog: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Widget _buildDetailColumn({
    required String imageAsset,
    required String value,
    required String label,
    bool showUnderline = false,
  }) {
    return Column(
      children: [
        Image.asset(imageAsset, width: 34.w, height: 34.w),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1E2D2F),
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailDivider() {
    return Container(height: 32.h, width: 1.w, color: const Color(0xFFF1F5F9));
  }

  Widget _buildAdviceBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Image.asset(AppAssets.preDown, height: 11.h, width: 11.w),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF647E80),
              fontSize: 10.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
