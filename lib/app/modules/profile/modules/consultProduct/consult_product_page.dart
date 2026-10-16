import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/event/table_price_event.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import 'cubit/consult_product_bloc_cubit.dart';
import 'cubit/consult_product_bloc_state.dart';

class ConsultProductPage extends StatefulWidget {
  const ConsultProductPage({super.key});

  @override
  State<ConsultProductPage> createState() => _ConsultProductPageState();
}

class _ConsultProductPageState extends State<ConsultProductPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isGridView = false;

  @override
  void initState() {
    super.initState();

    TabelaPrecoEvent.stream.listen((novaTabela) {
      if (mounted) {
        context.read<ConsultProductBlocCubit>().fetchProducts(novaTabela);
      }
    });

    context.read<ConsultProductBlocCubit>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar Produtos')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar produtos...',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon:
                              searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        searchQuery = '';
                                      });
                                    },
                                  )
                                  : null,
                          fillColor: Colors.white.withOpacity(0.8),
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () {
                        setState(() {
                          isGridView = !isGridView;
                        });
                      },
                    ),
                  ],
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

                    final filteredProducts =
                        (state.products ?? []).where((p) {
                          return p.produto.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              ) ||
                              p.codigo.toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              );
                        }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text('Nenhum produto encontrado'),
                      );
                    }

                    if (isGridView) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(product: product);
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(product: product, isGrid: false);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ConsultProductModel product;
  final bool isGrid;

  const ProductCard({super.key, required this.product, this.isGrid = true});

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.lightBlue[50];

    return isGrid
        ? Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          clipBehavior: Clip.antiAlias,
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
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product.produto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Código: ${product.codigo} • ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'R\$ ${product.preco} • ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Estoque: ${product.estoque}',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        )
        : Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          child: ListTile(
            tileColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(15),
            leading: Image.network(
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
                  ),
            ),
            title: Text(
              product.produto,
              style: const TextStyle(color: Colors.black87),
            ),
            subtitle: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Código: ${product.codigo} • ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'R\$ ${product.preco} • ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Estoque: ${product.estoque}',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
