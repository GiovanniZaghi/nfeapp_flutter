import 'dart:async';

import 'package:nfeapp_flutter/app/modules/home/modules/cart/finish_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/event/table_price_event.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_cubit.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_state.dart';
import 'cubit/finishCard/finish_bloc_cubit.dart';

class CartItem {
  final ConsultProductModel product;
  int quantity;
  String obs;

  CartItem({required this.product, this.quantity = 0, this.obs = ''});
}

class ProductListPage extends StatefulWidget {
  final String? tabelaMultitab;

  const ProductListPage({super.key, this.tabelaMultitab});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String searchQuery = '';
  bool isGrid = false;
  List<CartItem> cart = [];
  final GlobalKey _cartButtonKey = GlobalKey();
  late final StreamSubscription<int> _tabelaSub;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<FinishCartCubit>();
    cart =
        cubit.state.produtos
            .map((p) => CartItem(product: p, quantity: p.quantidade))
            .toList();

    _tabelaSub = TabelaPrecoEvent.stream.listen((novaTabela) {
      if (mounted && widget.tabelaMultitab == null) {
        context.read<ConsultProductBlocCubit>().fetchProducts(novaTabela);
      }
    });

    context.read<ConsultProductBlocCubit>().fetchProducts(
      null,
      widget.tabelaMultitab,
    );
  }

  @override
  void dispose() {
    _tabelaSub.cancel();
    super.dispose();
  }

  void addToCart(ConsultProductModel product) {
    final index = cart.indexWhere(
      (item) => item.product.codigo == product.codigo,
    );
    if (index >= 0) {
      setState(() => cart[index].quantity++);
    } else {
      setState(() => cart.add(CartItem(product: product, quantity: 1)));
    }
  }

  void removeFromCart(ConsultProductModel product) {
    final index = cart.indexWhere(
      (item) => item.product.codigo == product.codigo,
    );
    if (index >= 0) {
      setState(() {
        if (cart[index].quantity > 1) {
          cart[index].quantity--;
        } else {
          cart.removeAt(index);
        }
      });
    }
  }

  void addToCartWithQuantity(
    ConsultProductModel product,
    int quantity, {
    String obs = '',
  }) {
    final index = cart.indexWhere(
      (item) => item.product.codigo == product.codigo,
    );
    if (index >= 0) {
      setState(() {
        cart[index].quantity += quantity;
        cart[index].obs = obs;
      });
    } else {
      setState(
        () =>
            cart.add(CartItem(product: product, quantity: quantity, obs: obs)),
      );
    }
  }

  int get totalItems => cart.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => cart.fold(0.0, (sum, item) {
    final price =
        double.tryParse(item.product.preco.replaceAll(',', '.')) ?? 0.0;
    return sum + price * item.quantity;
  });

  Future<void> _handleBackNavigation() async {
    if (cart.isNotEmpty) {
      await showDialog(
        context: context,
        builder:
            (context) => Dialog(
              insetPadding: const EdgeInsets.all(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Carrinho com produtos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("Deseja excluir o carrinho?"),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Não"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text("Sim"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _openCartModal() async {
    final cubit = context.read<FinishCartCubit>();
    final selectedProducts = await showModalBottomSheet<
      List<ConsultProductModel>
    >(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Resumo Carrinho",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed:
                              () => Navigator.pop(
                                context,
                                <ConsultProductModel>[],
                              ),
                        ),
                      ],
                    ),
                    const Divider(),
                    cart.isEmpty
                        ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: Text('Carrinho vazio')),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.length,
                          itemBuilder: (_, index) {
                            final item = cart[index];
                            return ListTile(
                              leading: Image.network(
                                item.product.imagem,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        Image.asset('assets/no-image.jpeg'),
                              ),
                              title: Text(item.product.produto),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Qtd: ${item.quantity} • ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "R\$ ${item.product.preco}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      removeFromCart(item.product);
                                      setModalState(() {});
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      addToCart(item.product);
                                      setModalState(() {});
                                    },
                                  ),
                                ],
                              ),
                              onTap:
                                  () => _showPriceInfoDialog(
                                    context,
                                    item.product,
                                  ),
                            );
                          },
                        ),
                    const SizedBox(height: 10),
                    Text(
                      "Total: R\$ ${totalPrice.toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final productsToAdd =
                              cart
                                  .map(
                                    (e) => e.product.copyWith(
                                      quantidade: e.quantity,
                                      obs: e.obs,
                                    ),
                                  )
                                  .toList();
                          cubit.setProdutos(productsToAdd);
                          Navigator.pop(context, productsToAdd);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text(
                          "Concluir",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedProducts != null && selectedProducts.isNotEmpty) {
      Navigator.pop(context, selectedProducts);
    }
  }

  void _openProductModal(ConsultProductModel product) {
    int quantity = 1;
    double preco = double.tryParse(product.preco.replaceAll(',', '.')) ?? 0.0;

    final TextEditingController quantityController = TextEditingController(
      text: quantity.toString(),
    );
    final TextEditingController precoController = TextEditingController(
      text: product.preco,
    );
    final TextEditingController obsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showPriceInfoDialog(context, product),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Image.network(
                      product.imagem,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) =>
                              Image.asset('assets/no-image.jpeg', height: 150),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.produto,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Código: ${product.codigo} • ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "R\$ ${product.preco} • ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "Estoque: ${product.estoque}",
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Preço (R\$): ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: precoController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*[,\.]?\d{0,2}'),
                              ),
                            ],
                            onTap: () {
                              precoController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: precoController.text.length,
                              );
                            },
                            onChanged: (value) {
                              setStateModal(() {
                                preco =
                                    double.tryParse(
                                      value.replaceAll(',', '.'),
                                    ) ??
                                    preco;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setStateModal(() {
                                quantity--;
                                quantityController.text = quantity.toString();
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onTap: () {
                              quantityController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: quantityController.text.length,
                              );
                            },
                            onChanged: (value) {
                              int? val = int.tryParse(value);
                              setStateModal(() {
                                quantity = val != null && val > 0 ? val : 1;
                                quantityController.text = quantity.toString();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setStateModal(() {
                              quantity++;
                              quantityController.text = quantity.toString();
                            });
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total: R\$ ${(preco * quantity).toStringAsFixed(2).replaceAll('.', ',')}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedProduct = product.copyWith(
                            preco: preco
                                .toStringAsFixed(2)
                                .replaceAll('.', ','),
                          );
                          addToCartWithQuantity(
                            updatedProduct,
                            quantity,
                            obs: obsController.text.trim(),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Adicionar ao carrinho",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPriceInfoDialog(
    BuildContext context,
    ConsultProductModel product,
  ) async {
    final bloc = context.read<ConsultProductBlocCubit>();
    final price = await bloc.repository.getProductPrices(product.codigo);

    if (price == null) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Preços do produto"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Faturado: R\$ ${price.precoFaturado}",
                  style: const TextStyle(color: Colors.blue),
                ),
                Text(
                  "À vista: R\$ ${price.precoAvista}",
                  style: const TextStyle(color: Colors.green),
                ),
                Text(
                  "Promoção: R\$ ${price.precoPromo}",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Fechar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Selecionar Produtos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackNavigation,
        ),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por código ou nome...',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon:
                        searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => searchQuery = ''),
                            )
                            : null,
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ),
              Expanded(
                child: BlocBuilder<
                  ConsultProductBlocCubit,
                  ConsultProductBlocState
                >(
                  builder: (context, state) {
                    if (state.status == ConsultProductStateStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == ConsultProductStateStatus.error) {
                      return Center(
                        child: Text(state.errorMessage ?? 'Erro desconhecido'),
                      );
                    }

                    final products =
                        (state.products ?? [])
                            .where(
                              (p) =>
                                  p.produto.toLowerCase().contains(
                                    searchQuery.toLowerCase(),
                                  ) ||
                                  p.codigo.toLowerCase().contains(
                                    searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList();

                    if (products.isEmpty) {
                      return const Center(
                        child: Text('Nenhum produto encontrado'),
                      );
                    }

                    if (isGrid) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () => _openProductModal(product),
                            child: Card(
                              color: Colors.lightBlue[50],
                              elevation: 3,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      product.imagem.isNotEmpty
                                          ? product.imagem
                                          : 'assets/no-image.jpeg',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Image.asset(
                                            'assets/no-image.jpeg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "Código: ${product.codigo} • ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "R\$ ${product.preco} • ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Estoque: ${product.estoque}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          color: Colors.lightBlue[50],
                          elevation: 3,
                          child: ListTile(
                            onTap: () => _openProductModal(product),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.imagem.isNotEmpty
                                    ? product.imagem
                                    : 'assets/no-image.jpeg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Image.asset(
                                      'assets/no-image.jpeg',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                            title: Text(product.produto),
                            subtitle: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Código: ${product.codigo} • ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "R\$ ${product.preco} • ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Estoque: ${product.estoque}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ElevatedButton.icon(
              key: _cartButtonKey,
              onPressed: _openCartModal,
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Resumo Carrinho"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
            ),
            if (totalItems > 0)
              Positioned(
                right: 0,
                top: -10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
