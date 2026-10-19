
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoricoMeteorologicoScreen extends StatefulWidget {
  const HistoricoMeteorologicoScreen({super.key});

  @override
  State<HistoricoMeteorologicoScreen> createState() =>
      _HistoricoMeteorologicoScreenState();
}

class _HistoricoMeteorologicoScreenState
    extends State<HistoricoMeteorologicoScreen> {
  static const azul = Color(0xFF2563EB);
  static const fundo = Color(0xFFF7F8FA);
  static const texto = Color(0xFF202124);

  List<Map<String, dynamic>> leituras = [];
  String pesquisa = '';
  bool carregando = true;
  String? erro;

  DateTime? dataInicial;
  DateTime? dataFinal;
  String climaSelecionado = '';

  final pesquisaController = TextEditingController();

  static const Map<String, String> condicoes = {
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
    carregarHistorico();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  // BUSCAR REGISTROS NA API
  Future<void> carregarHistorico() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resposta = await ApiService.buscarHistorico();

      if (!mounted) return;

      if (resposta['sucesso'] == true &&
          resposta['leituras'] is List) {
        setState(() {
          leituras = (resposta['leituras'] as List)
              .whereType<Map<String, dynamic>>()
              .toList();
          carregando = false;
        });
      } else {
        setState(() {
          erro = resposta['mensagem']?.toString() ??
              'Não foi possível carregar o histórico.';
          carregando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = 'Erro ao carregar o histórico meteorológico.';
        carregando = false;
      });
    }
  }

  // FORMATAR VALORES
  String valor(dynamic dado, {String unidade = ''}) {
    if (dado == null || dado.toString().isEmpty) {
      return '--';
    }

    final numero = double.tryParse(dado.toString());

    if (numero != null) {
      return '${numero.toStringAsFixed(1)}$unidade';
    }

    return dado.toString();
  }

  String formatarData(dynamic data) {
    final textoData = data?.toString() ?? '';

    if (textoData.length >= 10) {
      return '${textoData.substring(8, 10)}/'
          '${textoData.substring(5, 7)}/'
          '${textoData.substring(0, 4)}';
    }

    return textoData;
  }

  String exibirData(DateTime? data) {
    if (data == null) return 'Selecionar data';

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String nomeClima(dynamic id) {
    return condicoes[id.toString()] ?? 'Não informado';
  }

  String emojiClima(dynamic id) {
    const emojis = {
      '1': '☀️',
      '2': '☁️',
      '3': '🌧️',
      '4': '⛅',
      '5': '⛈️',
      '6': '❄️',
      '7': '🌡️',
      '8': '💨',
    };

    return emojis[id.toString()] ?? '🌤️';
  }

  String nomeDirecao(dynamic graus) {
    if (graus == null) return '--';

    final numero = double.tryParse(graus.toString());
    if (numero == null) return '--';

    const nomes = [
      'Norte',
      'Nordeste',
      'Leste',
      'Sudeste',
      'Sul',
      'Sudoeste',
      'Oeste',
      'Noroeste',
    ];

    final indice = ((numero % 360) / 45).round() % 8;
    return nomes[indice];
  }

  // SELECIONAR DATA INICIAL OU FINAL
  Future<void> selecionarData({required bool inicial}) async {
    final data = await showDatePicker(
      context: context,
      initialDate: inicial
          ? (dataInicial ?? DateTime.now())
          : (dataFinal ?? dataInicial ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: inicial
          ? 'Selecione a data inicial'
          : 'Selecione a data final',
    );

    if (data == null || !mounted) return;

    setState(() {
      if (inicial) {
        dataInicial = data;
      } else {
        dataFinal = data;
      }
    });
  }

  // LIMPAR FILTROS
  void limparFiltros() {
    pesquisaController.clear();

    setState(() {
      pesquisa = '';
      climaSelecionado = '';
      dataInicial = null;
      dataFinal = null;
    });
  }

  // FILTRAR REGISTROS
  List<Map<String, dynamic>> get leiturasFiltradas {
    final termo = pesquisa.toLowerCase().trim();

    return leituras.where((leitura) {
      final dataTexto = leitura['data']?.toString() ?? '';
      final hora = leitura['hora']?.toString() ?? '';
      final climaId = leitura['descricao_id']?.toString() ?? '';
      final clima = nomeClima(climaId).toLowerCase();
      final dataFormatada = formatarData(dataTexto);

      final correspondePesquisa = termo.isEmpty ||
          dataFormatada.contains(termo) ||
          hora.contains(termo) ||
          clima.contains(termo);

      final correspondeClima = climaSelecionado.isEmpty ||
          climaId == climaSelecionado;

      bool correspondePeriodo = true;

      if (dataInicial != null || dataFinal != null) {
        final dataLeitura = DateTime.tryParse(dataTexto);

        if (dataLeitura == null) {
          correspondePeriodo = false;
        } else {
          if (dataInicial != null &&
              dataLeitura.isBefore(dataInicial!)) {
            correspondePeriodo = false;
          }

          if (dataFinal != null &&
              dataLeitura.isAfter(dataFinal!)) {
            correspondePeriodo = false;
          }
        }
      }

      return correspondePesquisa &&
          correspondeClima &&
          correspondePeriodo;
    }).toList();
  }

  // COMPONENTE DOS FILTROS
  Widget painelFiltros() {
    Widget botaoData(
        String titulo,
        DateTime? data,
        bool inicial,
        ) {
      return OutlinedButton.icon(
        onPressed: () => selecionarData(inicial: inicial),
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text('$titulo: ${exibirData(data)}'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_list, color: azul),
              SizedBox(width: 8),
              Text(
                'Filtros avançados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            key: ValueKey(climaSelecionado),
            initialValue: climaSelecionado,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Condição climática',
              border: OutlineInputBorder(),
            ),
            items: condicoes.entries.map((item) {
              return DropdownMenuItem<String>(
                value: item.key,
                child: Text(item.value),
              );
            }).toList(),
            onChanged: (novoValor) {
              setState(() {
                climaSelecionado = novoValor ?? '';
              });
            },
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              botaoData('De', dataInicial, true),
              botaoData('Até', dataFinal, false),
            ],
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: limparFiltros,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Limpar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  // COMPONENTE DE DETALHE
  Widget detalhe(String titulo, String conteudo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            conteudo,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // MOSTRAR DETALHES DE UMA LEITURA
  void mostrarDetalhes(Map<String, dynamic> leitura) {
    final campos = <String, String>{
      'Temperatura instantânea':
      valor(leitura['temp_ins'], unidade: ' °C'),
      'Temperatura mínima':
      valor(leitura['temp_min'], unidade: ' °C'),
      'Temperatura máxima':
      valor(leitura['temp_max'], unidade: ' °C'),
      'Umidade instantânea':
      valor(leitura['umi_ins'], unidade: ' %'),
      'Umidade mínima':
      valor(leitura['umi_min'], unidade: ' %'),
      'Umidade máxima':
      valor(leitura['umi_max'], unidade: ' %'),
      'Pressão instantânea':
      valor(leitura['pressao_ins'], unidade: ' hPa'),
      'Pressão mínima':
      valor(leitura['pressao_min'], unidade: ' hPa'),
      'Pressão máxima':
      valor(leitura['pressao_max'], unidade: ' hPa'),
      'Velocidade do vento':
      valor(leitura['vel_vento'], unidade: ' km/h'),
      'Direção do vento':
      nomeDirecao(leitura['dir_vento']),
      'Rajada de vento':
      valor(leitura['raj_vento'], unidade: ' km/h'),
      'Radiação':
      valor(leitura['radiacao']),
      'Quantidade de chuva':
      valor(leitura['qtd_chuva'], unidade: ' mm'),
      'Ponto de orvalho instantâneo':
      valor(leitura['pto_orvalho_ins'], unidade: ' °C'),
      'Ponto de orvalho mínimo':
      valor(leitura['pto_orvalho_min'], unidade: ' °C'),
      'Ponto de orvalho máximo':
      valor(leitura['pto_orvalho_max'], unidade: ' °C'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da leitura'),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${formatarData(leitura['data'])} '
                      'às ${leitura['hora'] ?? '--'}',
                ),

                const SizedBox(height: 8),

                Text(
                  '${emojiClima(leitura['descricao_id'])} '
                      '${nomeClima(leitura['descricao_id'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final largura = constraints.maxWidth;
                    final colunas = largura >= 450 ? 2 : 1;
                    const espaco = 10.0;

                    final larguraItem =
                        (largura - espaco * (colunas - 1)) /
                            colunas;

                    return Wrap(
                      spacing: espaco,
                      runSpacing: espaco,
                      children: campos.entries.map((campo) {
                        return SizedBox(
                          width: larguraItem,
                          child: detalhe(
                            campo.key,
                            campo.value,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // CARD DE CADA REGISTRO
  Widget cardLeitura(Map<String, dynamic> leitura) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => mostrarDetalhes(leitura),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fundo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  emojiClima(leitura['descricao_id']),
                  style: const TextStyle(fontSize: 27),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatarData(leitura['data']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${leitura['hora'] ?? '--'} • '
                          '${nomeClima(leitura['descricao_id'])}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    valor(
                      leitura['temp_ins'],
                      unidade: ' °C',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Umidade: '
                        '${valor(leitura['umi_ins'], unidade: ' %')}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.chevron_right,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // INTERFACE PRINCIPAL
  @override
  Widget build(BuildContext context) {
    final filtradas = leiturasFiltradas;

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Histórico Meteorológico'),
        backgroundColor: Colors.white,
        foregroundColor: texto,
        actions: [
          IconButton(
            tooltip: 'Atualizar histórico',
            onPressed: carregando ? null : carregarHistorico,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Histórico de leituras',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${leituras.length} leituras carregadas',
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                // CAMPO DE PESQUISA
                TextField(
                  controller: pesquisaController,
                  onChanged: (novoValor) {
                    setState(() {
                      pesquisa = novoValor;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                    'Pesquisar por data, hora ou clima...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: pesquisa.isEmpty
                        ? null
                        : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        pesquisaController.clear();

                        setState(() {
                          pesquisa = '';
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // PAINEL DE FILTROS
                painelFiltros(),

                const SizedBox(height: 16),

                Text(
                  '${filtradas.length} leituras encontradas',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // LISTA DE REGISTROS
                Expanded(
                  child: carregando
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : erro != null
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 44,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(erro!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: carregarHistorico,
                          child: const Text(
                            'Tentar novamente',
                          ),
                        ),
                      ],
                    ),
                  )
                      : filtradas.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhuma leitura encontrada.',
                    ),
                  )
                      : ListView.builder(
                    itemCount: filtradas.length,
                    itemBuilder: (context, index) {
                      return cardLeitura(
                        filtradas[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
