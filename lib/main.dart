import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/services/hive_service.dart';
import 'core/services/session_service.dart';
import 'features/auth/domain/models/parent.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/children_cubit.dart';
import 'features/auth/presentation/screens/screens.dart';
import 'features/meals/data/data.dart';
import 'features/meals/domain/domain.dart';
import 'features/meals/presentation/cubit/cubit.dart';
import 'features/meals/presentation/screens/screens.dart';
import 'features/settings/presentation/screens/coming_soon_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/growth/presentation/screens/screens.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';
import 'utils/app_styles.dart';
import 'utils/app_theme.dart';
import 'utils/splash_screen.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup meals feature dependencies
    final dataSource = ApiMealRemoteDataSource();
    final repository = MealRepositoryImpl(remoteDataSource: dataSource);
    final getAiMealSuggestions = GetAiMealSuggestions(repository);
    final getMealsByDate = GetMealsByDate(repository);
    final toggleFavoriteMeal = ToggleFavoriteMeal(repository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthCubit()),
        ChangeNotifierProvider(create: (_) => ChildrenCubit()),
        ChangeNotifierProvider(
          create: (_) => MealsCubit(
            getAiMealSuggestions: getAiMealSuggestions,
            getMealsByDate: getMealsByDate,
            toggleFavoriteMeal: toggleFavoriteMeal,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SmartKids Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.home: (context) => const HomePage(),
          AppRoutes.measurement: (context) => const MeasurementScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
          AppRoutes.notifications: (context) =>
              const ComingSoonScreen(title: 'الإشعارات'),
          AppRoutes.privacy: (context) =>
              const ComingSoonScreen(title: 'سياسة الخصوصية'),
          AppRoutes.profile: (context) =>
              const ComingSoonScreen(title: 'معلومات الحساب'),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.parentInfo: (context) => const ParentInfoScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.setNewPassword: (context) => const SetNewPasswordScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.otpVerification:
              final args = settings.arguments;
              if (args is OTPVerificationArgs) {
                return MaterialPageRoute(
                  builder: (context) => OTPVerificationScreen(
                    parent: args.parent,
                    phoneNumber: args.phoneNumber,
                    isPasswordReset: args.isPasswordReset,
                  ),
                );
              }
              if (args is Parent) {
                return MaterialPageRoute(
                  builder: (context) => OTPVerificationScreen(
                    parent: args,
                    phoneNumber: args.phone,
                  ),
                );
              }
              break;
            case AppRoutes.childInfo:
              final parent = settings.arguments as Parent?;
              return MaterialPageRoute(
                builder: (context) => ChildInfoScreen(parent: parent),
              );
          }
          return null;
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _didReadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didReadArgs) {
      _didReadArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int && args >= 0 && args < 3) {
        _currentIndex = args;
      }
    }
  }

  final List<Widget> _screens = const [
    _HomeTab(),
    MealsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'الوجبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const String _addChildMenuValue = 'add-new-child';
  StreamSubscription<void>? _logoutSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChildrenCubit>().loadChildren();
    });
    _logoutSub = DioClient.logoutEvents.listen((_) async {
      await SessionService.clearSession();
    });
  }

  @override
  void dispose() {
    _logoutSub?.cancel();
    super.dispose();
  }

  void _handleChildMenuSelection(String value) {
    if (value == _addChildMenuValue) {
      Navigator.of(context).pushNamed(AppRoutes.childInfo).then((_) {
        if (mounted) {
          final cubit = context.read<ChildrenCubit>();
          if (cubit.state.status != ChildrenStatus.loading) {
            cubit.addChildAndRefresh();
          }
        }
      });
      return;
    }

    final childIndex = int.tryParse(value);
    if (childIndex == null) return;
    context.read<ChildrenCubit>().setActiveChild(childIndex);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
              children: [
                // ── Greeting ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text('مرحباً!', style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      )),
                      SizedBox(width: 4),
                      Text('👋', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كيف حال طفلك اليوم؟',
                      style: AppStyles.regular14Grey,
                    ),
                  ),
                ),

                // ── Green Child Card ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<ChildrenCubit>(
                    builder: (context, childrenCubit, _) {
                      final childrenState = childrenCubit.state;
                      final activeChild = childrenState.activeChild;
                      final showLoading =
                          childrenState.status == ChildrenStatus.loading &&
                          childrenState.children.isEmpty;
                      final showError =
                          childrenState.status == ChildrenStatus.error &&
                          childrenState.children.isEmpty;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              )
                            else if (showError)
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'تعذر تحميل بيانات الأطفال',
                                      style: AppStyles.regular14White,
                                    ),
                                    const SizedBox(height: 8),
                                    IconButton(
                                      onPressed: () {
                                        context.read<ChildrenCubit>().loadChildren();
                                      },
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Row(
                                children: [
                                  // Avatar circle
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.whiteColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        activeChild?.genderEmoji ?? '👶',
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Name + age
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            PopupMenuButton<String>(
                                              onSelected: _handleChildMenuSelection,
                                              itemBuilder: (context) {
                                                return [
                                                  ...List.generate(
                                                    childrenState.children.length,
                                                    (index) => PopupMenuItem<String>(
                                                      value: '$index',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            index ==
                                                                    childrenState
                                                                        .activeChildIndex
                                                                ? Icons.check_circle
                                                                : Icons
                                                                      .person_outline,
                                                            size: 18,
                                                            color: index ==
                                                                    childrenState
                                                                        .activeChildIndex
                                                                ? AppColors.primary
                                                                : null,
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            childrenState
                                                                .children[index]
                                                                .name,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const PopupMenuDivider(),
                                                  const PopupMenuItem<String>(
                                                    value: _addChildMenuValue,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.add, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('إضافة طفل جديد'),
                                                      ],
                                                    ),
                                                  ),
                                                ];
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    activeChild?.name ?? 'طفلك',
                                                    style: AppStyles.bold18White,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: AppColors.whiteColor,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          activeChild?.ageLabel ?? '',
                                          style: AppStyles.regular14White,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            // Add measurement button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.measurement);
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('إضافة قياس جديد'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.whiteColor,
                                  side: const BorderSide(
                                    color: AppColors.whiteColor,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Stat Cards ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Streak card
                      Expanded(
                        child: _StatCard(
                          icon: '📈',
                          iconBg: AppColors.secondaryLighter,
                          value: '7',
                          label: 'أيام متتالية',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Meals today card
                      Expanded(
                        child: _StatCard(
                          icon: '🍽️',
                          iconBg: AppColors.primaryLighter,
                          value: '3',
                          label: 'وجبات اليوم',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Reminders Card ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.calendar_today, size: 18, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text(
                              'التذكيرات القادمة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLighter,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Blue icon square
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('📊', style: TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'قياس InBody',
                                      style: AppStyles.bold14Black,
                                    ),
                                    Text(
                                      'بعد 3 أيام',
                                      style: AppStyles.regular12Grey,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tip Card ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.lightbulb, color: AppColors.accent, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نصيحة اليوم 💡',
                                style: AppStyles.bold14Black,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تأكد من حصول طفلك على 8-10 ساعات من النوم يومياً لنمو صحي وسليم',
                                style: AppStyles.regular14White.copyWith(
                                  color: const Color(0xFF5D4037),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppStyles.bold20Black),
          Text(label, style: AppStyles.regular12Grey),
        ],
      ),
    );
  }
}

class _HomeChildSummary {
  final String name;
  final String ageLabel;

  const _HomeChildSummary({required this.name, required this.ageLabel});
}
