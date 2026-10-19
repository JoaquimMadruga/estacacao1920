import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() {
    return _CadastroUsuarioScreenState();
  }
}

class _CadastroUsuarioScreenState
    extends State<CadastroUsuarioScreen> {

  // ============================================================
  // CONTROLES DOS CAMPOS
  // ============================================================

  final TextEditingController nomeController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController senhaController =
  TextEditingController();

  final TextEditingController confirmarSenhaController =
  TextEditingController();

  // ============================================================
  // CONTROLE DO CARREGAMENTO
  // ============================================================

  bool carregando = false;

  // ============================================================
  // CADASTRAR USUÁRIO
  // ============================================================

  Future<void> cadastrarUsuario() async {

    // ----------------------------------------------------------
    // Verifica se o nome foi preenchido
    // ----------------------------------------------------------

    if (nomeController.text.trim().isEmpty) {
      mostrarMensagem('Digite o nome completo.');
      return;
    }

    // ----------------------------------------------------------
    // Verifica se o e-mail foi preenchido
    // ----------------------------------------------------------

    if (emailController.text.trim().isEmpty) {
      mostrarMensagem('Digite o e-mail.');
      return;
    }

    // ----------------------------------------------------------
    // Verifica se a senha foi preenchida
    // ----------------------------------------------------------

    if (senhaController.text.isEmpty) {
      mostrarMensagem('Digite uma senha.');
      return;
    }

    // ----------------------------------------------------------
    // Verifica se a confirmação foi preenchida
    // ----------------------------------------------------------

    if (confirmarSenhaController.text.isEmpty) {
      mostrarMensagem('Confirme a senha.');
      return;
    }

    // ----------------------------------------------------------
    // Verifica se as duas senhas são iguais
    // ----------------------------------------------------------

    if (senhaController.text !=
        confirmarSenhaController.text) {

      mostrarMensagem('As senhas não são iguais.');
      return;
    }

    // ----------------------------------------------------------
    // Inicia o carregamento
    // ----------------------------------------------------------

    setState(() {
      carregando = true;
    });

    try {

      // --------------------------------------------------------
      // Envia os dados para a API PHP
      // --------------------------------------------------------

      final resultado =
      await ApiService.cadastrarUsuario(

        nome: nomeController.text.trim(),

        email: emailController.text.trim(),

        senha: senhaController.text,
      );

      // --------------------------------------------------------
      // Verifica se o cadastro foi realizado
      // --------------------------------------------------------

      if (resultado['sucesso'] == true) {

        mostrarMensagem(
          resultado['mensagem'] ??
              'Usuário cadastrado com sucesso!',
        );

        // Limpa os campos depois do cadastro
        nomeController.clear();
        emailController.clear();
        senhaController.clear();
        confirmarSenhaController.clear();

      } else {

        mostrarMensagem(
          resultado['mensagem'] ??
              'Não foi possível cadastrar o usuário.',
        );
      }

    } catch (e) {

      // --------------------------------------------------------
      // Erro inesperado
      // --------------------------------------------------------

      mostrarMensagem(
        'Erro ao cadastrar usuário.',
      );

      debugPrint(
        'Erro no cadastro: $e',
      );

    } finally {

      // --------------------------------------------------------
      // Finaliza o carregamento
      // --------------------------------------------------------

      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // ============================================================
  // MOSTRAR MENSAGEM
  // ============================================================

  void mostrarMensagem(String mensagem) {

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  // ============================================================
  // LIBERAR OS CONTROLLERS
  // ============================================================

  @override
  void dispose() {

    nomeController.dispose();

    emailController.dispose();

    senhaController.dispose();

    confirmarSenhaController.dispose();

    super.dispose();
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // --------------------------------------------------------
      // BARRA SUPERIOR
      // --------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Cadastro de usuário',
        ),
      ),

      // --------------------------------------------------------
      // CONTEÚDO
      // --------------------------------------------------------

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: SizedBox(

            width: 500,

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [

                // ------------------------------------------------
                // ÍCONE
                // ------------------------------------------------

                const Icon(
                  Icons.person_add,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(
                  height: 20,
                ),

                // ------------------------------------------------
                // TÍTULO
                // ------------------------------------------------

                const Text(
                  'Cadastrar novo usuário',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ------------------------------------------------
                // NOME
                // ------------------------------------------------

                TextField(

                  controller: nomeController,

                  decoration: const InputDecoration(

                    labelText:
                    'Nome completo',

                    hintText:
                    'Digite o nome completo',

                    border:
                    OutlineInputBorder(),

                    prefixIcon:
                    Icon(Icons.person),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ------------------------------------------------
                // E-MAIL
                // ------------------------------------------------

                TextField(

                  controller: emailController,

                  keyboardType:
                  TextInputType.emailAddress,

                  decoration: const InputDecoration(

                    labelText:
                    'E-mail',

                    hintText:
                    'Digite o e-mail',

                    border:
                    OutlineInputBorder(),

                    prefixIcon:
                    Icon(Icons.email),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ------------------------------------------------
                // SENHA
                // ------------------------------------------------

                TextField(

                  controller: senhaController,

                  obscureText: true,

                  decoration: const InputDecoration(

                    labelText:
                    'Senha',

                    hintText:
                    'Digite uma senha',

                    border:
                    OutlineInputBorder(),

                    prefixIcon:
                    Icon(Icons.lock),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ------------------------------------------------
                // CONFIRMAR SENHA
                // ------------------------------------------------

                TextField(

                  controller:
                  confirmarSenhaController,

                  obscureText: true,

                  decoration: const InputDecoration(

                    labelText:
                    'Confirmar senha',

                    hintText:
                    'Digite a senha novamente',

                    border:
                    OutlineInputBorder(),

                    prefixIcon:
                    Icon(Icons.lock),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // ------------------------------------------------
                // BOTÃO
                // ------------------------------------------------

                ElevatedButton.icon(

                  onPressed:
                  carregando
                      ? null
                      : cadastrarUsuario,

                  icon: carregando

                      ? const SizedBox(
                    width: 18,
                    height: 18,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )

                      : const Icon(
                    Icons.person_add,
                  ),

                  label: Text(

                    carregando
                        ? 'Cadastrando...'
                        : 'Cadastrar usuário',
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