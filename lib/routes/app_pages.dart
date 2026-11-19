import 'package:get/get.dart';
import '../views/detail_view.dart';
import '../views/home_view.dart';
import '../views/search_view.dart';
import 'app_routes.dart';

/// Konfigurasi routing aplikasi AniNews ID menggunakan GetX Page Routing.
class AppPages {
  AppPages._();

  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
