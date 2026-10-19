
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import 'cadastro_usuario_screen.dart';
import 'cadastro_meteorologico_screen.dart';
import 'historico_meteorologico_screen.dart';
import 'graficos_meteorologicos_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const DashboardScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String temperatura = '--';
  String umidade = '--';
  String pressao = '--';
  String vento = '--';
  String condicao = '--';
  String dataLeitura = '';
  String horaLeitura = '';

  bool carregando = true;
  String? erro;

  List<Map<String, dynamic>> historico = [];
  bool carregandoHistorico = true;
  String? erroHistorico;

  DateTime? dataInicial;
  DateTime? dataFinal;
  String climaSelecionado = '';

  static const Color fundo = Color(0xFFF5F7FB);
  static const Color azul = Color(0xFF2563EB);
  static const Color texto = Color(0xFF182338);
  static const Color textoSecundario = Color(0xFF718096);

  static const Map<String, String> climas = {
    '': 'Todas as condições',
    '1': 'Ensolarado',
    '2': 'Nublado',
    '3': 'Chuvoso',
    '4': 'Parcialmente nublado',
    '5': 'Tempestade',
    '6': 'Frio',
    '7': 'Quente',
    '8': 'Ventando',
  };

  @override
  void initState() {
    super.initState();
    atualizarTudo();
  }

  Future<void> atualizarTudo() async {
    await Future.wait([
      carregarDados(),
      carregarHistorico(),
    ]);
  }

  String formatarNumero(dynamic valor) {
    if (valor == null) return '--';

    final numero = double.tryParse(valor.toString());

    if (numero == null || !numero.isFinite) return '--';

    return numero.toStringAsFixed(1);
  }

  Future<void> carregarDados() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    final resultado = await ApiService.buscarUltimaLeitura();

    if (!mounted) return;

    setState(() {
      carregando = false;

      if (resultado['sucesso'] == true &&
          resultado['leitura'] is Map) {
        final leitura = resultado['leitura'];

        temperatura = formatarNumero(leitura['temperatura']);
        umidade = formatarNumero(leitura['umidade']);
        pressao = formatarNumero(leitura['pressao']);
        vento = formatarNumero(leitura['velocidade_vento']);

        condicao = leitura['descricao']?.toString() ?? '--';
        dataLeitura = leitura['data']?.toString() ?? '';
        horaLeitura = leitura['hora']?.toString() ?? '';
      } else {
        erro = resultado['mensagem']?.toString() ??
            'Não foi possível carregar os dados.';

        temperatura = '--';
        umidade = '--';
        pressao = '--';
        vento = '--';
        condicao = '--';
        dataLeitura = '';
        horaLeitura = '';
      }
    });
  }

  Future<void> carregarHistorico() async {
    setState(() {
      carregandoHistorico = true;
      erroHistorico = null;
    });

    try {
      final resultado = await ApiService.buscarHistorico();

      if (!mounted) return;

      if (resultado['sucesso'] == true &&
          resultado['leituras'] is List) {
        final registros = (resultado['leituras'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();

        registros.sort((a, b) {
          final dataA = '${a['data'] ?? ''} ${a['hora'] ?? ''}';
          final dataB = '${b['data'] ?? ''} ${b['hora'] ?? ''}';
          return dataA.compareTo(dataB);
        });

        setState(() {
          historico = registros;
          carregandoHistorico = false;
        });
      } else {
        setState(() {
          erroHistorico = resultado['mensagem']?.toString() ??
              'Não foi possível carregar o histórico.';
          carregandoHistorico = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erroHistorico = 'Erro ao carregar o histórico.';
        carregandoHistorico = false;
      });
    }
  }

  String emojiClima() {
    switch (condicao.trim().toLowerCase()) {
      case 'ensolarado':
        return '☀️';
      case 'nublado':
        return '☁️';
      case 'chuvoso':
        return '🌧️';
      case 'parcialmente nublado':
        return '⛅';
      case 'tempestade':
        return '⛈️';
      case 'frio':
        return '❄️';
      case 'quente':
        return '🥵';
      case 'ventando':
        return '💨';
      default:
        return '🌤️';
    }
  }

  Color corClima() {
    switch (condicao.trim().toLowerCase()) {
      case 'ensolarado':
      case 'quente':
        return const Color(0xFFFFF3D9);
      case 'nublado':
        return const Color(0xFFE8EDF3);
      case 'chuvoso':
        return const Color(0xFFE0EEFF);
      case 'parcialmente nublado':
        return const Color(0xFFFFF4E4);
      case 'tempestade':
        return const Color(0xFFEAE4FF);
      case 'frio':
        return const Color(0xFFE3F5FF);
      case 'ventando':
        return const Color(0xFFE0F5F1);
      default:
        return const Color(0xFFEAF0FA);
    }
  }

  String dataFormatada() {
    final partes = dataLeitura.split('-');

    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return dataLeitura;
  }

  String formatarDataFiltro(DateTime? data) {
    if (data == null) return 'Selecionar';

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String dataCurta(dynamic data) {
    final valor = data?.toString() ?? '';

    if (valor.length < 10) return valor;

    return '${valor.substring(8, 10)}/'
        '${valor.substring(5, 7)}';
  }

  Future<void> selecionarData(bool inicial) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial
          ? (dataInicial ?? DateTime.now())
          : (dataFinal ?? dataInicial ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: inicial ? 'Data inicial' : 'Data final',
    );

    if (escolhida == null || !mounted) return;

    setState(() {
      if (inicial) {
        dataInicial = escolhida;
      } else {
        dataFinal = escolhida;
      }
    });
  }

  void limparFiltros() {
    setState(() {
      dataInicial = null;
      dataFinal = null;
      climaSelecionado = '';
    });
  }

  List<Map<String, dynamic>> get historicoFiltrado {
    return historico.where((leitura) {
      final data = DateTime.tryParse(
        leitura['data']?.toString() ?? '',
      );

      if (data == null) return false;

      final climaId = leitura['descricao_id']?.toString() ?? '';

      if (climaSelecionado.isNotEmpty &&
          climaId != climaSelecionado) {
        return false;
      }

      if (dataInicial != null && data.isBefore(dataInicial!)) {
        return false;
      }

      if (dataFinal != null && data.isAfter(dataFinal!)) {
        return false;
      }

      return true;
    }).toList();
  }

  // BARRA COMPACTA DE FILTROS
  Widget barraFiltros() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE9EDF4),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list,
                  color: azul,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 210,
            height: 42,
            child: DropdownButtonFormField<String>(
              key: ValueKey(climaSelecionado),
              initialValue: climaSelecionado,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: climas.entries.map((item) {
                return DropdownMenuItem(
                  value: item.key,
                  child: Text(
                    item.value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  climaSelecionado = valor ?? '';
                });
              },
            ),
          ),

          OutlinedButton.icon(
            onPressed: () => selecionarData(true),
            icon: const Icon(Icons.calendar_month, size: 16),
            label: Text(
              'De: ${formatarDataFiltro(dataInicial)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          OutlinedButton.icon(
            onPressed: () => selecionarData(false),
            icon: const Icon(Icons.calendar_month, size: 16),
            label: Text(
              'Até: ${formatarDataFiltro(dataFinal)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          TextButton.icon(
            onPressed: limparFiltros,
            icon: const Icon(Icons.restart_alt, size: 17),
            label: const Text(
              'Limpar',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // CARD DOS INDICADORES
  Widget cardIndicador({
    required String titulo,
    required String valor,
    required String unidade,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9EDF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 25,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            titulo,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            carregando
                ? 'Carregando...'
                : valor == '--'
                ? '--'
                : '$valor $unidade',
            style: const TextStyle(
              color: texto,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // GRÁFICOS REUTILIZANDO O PINTOR JÁ CRIADO
  Widget cardGrafico({
    required String titulo,
    required String campo,
    required String unidade,
    required Color cor,
    required IconData icone,
  }) {
    final pontos = <PontoGrafico>[];

    for (final leitura in historicoFiltrado) {
      final numero = double.tryParse(
        leitura[campo]?.toString() ?? '',
      );

      if (numero == null || !numero.isFinite) continue;

      pontos.add(
        PontoGrafico(
          valor: numero,
          legenda: dataCurta(leitura['data']),
          descricao:
          '${leitura['data'] ?? ''} ${leitura['hora'] ?? ''}',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9EDF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            '${pontos.length} medições • $unidade',
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 22),

          if (pontos.isEmpty)
            const SizedBox(
              height: 230,
              child: Center(
                child: Text('Nenhuma medição encontrada.'),
              ),
            )
          else
            SizedBox(
              height: 230,
              width: double.infinity,
              child: CustomPaint(
                painter: PintorGrafico(
                  pontos: pontos,
                  cor: cor,
                  unidade: unidade,
                ),
              ),
            ),

          if (pontos.isNotEmpty) ...[
            const SizedBox(height: 15),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'Mín: ${pontos.map((p) => p.valor).reduce(math.min).toStringAsFixed(1)} $unidade',
                ),
                Text(
                  'Máx: ${pontos.map((p) => p.valor).reduce(math.max).toStringAsFixed(1)} $unidade',
                ),
                Text(
                  'Média: ${(pontos.map((p) => p.valor).reduce((a, b) => a + b) / pontos.length).toStringAsFixed(1)} $unidade',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget secaoGraficos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gráficos meteorológicos',
          style: TextStyle(
            color: texto,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${historicoFiltrado.length} leituras no período selecionado',
          style: const TextStyle(
            color: textoSecundario,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 18),

        if (carregandoHistorico)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (erroHistorico != null)
          Column(
            children: [
              Text(
                erroHistorico!,
                style: const TextStyle(color: Colors.red),
              ),
              TextButton(
                onPressed: carregarHistorico,
                child: const Text('Tentar novamente'),
              ),
            ],
          )
        else ...[
            cardGrafico(
              titulo: 'Evolução da temperatura',
              campo: 'temp_ins',
              unidade: '°C',
              cor: const Color(0xFFEF6C35),
              icone: Icons.thermostat,
            ),

            const SizedBox(height: 16),

            cardGrafico(
              titulo: 'Umidade relativa do ar',
              campo: 'umi_ins',
              unidade: '%',
              cor: azul,
              icone: Icons.water_drop,
            ),

            const SizedBox(height: 16),

            cardGrafico(
              titulo: 'Pressão atmosférica',
              campo: 'pressao_ins',
              unidade: 'hPa',
              cor: Colors.teal,
              icone: Icons.speed,
            ),

            const SizedBox(height: 12),

            const Text(
              'Os gráficos utilizam os registros armazenados '
                  'no banco de dados, incluindo eventuais dados de teste.',
              style: TextStyle(
                color: textoSecundario,
                fontSize: 12,
              ),
            ),
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: texto,
        elevation: 0,
        title: const Text(
          'Estação Meteorológica 1920',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados e gráficos',
            onPressed: carregando || carregandoHistorico
                ? null
                : atualizarTudo,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${widget.usuario.nome}!',
                  style: const TextStyle(
                    color: texto,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.usuario.email,
                  style: const TextStyle(
                    color: textoSecundario,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 22),

                // FILTROS ACIMA DA CONDIÇÃO CLIMÁTICA
                barraFiltros(),

                const SizedBox(height: 16),

                // CONDIÇÃO CLIMÁTICA
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: corClima(),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 18,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONDIÇÃO CLIMÁTICA',
                            style: TextStyle(
                              color: textoSecundario,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            carregando ? 'Carregando...' : condicao,
                            style: const TextStyle(
                              color: texto,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            dataLeitura.isNotEmpty
                                ? 'Última leitura: ${dataFormatada()} às $horaLeitura'
                                : 'Aguardando dados meteorológicos',
                            style: const TextStyle(
                              color: textoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        carregando ? '⏳' : emojiClima(),
                        style: const TextStyle(fontSize: 76),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Dados meteorológicos',
                  style: TextStyle(
                    color: texto,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // INDICADORES RESPONSIVOS
                LayoutBuilder(
                  builder: (context, constraints) {
                    final largura = constraints.maxWidth;

                    final colunas = largura >= 900
                        ? 4
                        : largura >= 550
                        ? 2
                        : 1;

                    final larguraCard =
                        (largura - (colunas - 1) * 14) / colunas;

                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: larguraCard,
                          child: cardIndicador(
                            titulo: 'Temperatura',
                            valor: temperatura,
                            unidade: '°C',
                            icone: Icons.thermostat,
                            cor: Colors.orange,
                          ),
                        ),

                        SizedBox(
                          width: larguraCard,
                          child: cardIndicador(
                            titulo: 'Umidade relativa',
                            valor: umidade,
                            unidade: '%',
                            icone: Icons.water_drop,
                            cor: Colors.blue,
                          ),
                        ),

                        SizedBox(
                          width: larguraCard,
                          child: cardIndicador(
                            titulo: 'Pressão atmosférica',
                            valor: pressao,
                            unidade: 'hPa',
                            icone: Icons.speed,
                            cor: Colors.purple,
                          ),
                        ),

                        SizedBox(
                          width: larguraCard,
                          child: cardIndicador(
                            titulo: 'Velocidade do vento',
                            valor: vento,
                            unidade: 'km/h',
                            icone: Icons.air,
                            cor: Colors.teal,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                if (erro != null) ...[
                  const SizedBox(height: 22),
                  Text(
                    erro!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                const Text(
                  'Os dados apresentados correspondem à '
                      'última leitura registrada na estação.',
                  style: TextStyle(
                    color: textoSecundario,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 35),

                // GRÁFICOS ABAIXO DOS INDICADORES
                secaoGraficos(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),

// MENU LATERAL
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // INFORMAÇÕES DO USUÁRIO
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: azul,
              ),
              accountName: Text(widget.usuario.nome),
              accountEmail: Text(widget.usuario.email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: azul,
                ),
              ),
            ),

            // DASHBOARD
            ListTile(
              leading: const Icon(
                Icons.dashboard_outlined,
              ),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),

            const Divider(),

            // CADASTRAR USUÁRIO
            ListTile(
              leading: const Icon(
                Icons.person_add_alt_1,
                color: azul,
              ),
              title: const Text('Cadastrar usuário'),
              subtitle: const Text('Adicionar um novo acesso'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const CadastroUsuarioScreen(),
                  ),
                );
              },
            ),

            // AQUI CONTINUA O CADASTRO METEOROLÓGICO

            ListTile(
              leading: const Icon(
                Icons.cloud_upload_outlined,
                color: azul,
              ),
              title: const Text('Cadastro meteorológico'),
              subtitle: const Text('Registrar nova leitura'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const CadastroMeteorologicoScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
