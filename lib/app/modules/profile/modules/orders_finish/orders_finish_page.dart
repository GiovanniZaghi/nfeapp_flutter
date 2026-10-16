import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/order/model/order_model.dart';
import '../../../../repositories/order/order_repository.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_cubit.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_state.dart';

List<OrderModel> _filterOrders(Map<String, dynamic> args) {
  final orders = args['orders'] as List<OrderModel>;
  final search = args['search'] as String;
  final month = args['month'] as int;
  final year = args['year'] as int;

  return orders.where((o) {
    if (o.data.isEmpty) return false;

    try {
      final parsedDate = DateFormat("dd/MM/yyyy").parse(o.data);
      if (parsedDate.month != month || parsedDate.year != year) return false;
    } catch (_) {
      return false;
    }

    final cliente = o.cliente.toLowerCase();
    final pedido = o.pedido.toLowerCase();
    return search.isEmpty ||
        cliente.contains(search.toLowerCase()) ||
        pedido.contains(search.toLowerCase());
  }).toList();
}

class OrdersFinishPage extends StatefulWidget {
  const OrdersFinishPage({super.key});

  @override
  State<OrdersFinishPage> createState() => _OrdersFinishPageState();
}

class _OrdersFinishPageState extends State<OrdersFinishPage> {
  final ValueNotifier<List<OrderModel>> _filteredOrders =
      ValueNotifier<List<OrderModel>>([]);
  String searchQuery = '';
  late int selectedMonth;
  late int selectedYear;
  bool _modalAberto = false;
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    Future.microtask(() {
      context.read<OrderBlocCubit>().getOrders(implemented: "SIM");
    });
  }

  Future<void> _atualizarFiltroAsync(List<OrderModel> orders) async {
    if (orders.isEmpty) {
      _filteredOrders.value = [];
      return;
    }

    _isFiltering = true;
    setState(() {});

    final result = await compute(_filterOrders, {
      'orders': orders,
      'search': searchQuery,
      'month': selectedMonth,
      'year': selectedYear,
    });

    _filteredOrders.value = result;
    _isFiltering = false;
    setState(() {});
  }

  Future<void> _abrirDetalhes(OrderModel order) async {
    if (_modalAberto) return;
    _modalAberto = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
    );

    final repo =
        context.read<OrderBlocCubit>().orderRepository as OrderRepository;
    final details = await repo.getOrderDetails(
      pedido: order.pedido,
      implemented: true,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (details.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nenhum item encontrado")));
      _modalAberto = false;
      return;
    }

    double totalBruto = 0;
    for (var item in details) {
      final preco = double.tryParse(item.prcUnit.replaceAll(',', '.')) ?? 0;
      double quantidade = 0;
      if (item.quant is String) {
        quantidade = double.tryParse(item.quant.replaceAll(',', '.')) ?? 0;
      } else if (item.quant is int) {
        quantidade = (item.quant as int).toDouble();
      } else if (item.quant is double) {
        quantidade = item.quant as double;
      }
      totalBruto += preco * quantidade;
    }

    final desconto = double.tryParse(order.desconto.replaceAll(',', '.')) ?? 0;
    final totalComDesconto = totalBruto - desconto;

    String formatar(double valor) =>
        valor.toStringAsFixed(2).replaceAll('.', ',');

    final condicao = details.first.condicao;
    final forma = details.first.forma;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(ctx).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pedido #${order.pedido}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () async {
                              final buffer = StringBuffer();
                              buffer.writeln(
                                "📦 *Detalhes do Pedido #${order.pedido}*",
                              );
                              buffer.writeln("👤 Cliente: ${order.cliente}");
                              buffer.writeln("💳 Condição: $condicao");
                              buffer.writeln("💰 Forma: $forma");
                              buffer.writeln("");
                              buffer.writeln("🧾 Itens:");

                              for (var item in details) {
                                final preco =
                                    double.tryParse(
                                      item.prcUnit.replaceAll(',', '.'),
                                    ) ??
                                    0;
                                double quantidade = 0;
                                if (item.quant is String) {
                                  quantidade =
                                      double.tryParse(
                                        item.quant.replaceAll(',', '.'),
                                      ) ??
                                      0;
                                } else if (item.quant is int) {
                                  quantidade = (item.quant as int).toDouble();
                                } else if (item.quant is double) {
                                  quantidade = item.quant as double;
                                }

                                final totalItem = preco * quantidade;
                                buffer.writeln(
                                  "• ${item.produto} (x${quantidade.toStringAsFixed(0)}) - R\$ ${totalItem.toStringAsFixed(2).replaceAll('.', ',')}",
                                );
                              }

                              buffer.writeln("");
                              buffer.writeln(
                                "🔹 Total Bruto: R\$ ${formatar(totalBruto)}",
                              );
                              buffer.writeln(
                                "🔹 Desconto: R\$ ${formatar(desconto)}",
                              );
                              buffer.writeln(
                                "🔹 Total com Desconto: R\$ ${formatar(totalComDesconto)}",
                              );

                              await Share.share(buffer.toString());
                            },
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Cliente: ${order.cliente}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Condição de Pagamento: $condicao",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Forma: $forma",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Total Bruto: R\$ ${formatar(totalBruto)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Desconto: R\$ ${formatar(desconto)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Total com Desconto: R\$ ${formatar(totalComDesconto)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: details.length,
                      itemBuilder: (context, i) {
                        final item = details[i];

                        final precoUnit =
                            double.tryParse(
                              item.prcUnit.replaceAll(',', '.'),
                            ) ??
                            0;
                        double quantidade = 0;
                        if (item.quant is String) {
                          quantidade =
                              double.tryParse(
                                item.quant.replaceAll(',', '.'),
                              ) ??
                              0;
                        } else if (item.quant is int) {
                          quantidade = (item.quant as int).toDouble();
                        } else if (item.quant is double) {
                          quantidade = item.quant as double;
                        }
                        final totalItem = precoUnit * quantidade;

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${item.produto} (COD: ${item.codProd})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Qtd: ${quantidade.toStringAsFixed(0)} - Unit: R\$ ${precoUnit.toStringAsFixed(2).replaceAll('.', ',')}",
                              ),
                              Text(
                                "Total: R\$ ${totalItem.toStringAsFixed(2).replaceAll('.', ',')}",
                              ),
                              const Divider(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    _modalAberto = false;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/bg-login.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar pedido...',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) async {
                    searchQuery = value;
                    final state = context.read<OrderBlocCubit>().state;
                    if (state.orderModel != null) {
                      await _atualizarFiltroAsync(state.orderModel!);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration: InputDecoration(
                          labelText: "Mês",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                        items: List.generate(12, (i) {
                          final month = i + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              DateFormat.MMMM(
                                'pt_BR',
                              ).format(DateTime(0, month)).toUpperCase(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }),
                        onChanged: (val) async {
                          selectedMonth = val!;
                          final state = context.read<OrderBlocCubit>().state;
                          if (state.orderModel != null) {
                            await _atualizarFiltroAsync(state.orderModel!);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: InputDecoration(
                          labelText: "Ano",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                        items:
                            years
                                .map(
                                  (y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(
                                      y.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) async {
                          selectedYear = val!;
                          final state = context.read<OrderBlocCubit>().state;
                          if (state.orderModel != null) {
                            await _atualizarFiltroAsync(state.orderModel!);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocConsumer<OrderBlocCubit, OrderBlocState>(
                  listener: (context, state) async {
                    if (state.status == OrderStateStatus.success &&
                        state.orderModel != null) {
                      await _atualizarFiltroAsync(state.orderModel!);
                    }
                  },
                  builder: (context, state) {
                    if (state.status == OrderStateStatus.loading ||
                        _isFiltering) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == OrderStateStatus.error) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Erro ao buscar pedidos',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    return ValueListenableBuilder<List<OrderModel>>(
                      valueListenable: _filteredOrders,
                      builder: (context, list, _) {
                        if (list.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhum pedido encontrado',
                              style: TextStyle(color: primaryColor),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final order = list[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Card(
                                color: Colors.lightBlue[50],
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _abrirDetalhes(order),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTileOrdersWidget(
                                      order: {
                                        'number': order.pedido,
                                        'client': order.cliente,
                                        'total':
                                            'R\$ ${(double.tryParse(order.total.toString().replaceAll(',', '.')) ?? 0).toStringAsFixed(2).replaceAll('.', ',')}',
                                        'date': order.data,
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _filteredOrders.dispose();
    super.dispose();
  }
}
