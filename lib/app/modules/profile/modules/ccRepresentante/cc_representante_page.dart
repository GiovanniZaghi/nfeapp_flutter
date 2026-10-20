import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/cc_representante_bloc_cubit.dart';
import 'cubit/cc_representante_bloc_state.dart';

class CCRepresentantePage extends StatefulWidget {
  const CCRepresentantePage({super.key});

  @override
  State<CCRepresentantePage> createState() => _CCRepresentantePageState();
}

class _CCRepresentantePageState extends State<CCRepresentantePage> {
  @override
  void initState() {
    super.initState();
    context.read<CCRepresentanteBlocCubit>().fetchExtrato();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crédito Representante')),
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
          BlocBuilder<CCRepresentanteBlocCubit, CCRepresentanteState>(
            builder: (context, state) {
              if (state.status == CCRepresentanteStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == CCRepresentanteStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Erro ao carregar'),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed:
                              () =>
                                  context
                                      .read<CCRepresentanteBlocCubit>()
                                      .fetchExtrato(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final hasNoData =
                  state.extrato.length == 1 &&
                  state.extrato[0].descricao.toLowerCase().contains(
                    'não exist',
                  );

              if (state.extrato.isEmpty || hasNoData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Nenhum lançamento encontrado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.extrato.length,
                itemBuilder: (context, index) {
                  final item = state.extrato[index];
                  return Card(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Data: ${item.data}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.prePedido.isNotEmpty)
                                Text("Pré-pedido: ${item.prePedido}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(item.descricao),
                          const SizedBox(height: 4),
                          Text("Débito: R\$ ${item.debito}"),
                          Text("Crédito: R\$ ${item.credito}"),
                          Text(
                            "Saldo: R\$ ${item.saldo}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
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
}
