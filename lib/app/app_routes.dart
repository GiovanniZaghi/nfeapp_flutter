import 'package:nfeapp_flutter/app/modules/home/home_page.dart';
import 'package:nfeapp_flutter/app/modules/home/modules/cart/add_cart_page.dart';
import 'package:nfeapp_flutter/app/modules/profile/modules/customer/customer_page.dart';
import 'package:nfeapp_flutter/app/modules/profile/modules/orders_finish/orders_finish_page.dart';
import 'package:nfeapp_flutter/app/modules/profile/modules/orders_open/orders_open_page.dart';
import 'package:nfeapp_flutter/app/modules/profile/modules/consultProduct/consult_product_page.dart';
import 'package:get/get.dart';

import 'modules/home/modules/cart/finish_cart_page.dart';
import 'modules/login/login_page.dart';
import 'modules/profile/modules/commission/commission_page.dart';
import 'modules/splash/splash_page.dart';

class Routes {
  static const INITIAL = "/splash";
  static const LOGIN = "/login";
  static const HOME = "/home";
  static const ORDERS_OPEN = "/orders_open";
  static const ORDERS_FINISH = "/orders_finish";
  static const CUSTOMER = "/customer";
  static const CONSULT_PRODUCT = "/ConsultProduct";
  static const COMMISSION = "/Commission";
  static const FINISH_CART = "/finish_cart";
  static const ADD_CART = "/add_cart";
}

class AppPages {
  static final pages = [
    GetPage(name: Routes.INITIAL, page: () => const SplashPage()),
    GetPage(name: Routes.LOGIN, page: () => const LoginPage()),
    GetPage(name: Routes.HOME, page: () => const HomePage()),
    GetPage(name: Routes.ORDERS_OPEN, page: () => const OrdersOpenPage()),
    GetPage(name: Routes.ORDERS_FINISH, page: () => const OrdersFinishPage()),
    GetPage(
      name: Routes.CONSULT_PRODUCT,
      page: () => const ConsultProductPage(),
    ),
    GetPage(name: Routes.CUSTOMER, page: () => const CustomerPage()),
    GetPage(name: Routes.COMMISSION, page: () => const CommissionPage()),
    GetPage(name: Routes.FINISH_CART, page: () => const FinishCartPage()),
    GetPage(name: Routes.ADD_CART, page: () => ProductListPage()),
  ];
}
