
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Endereço da API PHP no WAMP
  static const String baseUrl = 'http://localhost/api';

  // ============================================================
  // CADASTRAR USUÁRIO
  // ============================================================

  static Future<Map<String, dynamic>> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios/cadastrar.php');

    try {
      debugPrint('Iniciando cadastro...');
      debugPrint('URL: $url');

      final resposta = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'nome': nome.trim(),
          'email': email.trim(),
          'senha': senha,
        },
      );

      debugPrint('STATUS CADASTRO: ${resposta.statusCode}');
      debugPrint('RESPOSTA CADASTRO: ${resposta.body}');

      if (resposta.statusCode != 200) {
        return {
          'sucesso': false,
          'mensagem':
          'Erro no servidor: ${resposta.statusCode}',
        };
      }

      final dados = jsonDecode(resposta.body);

      if (dados is Map<String, dynamic>) {
        return dados;
      }

      return {
        'sucesso': false,
        'mensagem': 'Resposta inesperada do servidor.',
      };
    } on FormatException catch (e) {
      debugPrint('ERRO JSON CADASTRO: $e');

      return {
        'sucesso': false,
        'mensagem':
        'O servidor retornou uma resposta inválida.',
      };
    } catch (e) {
      debugPrint('ERRO CADASTRO: $e');

      return {
        'sucesso': false,
        'mensagem':
        'Não foi possível conectar à API de cadastro.',
      };
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> loginUsuario({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios/login.php');

    try {
      final resposta = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email.trim(),
          'senha': senha,
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        if (dados is Map<String, dynamic>) {
          return dados;
        }

        return {
          'sucesso': false,
          'mensagem': 'Resposta inesperada do servidor.',
        };
      }

      return {
        'sucesso': false,
        'mensagem':
        'Erro no servidor: ${resposta.statusCode}',
      };
    } catch (e) {
      debugPrint('ERRO LOGIN: $e');

      return {
        'sucesso': false,
        'mensagem': 'Não foi possível conectar à API.',
      };
    }
  }

  // ============================================================
  // BUSCAR ÚLTIMA LEITURA METEOROLÓGICA
  // ============================================================

  static Future<Map<String, dynamic>> buscarUltimaLeitura() async {
    final url = Uri.parse(
      '$baseUrl/meteorologia/ultimas_leituras.php',
    );

    try {
      final resposta = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        if (dados is Map<String, dynamic>) {
          return dados;
        }

        return {
          'sucesso': false,
          'mensagem': 'Resposta inesperada do servidor.',
        };
      }

      return {
        'sucesso': false,
        'mensagem':
        'Erro no servidor: ${resposta.statusCode}',
      };
    } catch (e) {
      debugPrint('ERRO METEOROLOGIA: $e');

      return {
        'sucesso': false,
        'mensagem':
        'Não foi possível buscar os dados meteorológicos.',
      };
    }
  }

  // ============================================================
  // CADASTRAR LEITURA METEOROLÓGICA
  // ============================================================

  static Future<Map<String, dynamic>> cadastrarLeitura({
    required Map<String, String> dados,
  }) async {
    final url = Uri.parse(
      '$baseUrl/meteorologia/cadastrar.php',
    );

    try {
      debugPrint('Iniciando cadastro meteorológico...');
      debugPrint('URL: $url');

      final resposta = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: dados,
      );

      debugPrint(
        'STATUS METEOROLOGIA: ${resposta.statusCode}',
      );

      debugPrint(
        'RESPOSTA METEOROLOGIA: ${resposta.body}',
      );

      Map<String, dynamic> resultado;

      try {
        final json = jsonDecode(resposta.body);

        if (json is! Map<String, dynamic>) {
          return {
            'sucesso': false,
            'mensagem': 'Resposta inesperada do servidor.',
          };
        }

        resultado = json;
      } on FormatException {
        return {
          'sucesso': false,
          'mensagem':
          'O servidor retornou uma resposta inválida. '
              'Verifique o arquivo cadastrar.php.',
        };
      }

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        return {
          'sucesso': false,
          'mensagem': resultado['mensagem']?.toString() ??
              'Erro no servidor: ${resposta.statusCode}',
        };
      }

      return resultado;
    } catch (e) {
      debugPrint('ERRO CADASTRO METEOROLÓGICO: $e');

      return {
        'sucesso': false,
        'mensagem':
        'Não foi possível conectar à API meteorológica.',
      };
    }
  }


  // ============================================================
  // BUSCAR HISTÓRICO METEOROLÓGICO
  // ============================================================

  static Future<Map<String, dynamic>> buscarHistorico() async {
    final url = Uri.parse(
      '$baseUrl/meteorologia/historico.php',
    );

    try {
      debugPrint('Buscando histórico meteorológico...');

      final resposta = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'STATUS HISTÓRICO: ${resposta.statusCode}',
      );

      if (resposta.statusCode != 200) {
        return {
          'sucesso': false,
          'mensagem':
          'Erro no servidor: ${resposta.statusCode}',
        };
      }

      final dados = jsonDecode(resposta.body);

      if (dados is Map<String, dynamic>) {
        return dados;
      }

      return {
        'sucesso': false,
        'mensagem': 'Resposta inesperada do servidor.',
      };
    } on FormatException {
      return {
        'sucesso': false,
        'mensagem': 'O servidor retornou um JSON inválido.',
      };
    } catch (e) {
      debugPrint('ERRO HISTÓRICO: $e');

      return {
        'sucesso': false,
        'mensagem':
        'Não foi possível carregar o histórico meteorológico.',
      };
    }
  }
}


