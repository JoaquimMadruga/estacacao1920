
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GraficosMeteorologicosScreen extends StatefulWidget {
  const GraficosMeteorologicosScreen({super.key});

  @override
  State<GraficosMeteorologicosScreen> createState() =>
      _GraficosMeteorologicosScreenState();
}

class _GraficosMeteorologicosScreenState
    extends State<GraficosMeteorologicosScreen> {
  static const azul = Color(0xFF2563EB);
  static const fundo = Color(0xFFF7F8FA);

  List<Map<String, dynamic>> leituras = [];
  bool carregando = true;
  String? erro;

  DateTime? dataInicial;
  DateTime? dataFinal;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resposta = await ApiService.buscarHistorico();

      if (!mounted) return;

      if (resposta['sucesso'] == true &&
          resposta['leituras'] is List) {
        final registros = (resposta['leituras'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();

        // Organiza do registro mais antigo para o mais recente.
        registros.sort((a, b) {
          final dataA =
              '${a['data'] ?? ''} ${a['hora'] ?? ''}';
          final dataB =
              '${b['data'] ?? ''} ${b['hora'] ?? ''}';

          return dataA.compareTo(dataB);
        });

        setState(() {
          leituras = registros;
          carregando = false;
        });
      } else {
        setState(() {
          erro = resposta['mensagem']?.toString() ??
              'Não foi possível carregar os gráficos.';
          carregando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = 'Erro ao consultar os dados meteorológicos.';
        carregando = false;
      });
    }
  }

  String formatarData(String data) {
    if (data.length < 10) return data;

    return '${data.substring(8, 10)}/'
        '${data.substring(5, 7)}';
  }

  String formatarDataCompleta(DateTime? data) {
    if (data == null) return 'Selecionar';

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
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

    if (!mounted || escolhida == null) return;

    setState(() {
      if (inicial) {
        dataInicial = escolhida;
      } else {
        dataFinal = escolhida;
      }
    });
  }

  List<Map<String, dynamic>> get leiturasFiltradas {
    return leituras.where((leitura) {
      final data =
      DateTime.tryParse(leitura['data']?.toString() ?? '');

      if (data == null) return false;

      if (dataInicial != null && data.isBefore(dataInicial!)) {
        return false;
      }

      if (dataFinal != null && data.isAfter(dataFinal!)) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget painelPeriodo() {
    return Container(
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
          const Text(
            'Filtrar por período',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => selecionarData(true),
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'De: ${formatarDataCompleta(dataInicial)}',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => selecionarData(false),
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Até: ${formatarDataCompleta(dataFinal)}',
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    dataInicial = null;
                    dataFinal = null;
                  });
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Limpar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget grafico({
    required String titulo,
    required String campo,
    required String unidade,
    required Color cor,
    required IconData icone,
  }) {
    final registros = leiturasFiltradas;

    final pontos = <PontoGrafico>[];

    for (final leitura in registros) {
      final numero = double.tryParse(
        leitura[campo]?.toString() ?? '',
      );

      if (numero == null || !numero.isFinite) continue;

      final data = leitura['data']?.toString() ?? '';
      final hora = leitura['hora']?.toString() ?? '';

      pontos.add(
        PontoGrafico(
          valor: numero,
          legenda: formatarData(data),
          descricao: '$data $hora',
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            '${pontos.length} medições • $unidade',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          if (pontos.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(
                child: Text('Nenhuma medição neste período.'),
              ),
            )
          else
            SizedBox(
              height: 240,
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
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                Text(
                  'Mín: ${pontos.map((p) => p.valor).reduce(math.min).toStringAsFixed(1)} $unidade',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Máx: ${pontos.map((p) => p.valor).reduce(math.max).toStringAsFixed(1)} $unidade',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Média: ${(pontos.map((p) => p.valor).reduce((a, b) => a + b) / pontos.length).toStringAsFixed(1)} $unidade',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Gráficos Meteorológicos'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202124),
        actions: [
          IconButton(
            tooltip: 'Atualizar gráficos',
            onPressed: carregando ? null : carregarDados,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: carregando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : erro != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(erro!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      )
          : Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Análise Meteorológica',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Acompanhe a evolução das medições registradas.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              painelPeriodo(),

              const SizedBox(height: 18),

              Text(
                '${leiturasFiltradas.length} registros no período',
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              grafico(
                titulo: 'Temperatura',
                campo: 'temp_ins',
                unidade: '°C',
                cor: const Color(0xFFEF6C35),
                icone: Icons.thermostat,
              ),

              grafico(
                titulo: 'Umidade do ar',
                campo: 'umi_ins',
                unidade: '%',
                cor: azul,
                icone: Icons.water_drop_outlined,
              ),

              grafico(
                titulo: 'Pressão atmosférica',
                campo: 'pressao_ins',
                unidade: 'hPa',
                cor: const Color(0xFF16A085),
                icone: Icons.speed,
              ),

              const Text(
                'Os gráficos representam os valores armazenados no banco de dados, incluindo registros de teste.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MODELO DE UM PONTO NO GRÁFICO
class PontoGrafico {
  final double valor;
  final String legenda;
  final String descricao;

  const PontoGrafico({
    required this.valor,
    required this.legenda,
    required this.descricao,
  });
}

// DESENHO DOS GRÁFICOS
class PintorGrafico extends CustomPainter {
  final List<PontoGrafico> pontos;
  final Color cor;
  final String unidade;

  PintorGrafico({
    required this.pontos,
    required this.cor,
    required this.unidade,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pontos.isEmpty) return;

    const esquerda = 56.0;
    const direita = 14.0;
    const topo = 15.0;
    const baixo = 36.0;

    final largura = math.max(
      1.0,
      size.width - esquerda - direita,
    );

    final altura = math.max(
      1.0,
      size.height - topo - baixo,
    );

    final valores = pontos.map((p) => p.valor).toList();

    var minimo = valores.reduce(math.min);
    var maximo = valores.reduce(math.max);

    // Evita divisão por zero quando todos os valores são iguais.
    if (minimo == maximo) {
      minimo -= 1;
      maximo += 1;
    } else {
      final margem = (maximo - minimo) * 0.1;
      minimo -= margem;
      maximo += margem;
    }

    final intervalo = maximo - minimo;

    final tintaGrade = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final tintaLinha = Paint()
      ..color = cor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final tintaPonto = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;

    void escrever(
        String texto,
        Offset posicao, {
          double tamanho = 11,
        }) {
      final painter = TextPainter(
        text: TextSpan(
          text: texto,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: tamanho,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(canvas, posicao);
    }

    // Linhas horizontais e valores do eixo Y.
    for (var i = 0; i <= 4; i++) {
      final y = topo + (altura / 4) * i;
      final valorEixo = maximo - intervalo * i / 4;

      canvas.drawLine(
        Offset(esquerda, y),
        Offset(esquerda + largura, y),
        tintaGrade,
      );

      escrever(
        valorEixo.toStringAsFixed(1),
        Offset(2, y - 7),
      );
    }

    final offsets = <Offset>[];

    for (var i = 0; i < pontos.length; i++) {
      final x = pontos.length == 1
          ? esquerda + largura / 2
          : esquerda + largura * i / (pontos.length - 1);

      final y = topo +
          altura * (maximo - pontos[i].valor) / intervalo;

      offsets.add(Offset(x, y));
    }

    // Liga os pontos.
    if (offsets.length > 1) {
      final caminho = Path()
        ..moveTo(offsets.first.dx, offsets.first.dy);

      for (var i = 1; i < offsets.length; i++) {
        caminho.lineTo(offsets[i].dx, offsets[i].dy);
      }

      canvas.drawPath(caminho, tintaLinha);
    }

    // Desenha os pontos.
    for (final ponto in offsets) {
      canvas.drawCircle(ponto, 4, tintaPonto);
    }

    // Datas no eixo X (limita rótulos para evitar sobreposição).
    final passo = math.max(1, (pontos.length / 5).ceil());

    for (var i = 0; i < pontos.length; i++) {
      if (i % passo != 0 && i != pontos.length - 1) {
        continue;
      }

      final x = offsets[i].dx;

      escrever(
        pontos[i].legenda,
        Offset(
          math.max(0, math.min(size.width - 40, x - 17)),
          topo + altura + 12,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PintorGrafico antigo) {
    return true;
  }
}
