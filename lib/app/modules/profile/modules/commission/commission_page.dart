import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'cubit/commission_bloc_cubit.dart';
import 'cubit/commission_bloc_state.dart';

class CommissionPage extends StatefulWidget {
  const CommissionPage({super.key});

  @override
  State<CommissionPage> createState() => _CommissionPageState();
}

class _CommissionPageState extends State<CommissionPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  String _formatDate(DateTime date) {
    return DateFormat('ddMMyyyy').format(date);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart ? startDate : endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      context.read<CommissionBlocCubit>().fetchCommissions(
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CommissionBlocCubit>().fetchCommissions(
      startDate: _formatDate(startDate),
      endDate: _formatDate(endDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comissões')),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: true),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Início: ${DateFormat('dd/MM/yyyy').format(startDate)}",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Fim: ${DateFormat('dd/MM/yyyy').format(endDate)}",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<CommissionBlocCubit, CommissionState>(
                  builder: (context, state) {
                    if (state.status == CommissionBlocStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == CommissionBlocStatus.error) {
                      return Center(
                        child: Text(state.errorMessage ?? 'Erro ao carregar'),
                      );
                    }

                    final hasNoData =
                        state.commissions.length == 1 &&
                        state.commissions[0].data.contains(
                          'Não existem pedidos',
                        );

                    if (hasNoData) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Nenhuma comissão encontrada para este período',
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
                      itemCount: state.commissions.length,
                      itemBuilder: (context, index) {
                        final commission = state.commissions[index];
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
                                Text(
                                  "Data: ${commission.data}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Total Pedido: R\$ ${commission.totalPed}",
                                ),
                                Text(
                                  "Total Devolução: R\$ ${commission.totalDev}",
                                ),
                                Text(
                                  "Total Comissão: R\$ ${commission.totalComi}",
                                ),
                              ],
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
    );
  }
}
