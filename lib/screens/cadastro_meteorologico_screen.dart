
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class CadastroMeteorologicoScreen extends StatefulWidget {
  const CadastroMeteorologicoScreen({super.key});

  @override
  State<CadastroMeteorologicoScreen> createState() =>
      _CadastroMeteorologicoScreenState();
}

class _CadastroMeteorologicoScreenState
    extends State<CadastroMeteorologicoScreen> {
  static const Color azul = Color(0xFF2563EB);
  static const Color fundo = Color(0xFFF7F8FA);
  static const Color texto = Color(0xFF202124);

  final _formKey = GlobalKey<FormState>();

  late DateTime dataSelecionada;
  late TimeOfDay horaSelecionada;

  int? descricaoId;
  bool salvando = false;
  bool expandirTodas = false;
  int versaoExpansao = 0;

  final Map<String, TextEditingController> campos = {};

  final Map<int, Map<String, String>> descricoes = {
    1: {'nome': 'Ensolarado', 'emoji': '☀️'},
    2: {'nome': 'Nublado', 'emoji': '☁️'},
    3: {'nome': 'Chuvoso', 'emoji': '🌧️'},
    4: {'nome': 'Parcialmente nublado', 'emoji': '⛅'},
    5: {'nome': 'Tempestade', 'emoji': '⛈️'},
    6: {'nome': 'Frio', 'emoji': '❄️'},
    7: {'nome': 'Quente', 'emoji': '🌡️'},
    8: {'nome': 'Ventando', 'emoji': '💨'},
  };

  final List<String> nomesCampos = [
    'temp_ins',
    'temp_min',
    'temp_max',
    'umi_ins',
    'umi_min',
    'umi_max',
    'pressao_ins',
    'pressao_min',
    'pressao_max',
    'velocidade_vento',
    'direcao_vento',
    'rajada_vento',
    'radiacao',
    'chuva',
    'pto_orv_ins',
    'pto_orv_min',
    'pto_orv_max',
  ];

  @override
  void initState() {
    super.initState();

    dataSelecionada = DateTime.now();
    horaSelecionada = TimeOfDay.now();

    for (final nome in nomesCampos) {
      campos[nome] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in campos.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get dataFormatada {
    final dia = dataSelecionada.day.toString().padLeft(2, '0');
    final mes = dataSelecionada.month.toString().padLeft(2, '0');
    final ano = dataSelecionada.year;

    return '$dia/$mes/$ano';
  }

  String get dataParaBanco {
    final ano = dataSelecionada.year.toString();
    final mes = dataSelecionada.month.toString().padLeft(2, '0');
    final dia = dataSelecionada.day.toString().padLeft(2, '0');

    return '$ano-$mes-$dia';
  }

  String get horaFormatada {
    final hora = horaSelecionada.hour.toString().padLeft(2, '0');
    final minuto = horaSelecionada.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null && mounted) {
      setState(() {
        dataSelecionada = data;
      });
    }
  }

  Future<void> selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horaSelecionada,
    );

    if (hora != null && mounted) {
      setState(() {
        horaSelecionada = hora;
      });
    }
  }

  // ============================================================
  // CAMPO NUMÉRICO
  // ============================================================

  Widget campoNumerico(
      String titulo,
      String chave, {
        String? unidade,
        bool obrigatorio = false,
      }) {
    return TextFormField(
      controller: campos[chave],
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[-0-9,.]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: titulo,
        hintText: '0,0',
        suffixText: unidade,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
      ),
      validator: (valor) {
        final textoDigitado = (valor ?? '').trim();

        if (textoDigitado.isEmpty) {
          return obrigatorio ? 'Campo obrigatório' : null;
        }

        final numero = double.tryParse(
          textoDigitado.replaceAll(',', '.'),
        );

        if (numero == null || !numero.isFinite) {
          return 'Número inválido';
        }

        if (chave.startsWith('umi_') &&
            (numero < 0 || numero > 100)) {
          return 'Use 0 a 100';
        }

        if (chave == 'direcao_vento' &&
            (numero < 0 || numero > 360)) {
          return 'Use 0 a 360';
        }

        if ((chave == 'chuva' ||
            chave == 'radiacao' ||
            chave == 'velocidade_vento' ||
            chave == 'rajada_vento') &&
            numero < 0) {
          return 'Valor negativo';
        }

        return null;
      },
    );
  }



  // ============================================================
  // LISTA SUSPENSA - DIREÇÃO DO VENTO
  // ============================================================

  Widget campoDirecaoVento() {
    const direcoes = {
      '0': 'Norte (N)',
      '45': 'Nordeste (NE)',
      '90': 'Leste (L)',
      '135': 'Sudeste (SE)',
      '180': 'Sul (S)',
      '225': 'Sudoeste (SO)',
      '270': 'Oeste (O)',
      '315': 'Noroeste (NO)',
    };

    return DropdownButtonFormField<String>(
      initialValue: campos['direcao_vento']!.text.isEmpty
          ? null
          : campos['direcao_vento']!.text,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Direção do vento',
        prefixIcon: Icon(Icons.explore_outlined),
        border: OutlineInputBorder(),
      ),
      hint: const Text('Selecione a direção'),
      items: direcoes.entries.map((direcao) {
        return DropdownMenuItem<String>(
          value: direcao.key,
          child: Text(direcao.value),
        );
      }).toList(),
      onChanged: (valor) {
        setState(() {
          campos['direcao_vento']!.text = valor ?? '';
        });
      },
    );
  }


  // ============================================================
  // SEÇÕES EXPANSÍVEIS
  // ============================================================

  Widget secao({
    required String titulo,
    required IconData icone,
    required List<Widget> camposSecao,
    bool expandida = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: ExpansionTile(
        key: ValueKey('$titulo-$versaoExpansao'),
        initiallyExpanded: expandida || expandirTodas,
        leading: Icon(icone, color: azul),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: texto,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          18,
        ),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;

              final colunas = largura >= 650
                  ? 3
                  : largura >= 400
                  ? 2
                  : 1;

              const espacamento = 12.0;

              final larguraCampo =
                  (largura - espacamento * (colunas - 1)) /
                      colunas;

              return Wrap(
                spacing: espacamento,
                runSpacing: 16,
                children: camposSecao.map((campo) {
                  return SizedBox(
                    width: larguraCampo,
                    child: campo,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALIDAÇÕES
  // ============================================================

  double? valorNumerico(String chave) {
    final valor = campos[chave]?.text.trim() ?? '';

    if (valor.isEmpty) return null;

    return double.tryParse(
      valor.replaceAll(',', '.'),
    );
  }

  bool intervaloValido(String minima, String maxima) {
    final min = valorNumerico(minima);
    final max = valorNumerico(maxima);

    if (min == null || max == null) return true;

    return min <= max;
  }

  void mostrarMensagem(
      String mensagem, {
        bool erro = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro
            ? const Color(0xFFDC2626)
            : const Color(0xFF2563EB),
      ),
    );
  }

  // ============================================================
  // SALVAR LEITURA NO MYSQL ATRAVÉS DA API
  // ============================================================

  Future<void> salvarLeitura() async {
    if (salvando) return;

    // Abrir as seções para mostrar possíveis erros.
    setState(() {
      expandirTodas = true;
      versaoExpansao++;
    });

    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    if (!_formKey.currentState!.validate()) {
      mostrarMensagem(
        'Confira os campos destacados.',
        erro: true,
      );
      return;
    }

    if (!intervaloValido('temp_min', 'temp_max') ||
        !intervaloValido('umi_min', 'umi_max') ||
        !intervaloValido('pressao_min', 'pressao_max') ||
        !intervaloValido('pto_orv_min', 'pto_orv_max')) {
      mostrarMensagem(
        'O valor mínimo não pode ser maior que o máximo.',
        erro: true,
      );
      return;
    }

    if (descricaoId == null) {
      mostrarMensagem(
        'Selecione uma condição climática.',
        erro: true,
      );
      return;
    }

    final dados = <String, String>{
      'data': dataParaBanco,
      'hora': horaFormatada,
      'descricao_id': descricaoId.toString(),
    };

    // Adiciona todas as medições ao envio.
    for (final entrada in campos.entries) {
      dados[entrada.key] = entrada.value.text
          .trim()
          .replaceAll(',', '.');
    }

    setState(() {
      salvando = true;
    });

    try {
      final resposta = await ApiService.cadastrarLeitura(
        dados: dados,
      );

      if (!mounted) return;

      if (resposta['sucesso'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Leitura cadastrada com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        mostrarMensagem(
          resposta['mensagem']?.toString() ??
              'Não foi possível salvar a leitura.',
          erro: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      mostrarMensagem(
        'Erro ao comunicar com o servidor.',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Cadastro Meteorológico'),
        backgroundColor: Colors.white,
        foregroundColor: texto,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1050,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Nova leitura meteorológica',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Preencha as informações da estação para '
                      'registrar uma nova medição.',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                // DATA E HORA
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: salvando
                              ? null
                              : selecionarData,
                          icon: const Icon(
                            Icons.calendar_today,
                          ),
                          label: Text(
                            'Data: $dataFormatada',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: salvando
                              ? null
                              : selecionarHora,
                          icon: const Icon(
                            Icons.access_time,
                          ),
                          label: Text(
                            'Hora: $horaFormatada',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // TEMPERATURA
                secao(
                  titulo: 'Temperatura',
                  icone: Icons.thermostat,
                  expandida: true,
                  camposSecao: [
                    campoNumerico(
                      'Instantânea',
                      'temp_ins',
                      unidade: '°C',
                      obrigatorio: true,
                    ),
                    campoNumerico(
                      'Mínima',
                      'temp_min',
                      unidade: '°C',
                    ),
                    campoNumerico(
                      'Máxima',
                      'temp_max',
                      unidade: '°C',
                    ),
                  ],
                ),

                // UMIDADE
                secao(
                  titulo: 'Umidade',
                  icone: Icons.water_drop_outlined,
                  camposSecao: [
                    campoNumerico(
                      'Instantânea',
                      'umi_ins',
                      unidade: '%',
                      obrigatorio: true,
                    ),
                    campoNumerico(
                      'Mínima',
                      'umi_min',
                      unidade: '%',
                    ),
                    campoNumerico(
                      'Máxima',
                      'umi_max',
                      unidade: '%',
                    ),
                  ],
                ),

                // PRESSÃO ATMOSFÉRICA
                secao(
                  titulo: 'Pressão atmosférica',
                  icone: Icons.speed,
                  camposSecao: [
                    campoNumerico(
                      'Instantânea',
                      'pressao_ins',
                      unidade: 'hPa',
                    ),
                    campoNumerico(
                      'Mínima',
                      'pressao_min',
                      unidade: 'hPa',
                    ),
                    campoNumerico(
                      'Máxima',
                      'pressao_max',
                      unidade: 'hPa',
                    ),
                  ],
                ),

                // VENTO

// ============================================================
// VENTO
// ============================================================

                secao(
                  titulo: 'Vento',
                  icone: Icons.air,
                  camposSecao: [
                    campoNumerico(
                      'Velocidade',
                      'velocidade_vento',
                      unidade: 'km/h',
                    ),

                    // Lista suspensa de direção do vento
                    campoDirecaoVento(),

                    campoNumerico(
                      'Rajada',
                      'rajada_vento',
                      unidade: 'km/h',
                    ),
                  ],
                ),


                // OUTRAS MEDIÇÕES
                secao(
                  titulo: 'Outras medições',
                  icone: Icons.cloud_outlined,
                  camposSecao: [
                    campoNumerico(
                      'Radiação',
                      'radiacao',
                    ),
                    campoNumerico(
                      'Chuva',
                      'chuva',
                      unidade: 'mm',
                    ),
                  ],
                ),

                // PONTO DE ORVALHO
                secao(
                  titulo: 'Ponto de orvalho',
                  icone: Icons.ac_unit,
                  camposSecao: [
                    campoNumerico(
                      'Instantâneo',
                      'pto_orv_ins',
                      unidade: '°C',
                    ),
                    campoNumerico(
                      'Mínimo',
                      'pto_orv_min',
                      unidade: '°C',
                    ),
                    campoNumerico(
                      'Máximo',
                      'pto_orv_max',
                      unidade: '°C',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // CONDIÇÃO CLIMÁTICA
                const Text(
                  'Condição climática',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: descricoes.entries.map((entrada) {
                    final selecionado =
                        descricaoId == entrada.key;

                    return ChoiceChip(
                      selected: selecionado,
                      selectedColor:
                      const Color(0xFFDBEAFE),
                      backgroundColor: Colors.white,
                      label: Text(
                        '${entrada.value['emoji']}  '
                            '${entrada.value['nome']}',
                      ),
                      onSelected: salvando
                          ? null
                          : (_) {
                        setState(() {
                          descricaoId = entrada.key;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // BOTÃO SALVAR
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                    salvando ? null : salvarLeitura,
                    icon: salvando
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      salvando
                          ? 'Salvando...'
                          : 'Salvar informações',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azul,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
