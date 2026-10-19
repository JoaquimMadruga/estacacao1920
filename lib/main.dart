import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Estação Meteorológica',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),

        scaffoldBackgroundColor:
        const Color(0xFFF5F7FA),
      ),

      home: const LoginScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        title: const Text(
          'Sistema Meteorológico',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),

            child: Row(
              children: [
                const Icon(Icons.person_outline),

                const SizedBox(width: 8),

                const Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ============================================================
      // MENU LATERAL
      // ============================================================

      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,

            children: [
              // ----------------------------------------------------
              // CABEÇALHO DO MENU
              // ----------------------------------------------------

              Container(
                height: 180,

                padding: const EdgeInsets.all(24),

                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),

                child: const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  mainAxisAlignment:
                  MainAxisAlignment.end,

                  children: [
                    Icon(
                      Icons.cloud,
                      color: Colors.white,
                      size: 45,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Sistema Meteorológico',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Estação meteorológica',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------
              // DASHBOARD
              // ----------------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.dashboard_outlined,
                ),

                title: const Text(
                  'Dashboard',
                ),

                selected: true,

                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // ----------------------------------------------------
              // USUÁRIOS
              // ----------------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.people_outline,
                ),

                title: const Text(
                  'Usuários',
                ),

                onTap: () {
                  Navigator.pop(context);

                  // Futuramente:
                  // Navigator.push(...)
                },
              ),

              // ----------------------------------------------------
              // METEOROLOGIA
              // ----------------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.cloud_outlined,
                ),

                title: const Text(
                  'Meteorologia',
                ),

                onTap: () {
                  Navigator.pop(context);

                  // Futuramente:
                  // Navigator.push(...)
                },
              ),

              const Divider(),

              // ----------------------------------------------------
              // SAIR
              // ----------------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.logout,
                ),

                title: const Text(
                  'Sair',
                ),

                onTap: () {
                  Navigator.pop(context);

                  // Futuramente:
                  // voltar para o LoginScreen
                },
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // CORPO DA TELA
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ====================================================
              // TÍTULO
              // ====================================================

              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Acompanhe os registros da estação meteorológica.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // ====================================================
              // CARDS DE RESUMO
              // ====================================================

              LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final largura =
                      constraints.maxWidth;

                  // Desktop
                  if (largura >= 900) {
                    return Row(
                      children: [
                        Expanded(
                          child: resumoCard(
                            icon: Icons.people_outline,
                            titulo: 'USUÁRIOS',
                            valor: '1',
                            descricao: 'cadastrado',
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: resumoCard(
                            icon: Icons.cloud_outlined,
                            titulo: 'REGISTROS',
                            valor: '1',
                            descricao: 'registro',
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: resumoCard(
                            icon: Icons.access_time,
                            titulo: 'ÚLTIMO REGISTRO',
                            valor: '19:26',
                            descricao: '01/10/2026',
                          ),
                        ),
                      ],
                    );
                  }

                  // Celular / tela pequena
                  return Column(
                    children: [
                      resumoCard(
                        icon: Icons.people_outline,
                        titulo: 'USUÁRIOS',
                        valor: '1',
                        descricao: 'cadastrado',
                      ),

                      const SizedBox(height: 16),

                      resumoCard(
                        icon: Icons.cloud_outlined,
                        titulo: 'REGISTROS',
                        valor: '1',
                        descricao: 'registro',
                      ),

                      const SizedBox(height: 16),

                      resumoCard(
                        icon: Icons.access_time,
                        titulo: 'ÚLTIMO REGISTRO',
                        valor: '19:26',
                        descricao: '01/10/2026',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 35),

              // ====================================================
              // ACESSO RÁPIDO
              // ====================================================

              const Text(
                'Acesso rápido',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Acesse rapidamente as principais funções.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final largura =
                      constraints.maxWidth;

                  if (largura >= 700) {
                    return Row(
                      children: [
                        Expanded(
                          child: acessoCard(
                            icon: Icons.person_add_outlined,
                            titulo: 'Cadastrar usuário',
                            descricao:
                            'Adicione um novo usuário ao sistema.',
                            onTap: () {
                              // Futuramente:
                              // abrir cadastro
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: acessoCard(
                            icon: Icons.cloud_outlined,
                            titulo:
                            'Novo registro meteorológico',
                            descricao:
                            'Registre os dados coletados pela estação.',
                            onTap: () {
                              // Futuramente:
                              // abrir cadastro meteorológico
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      acessoCard(
                        icon: Icons.person_add_outlined,
                        titulo: 'Cadastrar usuário',
                        descricao:
                        'Adicione um novo usuário ao sistema.',
                        onTap: () {},
                      ),

                      const SizedBox(height: 16),

                      acessoCard(
                        icon: Icons.cloud_outlined,
                        titulo:
                        'Novo registro meteorológico',
                        descricao:
                        'Registre os dados coletados pela estação.',
                        onTap: () {},
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 35),

              // ====================================================
              // ÚLTIMOS REGISTROS
              // ====================================================

              const Text(
                'Últimos registros',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Confira os dados meteorológicos mais recentes.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              // ====================================================
              // TABELA
              // ====================================================

              Card(
                elevation: 1,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: SingleChildScrollView(
                    scrollDirection:
                    Axis.horizontal,

                    child: DataTable(
                      columnSpacing: 35,

                      columns: const [
                        DataColumn(
                          label: Text(
                            'Data',
                          ),
                        ),

                        DataColumn(
                          label: Text(
                            'Hora',
                          ),
                        ),

                        DataColumn(
                          label: Text(
                            'Temperatura',
                          ),
                        ),

                        DataColumn(
                          label: Text(
                            'Umidade',
                          ),
                        ),

                        DataColumn(
                          label: Text(
                            'Condição',
                          ),
                        ),
                      ],

                      rows: const [
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '01/10/2026',
                              ),
                            ),

                            DataCell(
                              Text(
                                '19:26',
                              ),
                            ),

                            DataCell(
                              Text(
                                '1,00 °C',
                              ),
                            ),

                            DataCell(
                              Text(
                                '4,00 %',
                              ),
                            ),

                            DataCell(
                              Text(
                                'Ensolarado',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // WIDGET: CARD DE RESUMO
  // ================================================================

  Widget resumoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required String descricao,
  }) {
    return Card(
      elevation: 1,

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // Ícone
            Icon(
              icon,
              size: 34,
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            // Título
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 8),

            // Valor
            Text(
              valor,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            // Descrição
            Text(
              descricao,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // WIDGET: CARD DE ACESSO RÁPIDO
  // ================================================================

  Widget acessoCard({
    required IconData icon,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,

      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(22),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // Ícone
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),

              const SizedBox(height: 16),

              // Título
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Descrição
              Text(
                descricao,
                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              // Botão visual
              const Row(
                mainAxisAlignment:
                MainAxisAlignment.end,

                children: [
                  Text(
                    'Acessar',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}