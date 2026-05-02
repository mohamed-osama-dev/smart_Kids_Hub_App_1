import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../../core/network/secure_storage_service.dart';
import '../../data/repositories/scale_reading_repository.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';
import '../../../../utils/app_styles.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  bool _isBluetoothOn = false;
  bool _isScanning = false;
  int _secondsLeft = 20;
  String _statusText = 'يجب تفعيل البلوتوث للاتصال بجهاز القياس';
  double _currentWeight = 0.0;
  String _currentUnit = 'kg';
  bool _isSending = false;

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _sendWeight() async {
    if (_isSending || _currentWeight <= 0) return;

    setState(() {
      _isSending = true;
      _statusText = 'جاري إرسال الوزن...';
    });

    try {
      final childId = await SecureStorageService.getChildId();
      if (childId == null) {
        if (mounted) {
          setState(() {
            _isSending = false;
            _statusText = 'بيانات الطفل غير متوفرة. يرجى إضافة بيانات الطفل أولاً.';
          });
        }
        return;
      }

      // _currentWeight is always in kg (from BLE)
      final repo = ScaleReadingRepository();
      final success = await repo.updateWeight(
        childId: childId,
        weight: _currentWeight,
      );

      if (mounted) {
        setState(() {
          _isSending = false;
          _statusText = success
              ? 'تم إرسال الوزن بنجاح! ✅'
              : 'فشل الإرسال. يرجى المحاولة مرة أخرى.';
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تسجيل الوزن بنجاح! جاري الانتقال لتخطيط الوجبات...',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to meals tab after short delay
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.home, arguments: 1);
            }
          });
        }
      }
    } catch (e) {
      print('❌ Send weight error: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
          _statusText = 'حدث خطأ أثناء الإرسال. تحقق من الاتصال بالإنترنت.';
        });
      }
    }
  }

  Future<void> _requestPermissionsAndScan() async {
    if (_isScanning) return;

    if (Platform.isAndroid) {
      try {
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();
      } catch (_) {}
    }

    if (await FlutterBluePlus.isSupported == false) {
      setState(() => _statusText = 'البلوتوث غير مدعوم في هذا الجهاز');
      return;
    }

    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        setState(() => _statusText = 'يرجى تفعيل البلوتوث من الإعدادات');
        return;
      }
    }

    setState(() {
      _isBluetoothOn = true;
      _isScanning = true;
      _currentWeight = 0.0;
      _currentUnit = 'kg';
      _secondsLeft = 20;
      _statusText = 'جاري البحث... يرجى ثبات الطفل لمدة $_secondsLeft ثانية';
    });

    List<double> recordedWeights = [];

    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        String deviceName = r.device.platformName.toLowerCase();
        var mfgData = r.advertisementData.manufacturerData;

        if (deviceName == 'da' ||
            mfgData.containsKey(480) ||
            mfgData.containsKey(208) ||
            mfgData.keys.any((k) => k & 0xFF == 0xE0 || k & 0xFF == 0xD0)){
          print("=== 🔵 BLE Packet Received ===");
          print("Name: $deviceName");
          print("Mfg Data Keys: ${mfgData.keys.toList()}");

          mfgData.forEach((key, value) {
            print("  Key: $key (0x${key.toRadixString(16)}) → Payload: $value");
          });

          double weight = 0.0;

          if (mfgData.isNotEmpty) {
            int companyId = mfgData.keys.first;
            List<int> payload = mfgData.values.first;

            int lowByte = companyId & 0xFF;

            if (lowByte == 0xD0) continue;

            int weightHighByte = companyId >> 8;

            if (payload.isNotEmpty) {
              int weightLowByte = payload[0];
              int rawValue = weightHighByte * 256 + weightLowByte;
              weight = rawValue / 100.0;

              print(
                "Company ID: $companyId (0x${companyId.toRadixString(16)})",
              );
              print("High Byte: $weightHighByte, Low Byte: $weightLowByte");
              print("Raw Value: $rawValue");
              print(" Weight: $weight kg");
            }
          }

          if (weight > 0 && weight < 500) {
            recordedWeights.add(weight);
          }
          print("==============================");
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 20));

    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isScanning) break;

      setState(() {
        _secondsLeft--;
        _statusText = 'جاري التأكد من ثبات الوزن... $_secondsLeft ثانية';
      });
    }

    await FlutterBluePlus.stopScan();
    subscription.cancel();

    double finalComputedWeight = 0.0;
    if (recordedWeights.isNotEmpty) {
      Map<double, int> freq = {};
      for (var w in recordedWeights) {
        freq[w] = (freq[w] ?? 0) + 1;
      }
      int maxCount = 0;
      freq.forEach((w, count) {
        if (count > maxCount) {
          maxCount = count;
          finalComputedWeight = w;
        }
      });
    }

    if (mounted && _isScanning) {
      setState(() {
        _isScanning = false;
        if (finalComputedWeight > 0) {
          _currentWeight = finalComputedWeight;
          _statusText = 'تم قياس الوزن بنجاح!';
        } else if (_isBluetoothOn) {
          _statusText = 'لم يتم التقاط وزن ثابت. يرجى إعادة المحاولة.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!_isScanning) {
                          setState(() {
                            _currentWeight = 0.0;
                            _statusText =
                                'يجب تفعيل البلوتوث للاتصال بجهاز القياس';
                          });
                          if (_isBluetoothOn) {
                            _requestPermissionsAndScan();
                          }
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isScanning
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: _isScanning
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white,
                        ),
                      ),
                    ),
                    Text('القياس', style: AppStyles.bold20White),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bluetooth,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isScanning ? 'البحث جاري...' : 'يرجى تشغيل البلوتوث',
                        style: AppStyles.bold14White,
                      ),
                      const Spacer(),
                      Switch(
                        value: _isBluetoothOn,
                        onChanged: (value) {
                          if (value) {
                            _requestPermissionsAndScan();
                          } else {
                            FlutterBluePlus.stopScan();
                            setState(() {
                              _isBluetoothOn = false;
                              _isScanning = false;
                              _statusText = 'تم إيقاف البلوتوث';
                            });
                          }
                        },
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.success,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.5),
                        trackOutlineColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: _currentWeight > 0
                        ? AppColors.success
                        : Colors.transparent,
                    width: 4,
                  ),
                  boxShadow: _currentWeight > 0
                      ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: _currentWeight > 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentUnit == 'kg'
                                  ? _currentWeight.toStringAsFixed(1)
                                  : (_currentWeight * 2.20462).toStringAsFixed(
                                      1,
                                    ),
                              style: AppStyles.bold24White.copyWith(
                                fontSize: 64,
                              ),
                            ),
                            Text(
                              _currentUnit == 'kg' ? 'كجم' : 'رطل',
                              style: AppStyles.bold18White,
                            ),
                          ],
                        )
                      : _isScanning
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          Icons.monitor_weight_outlined,
                          size: 100,
                          color: Colors.white.withOpacity(0.9),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Unit toggle button (only show when weight is available)
              if (_currentWeight > 0)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentUnit = _currentUnit == 'kg' ? 'lb' : 'kg';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentUnit == 'kg'
                              ? 'التحويل إلى رطل (lb)'
                              : 'التحويل إلى كيلو (kg)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Text(
                _currentWeight > 0
                    ? (_currentUnit == 'kg'
                          ? 'الوزن بالكيلوجرام (kg)'
                          : 'الوزن بالرطل (lb)')
                    : _isBluetoothOn
                    ? 'حالة البلوتوث'
                    : 'يرجى تشغيل البلوتوث',
                style: AppStyles.bold18White,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: AppStyles.regular14White.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),

              // Helper text when weight is ready
              if (_currentWeight > 0 && !_isScanning && !_isSending)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        'اضغط إرسال وتعالى نعمل خطة الوجبات! ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '🍽️',
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_currentWeight > 0 && !_isScanning && !_isSending)
                const SizedBox(height: 12),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: (_isScanning || _isSending)
                        ? null
                        : (_currentWeight > 0
                              ? _sendWeight
                              : _requestPermissionsAndScan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    ),
                    icon: (_isScanning || _isSending)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _currentWeight > 0
                                ? Icons.cloud_upload
                                : Icons.bluetooth,
                          ),
                    label: Text(
                      _isScanning
                          ? 'جاري حساب الوزن بدقة...'
                          : _isSending
                          ? 'جاري الإرسال...'
                          : (_currentWeight > 0
                                ? 'إرسال'
                                : 'تشغيل البلوتوث وبدء القياس'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
