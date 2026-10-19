import 'package:flutter/material.dart';
import 'cadastro_usuario_screen.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {

  // ============================================================
  // CONTROLES DOS CAMPOS
  // ============================================================

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController senhaController =
  TextEditingController();

  // ============================================================
  // CONTROLE DA SENHA
  // ============================================================

  bool senhaVisivel = false;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> fazerLogin() async {
    // Verifica se o e-mail foi preenchido
    if (emailController.text.trim().isEmpty) {
      mostrarMensagem('Digite o e-mail.');
      return;
    }

    // Verifica se a senha foi preenchida
    if (senhaController.text.isEmpty) {
      mostrarMensagem('Digite a senha.');
      return;
    }

    // Mostra uma mensagem enquanto o login é realizado
    mostrarMensagem('Entrando...');

    // Envia e-mail e senha para a API
    final resultado = await ApiService.loginUsuario(
      email: emailController.text.trim(),
      senha: senhaController.text,
    );

    // Verifica se o login foi realizado com sucesso
    if (resultado['sucesso'] == true) {
      final usuario = Usuario.fromJson(
        resultado['usuario'],
      );

      // Vai para o Dashboard
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            usuario: usuario,
          ),
        ),
      );

      return;
    }

    // Caso o login tenha falhado
    mostrarMensagem(
      resultado['mensagem'] ?? 'Não foi possível realizar o login.',
    );
  }

  // ============================================================
  // MENSAGEM
  // ============================================================

  void mostrarMensagem(String mensagem) {

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  // ============================================================
  // LIBERAR CONTROLLERS
  // ============================================================

  @override
  void dispose() {

    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Login',
        ),
      ),

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: SizedBox(

            width: 500,

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [

                // ==================================================
                // ÍCONE
                // ==================================================

                const Icon(
                  Icons.lock_outline,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // TÍTULO
                // ==================================================

                const Text(
                  'Entrar no sistema',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Entre com seu e-mail e senha.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================================
                // E-MAIL
                // ==================================================

                TextField(

                  controller: emailController,

                  keyboardType:
                  TextInputType.emailAddress,

                  decoration: const InputDecoration(

                    labelText: 'E-mail',

                    hintText:
                    'Digite seu e-mail',

                    border:
                    OutlineInputBorder(),

                    prefixIcon:
                    Icon(Icons.email),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ==================================================
                // SENHA
                // ==================================================

                TextField(

                  controller: senhaController,

                  obscureText: !senhaVisivel,

                  decoration: InputDecoration(

                    labelText: 'Senha',

                    hintText:
                    'Digite sua senha',

                    border:
                    const OutlineInputBorder(),

                    prefixIcon:
                    const Icon(Icons.lock),

                    suffixIcon: IconButton(

                      icon: Icon(
                        senhaVisivel
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {

                        setState(() {

                          senhaVisivel =
                          !senhaVisivel;

                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // ==================================================
                // BOTÃO ENTRAR
                // ==================================================

                ElevatedButton.icon(

                  onPressed: fazerLogin,

                  icon: const Icon(
                    Icons.login,
                  ),

                  label: const Text(
                    'Entrar',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}