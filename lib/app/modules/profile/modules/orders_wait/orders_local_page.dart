import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/dao/cart/cart_dao.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/finishCard/model/cart_model.dart';
import '../../../home/modules/cart/cubit/finishCard/finish_bloc_cubit.dart';
import '../../../../core/ui/helpers/messages.dart';
import '../../../home/modules/cart/finish_cart_page.dart';

class LocalOrdersPage extends StatefulWidget {
  const LocalOrdersPage({super.key});

  static final ValueNotifier<bool> updateNotifier = ValueNotifier(false);

  @override
  State<LocalOrdersPage> createState() => _LocalOrdersPageState();
}

class _LocalOrdersPageState extends State<LocalOrdersPage>
    with Messages<LocalOrdersPage> {
  String searchQuery = '';
  List<CartModel> localOrders = [];
  bool _modalAberto = false;

  @override
  void initState() {
    super.initState();
    _loadLocalOrders();
    _loadClientes();
    LocalOrdersPage.updateNotifier.addListener(_onUpdate);
  }

  Future<void> _loadClientes() async {
    final cubit = context.read<FinishCartCubit>();
    await cubit.fetchClientes();
    await cubit.fetchCondicoesPagamento();
    await cubit.fetchTiposPagamento();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    LocalOrdersPage.updateNotifier.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    _loadLocalOrders();
  }

  Future<void> _loadLocalOrders() async {
    final dao = CartDao();
    final pedidos = await dao.getCarts();
    if (!mounted) return;
    setState(() {
      localOrders = pedidos;
    });
  }

  List<CartModel> getFilteredOrders(List<CartModel> orders) {
    if (searchQuery.isEmpty) return orders;
    return orders.where((o) {
      final cliente = o.idCliente.toLowerCase();
      final pedido = o.numPed.toLowerCase();
      return cliente.contains(searchQuery.toLowerCase()) ||
          pedido.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _abrirDetalhes(CartModel order) async {
    if (_modalAberto) return;
    _modalAberto = true;

    final cubit = context.read<FinishCartCubit>();

    await cubit.fetchProdutosLocais();
    await cubit.fetchClientes();
    await cubit.fetchCondicoesPagamento();
    await cubit.fetchTiposPagamento();

    cubit.setProdutosDoPedido(order.produtos);
    cubit.setPedidoEmEdicao(order);

    final clientesMap = {
      for (var c in cubit.clientesLista) c.codigo: c.cliente,
    };
    final produtosMap = {
      for (var p in cubit.produtosLista) p.codigo: p.produto,
    };
    final condicoesMap = {
      for (var c in cubit.condicoesPagamento) c.codigo: c.descricao,
    };
    final tiposMap = {
      for (var t in cubit.tiposPagamento) t.codigo: t.descricao,
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String formatar(double valor) =>
            valor.toStringAsFixed(2).replaceAll('.', ',');

        double totalBruto = 0.0;
        for (var item in order.produtos) {
          final preco = double.tryParse(item.preco.replaceAll(',', '.')) ?? 0.0;
          totalBruto += preco * item.quantidade;
        }

        double desconto =
            double.tryParse(order.valDesc.replaceAll(',', '.')) ?? 0.0;
        double totalComDesconto = totalBruto - desconto;
        if (totalComDesconto < 0) totalComDesconto = 0;

        void _compartilharPedido() {
          final cliente = clientesMap[order.idCliente] ?? order.idCliente;
          final texto = '''
Pedido #${order.numPed}
Cliente: $cliente
Forma de Pagamento: ${tiposMap[order.idTpPag] ?? order.idTpPag}
Condição: ${condicoesMap[order.idCondPag] ?? order.idCondPag}
Total: R\$ ${formatar(totalComDesconto)}
''';
          Share.share(texto, subject: 'Detalhes do Pedido #${order.numPed}');
        }

        return Padding(
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
                      "Pedido #${order.numPed}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _compartilharPedido,
                          icon: const Icon(
                            Icons.share,
                            color: Colors.blueAccent,
                          ),
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
                  "Cliente: ${clientesMap[order.idCliente] ?? order.idCliente}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Forma de Pagamento: ${tiposMap[order.idTpPag] ?? order.idTpPag}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Condição: ${condicoesMap[order.idCondPag] ?? order.idCondPag}",
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
                    itemCount: order.produtos.length,
                    itemBuilder: (context, i) {
                      final item = order.produtos[i];
                      final preco =
                          double.tryParse(item.preco.replaceAll(',', '.')) ?? 0;
                      final totalItem = preco * item.quantidade;
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Produto: ${produtosMap[item.idProduto] ?? item.idProduto}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text("Qtd: ${item.quantidade}"),
                            Text("Unit: R\$ ${formatar(preco)}"),
                            Text("Total: R\$ ${formatar(totalItem)}"),
                            const Divider(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                        onPressed: () async {
                          final clienteSelecionado = cubit.clientesLista
                              .firstWhere(
                                (c) => c.codigo == order.idCliente,
                                orElse: () => cubit.clientesLista.first,
                              );

                          final condicaoSelecionada = cubit.condicoesPagamento
                              .firstWhere(
                                (c) => c.codigo == order.idCondPag,
                                orElse: () => cubit.condicoesPagamento.first,
                              );

                          final tipoSelecionado = cubit.tiposPagamento
                              .firstWhere(
                                (t) => t.codigo == order.idTpPag,
                                orElse: () => cubit.tiposPagamento.first,
                              );

                          cubit.setCliente(clienteSelecionado);
                          cubit.setCondicaoPagamento(condicaoSelecionada);
                          cubit.setTipoPagamento(tipoSelecionado);
                          cubit.setProdutosDoPedido(order.produtos);
                          cubit.setPedidoEmEdicao(order);

                          Navigator.of(ctx).pop();

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FinishCartPage(pedido: order),
                            ),
                          );

                          _loadLocalOrders();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Excluir"),
                        onPressed: () async {
                          await cubit.excluirPedidoLocal(order.numPed);
                          if ((cubit.state.successMessage ?? '').isNotEmpty) {
                            showSuccess(cubit.state.successMessage!);
                          } else if ((cubit.state.errorMessage ?? '')
                              .isNotEmpty) {
                            showError(cubit.state.errorMessage!);
                          }
                          cubit.limparMensagens();
                          Navigator.of(ctx).pop();
                          _loadLocalOrders();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    _modalAberto = false;
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders(localOrders);
    final cubit = context.read<FinishCartCubit>();
    final clientesMap = {
      for (var c in cubit.clientesLista) c.codigo: c.cliente,
    };

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
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
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              Expanded(
                child:
                    filteredOrders.isEmpty
                        ? const Center(child: Text('Nenhum pedido salvo'))
                        : ListView.separated(
                          itemCount: filteredOrders.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
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
                                        'number': order.numPed,
                                        'client':
                                            clientesMap[order.idCliente] ??
                                            order.idCliente,
                                        'total':
                                            'R\$ ${order.totalPed.replaceAll('.', ',')}',
                                        'date': order.dataPed,
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          if (localOrders.isNotEmpty)
            Positioned(
              left: 16,
              bottom: 16,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Enviar Todos",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final cubit = context.read<FinishCartCubit>();
                  final sucesso = await cubit.enviarTodosPedidos();
                  if (sucesso) {
                    showSuccess("Todos os pedidos foram enviados!");
                  } else {
                    showError("Falha ao enviar todos os pedidos.");
                  }
                  _loadLocalOrders();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
