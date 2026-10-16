import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/event/table_price_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nome = "Nome pendente";
  String email = "Email pendente";
  String? imagem64;
  int tabelaSelecionada = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('userFantasia') ?? "Nome pendente";
      email = prefs.getString('userEmail') ?? "Email pendente";
      imagem64 = prefs.getString('userImagem64');
      tabelaSelecionada = prefs.getInt('tabelaPreco') ?? 2;
    });
  }

  Future<void> _changeTabela(int selected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tabelaPreco', selected);
    setState(() => tabelaSelecionada = selected);

    TabelaPrecoEvent.change(selected);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userLogin');
    await prefs.remove('userCodigo');
    await prefs.remove('companyCodigo');
    await prefs.remove('userFantasia');
    await prefs.remove('userEmail');
    await prefs.remove('userImagem64');
    await prefs.remove('multitab');
    await prefs.remove('repId');
    await prefs.remove('host');
    await prefs.remove('port');
    await prefs.remove('tabelaPreco');

    await prefs.reload();

    Get.offAllNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary,
                      child:
                          imagem64 != null
                              ? ClipOval(
                                child: Image.memory(
                                  base64Decode(imagem64!),
                                  fit: BoxFit.cover,
                                  width: 56,
                                  height: 56,
                                ),
                              )
                              : const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.content_paste_search,
                        color: colorScheme.primary,
                      ),
                      title: const Text("Consultar Produtos"),
                      onTap: () => Get.toNamed("/ConsultProduct"),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.attach_money,
                        color: colorScheme.primary,
                      ),
                      title: const Text("Comissão"),
                      onTap: () => Get.toNamed("/Commission"),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person_search_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text("Clientes"),
                      onTap: () => Get.toNamed("/customer"),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.star_rate,
                        color: colorScheme.primary,
                      ),
                      title: const Text("Avaliar App"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.shopping_bag_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text("Tabela de Preço"),
                      subtitle: Text(
                        tabelaSelecionada == 1
                            ? "A Prazo"
                            : tabelaSelecionada == 2
                            ? "À Vista"
                            : "Promoção",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () async {
                        final selected = await showDialog<int>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text(
                                  "Selecione a Tabela de Preço",
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text("1 - A Prazo"),
                                      onTap: () => Navigator.pop(context, 1),
                                    ),
                                    ListTile(
                                      title: const Text("2 - À Vista"),
                                      onTap: () => Navigator.pop(context, 2),
                                    ),
                                    ListTile(
                                      title: const Text("3 - Promoção"),
                                      onTap: () => Navigator.pop(context, 3),
                                    ),
                                  ],
                                ),
                              ),
                        );

                        if (selected != null) {
                          await _changeTabela(selected);
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: colorScheme.primary,
                      ),
                      title: const Text("Sair"),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
