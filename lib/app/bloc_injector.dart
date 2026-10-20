import 'package:nfeapp_flutter/app/modules/home/modules/cart/cubit/order/order_bloc_cubit.dart';
import 'package:nfeapp_flutter/app/repositories/ccRepresentante/cc_representante_repository.dart';
import 'package:nfeapp_flutter/app/repositories/commission/commission_repository.dart';
import 'package:nfeapp_flutter/app/repositories/customer/customer_repository.dart';
import 'package:nfeapp_flutter/app/repositories/finishCard/finish_cart_repository.dart';
import 'package:nfeapp_flutter/app/repositories/login/login_repository.dart';
import 'package:nfeapp_flutter/app/repositories/order/order_repository.dart';
import 'package:nfeapp_flutter/app/repositories/payment/payment_repository.dart';
import 'package:nfeapp_flutter/app/repositories/product/consult_product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_widget.dart';
import 'core/helpers/environments.dart';
import 'core/rest/http/http_rest_client.dart';
import 'modules/home/modules/cart/cubit/finishCard/finish_bloc_cubit.dart';
import 'modules/login/cubit/login_bloc_cubit.dart';
import 'modules/profile/modules/ccRepresentante/cubit/cc_representante_bloc_cubit.dart';
import 'modules/profile/modules/commission/cubit/commission_bloc_cubit.dart';
import 'modules/profile/modules/consultProduct/cubit/consult_product_bloc_cubit.dart';
import 'modules/profile/modules/customer/cubit/customer_bloc_cubit.dart';

class BlocInjection extends StatefulWidget {
  const BlocInjection({super.key});

  @override
  State<BlocInjection> createState() => _BlocInjectionState();
}

class _BlocInjectionState extends State<BlocInjection> {
  final HttpRestClient _apiRestClient = HttpRestClient(
    baseUrl: Environments.get('BASE_URL') ?? "",
  );

  late final Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Erro ao inicializar dependências: ${snapshot.error}',
                ),
              ),
            ),
          );
        }

        final prefs = snapshot.data!;

        return MultiBlocProvider(
          providers: [
            BlocProvider<LoginBlocCubit>(
              create:
                  (_) => LoginBlocCubit(
                    loginRepository: LoginRepository(
                      restClient: _apiRestClient,
                    ),
                  ),
            ),
            BlocProvider<OrderBlocCubit>(
              create:
                  (_) => OrderBlocCubit(
                    orderRepository: OrderRepository(rest: _apiRestClient),
                  ),
            ),
            BlocProvider<CustomerBlocCubit>(
              create:
                  (_) => CustomerBlocCubit(
                    customerRepository: CustomerRepository(),
                  )..fetchCustomers(),
            ),
            BlocProvider<ConsultProductBlocCubit>(
              create:
                  (_) => ConsultProductBlocCubit(
                    productRepository: ConsultProductRepository(),
                  )..fetchProducts(),
            ),
            BlocProvider<CommissionBlocCubit>(
              create:
                  (_) =>
                      CommissionBlocCubit(repository: CommissionRepository()),
            ),
            BlocProvider<CCRepresentanteBlocCubit>(
              create:
                  (_) => CCRepresentanteBlocCubit(
                    repository: CCRepresentanteRepository(),
                  ),
            ),
            BlocProvider<FinishCartCubit>(
              create:
                  (_) => FinishCartCubit(
                    paymentRepository: PaymentRepository(),
                    customerRepository: CustomerRepository(),
                    finishCartRepository: FinishCartRepository(),
                    prefs: prefs,
                  ),
            ),
          ],
          child: const AppWidget(),
        );
      },
    );
  }
}
