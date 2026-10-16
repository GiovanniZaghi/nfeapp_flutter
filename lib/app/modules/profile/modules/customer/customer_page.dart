import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/customer/model/customer_model.dart';
import 'cubit/customer_bloc_cubit.dart';
import 'cubit/customer_bloc_state.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          BlocBuilder<CustomerBlocCubit, CustomerBlocState>(
            builder: (context, state) {
              if (state.status == CustomerStateStatus.success &&
                  (state.customers?.isNotEmpty ?? false)) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(state.customers!),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BlocBuilder<CustomerBlocCubit, CustomerBlocState>(
            builder: (context, state) {
              if (state.status == CustomerStateStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == CustomerStateStatus.error) {
                return Center(
                  child: Text(state.errorMessage ?? 'Erro desconhecido'),
                );
              }

              final customers = state.customers ?? [];

              if (customers.isEmpty) {
                return const Center(child: Text('Nenhum cliente encontrado'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return InkWell(
                    onTap: () {
                      _showCustomerModal(context, customer);
                    },
                    child: Card(
                      color: Colors.lightBlue[50],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.cliente,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Código: ${customer.codigo}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
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
        ],
      ),
    );
  }

  void _showCustomerModal(BuildContext context, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  customer.cliente,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildInfo("Código", customer.codigo),
                _buildInfo("Endereço", customer.endereco),
                _buildInfo("Bairro", customer.bairro),
                _buildInfo("Cidade", customer.cidade),
                _buildInfo("UF", customer.uf),
                _buildInfo("Restrição", customer.restricao),
                _buildInfo("Limite de Crédito", customer.limiteCredito),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isNotEmpty ? value : "-")),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<CustomerModel> customers;
  CustomSearchDelegate(this.customers);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        customers.where((c) {
          return c.cliente.toLowerCase().contains(query.toLowerCase()) ||
              c.codigo.contains(query);
        }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final customer = results[index];
        return InkWell(
          onTap: () => _showCustomerModal(context, customer),
          child: Card(
            color: Colors.lightBlue[50],
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.cliente,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código: ${customer.codigo}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        customers.where((c) {
          return c.cliente.toLowerCase().contains(query.toLowerCase()) ||
              c.codigo.contains(query);
        }).toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final customer = suggestions[index];
        return InkWell(
          onTap: () => _showCustomerModal(context, customer),
          child: Card(
            color: Colors.lightBlue[50],
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.cliente,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Código: ${customer.codigo}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCustomerModal(BuildContext context, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  customer.cliente,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildInfo("Código", customer.codigo),
                _buildInfo("Endereço", customer.endereco),
                _buildInfo("Bairro", customer.bairro),
                _buildInfo("Cidade", customer.cidade),
                _buildInfo("UF", customer.uf),
                _buildInfo("Restrição", customer.restricao),
                _buildInfo("Limite de Crédito", customer.limiteCredito),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isNotEmpty ? value : "-")),
        ],
      ),
    );
  }
}
