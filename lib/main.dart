import 'dart:convert'; // Importe o pacote dart:convert
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ContatoApp());
}

class ContatoApp extends StatelessWidget {
  const ContatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TelaContato(),
    );
  }
}

class TelaContato extends StatefulWidget {
  const TelaContato({super.key});

  @override
  State<TelaContato> createState() => _TelaContatonState();
}

class _TelaContatonState extends State<TelaContato> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  List<Contato> _contatos = [];

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  void _carregarContatos() async {
    final prefs = await SharedPreferences.getInstance();
    final contatosJson = prefs.getStringList('contatos') ?? [];

    setState(() {
      // Carrega contatos a partir do SharedPreferences
      _contatos = contatosJson.map((jsonString) {
        Map<String, dynamic> json = jsonDecode(jsonString);
        return Contato.fromJson(json);
      }).toList();
    });
  }

  void _salvarContatos() async {
    final prefs = await SharedPreferences.getInstance();
    final contatosJson = _contatos.map((contato) {
      return jsonEncode(contato.toJson()); // Converte o mapa em uma string JSON
    }).toList();
    prefs.setStringList('contatos', contatosJson);
  }

  void _adicionarContato() {
    setState(() {
      final novoContato = Contato(
        nome: _nomeController.text,
        telefone: _telefoneController.text,
      );

      if (novoContato.isValid()) {
        // Adiciona um novo contato à lista e salva
        _contatos.add(novoContato);
        _nomeController.clear();
        _telefoneController.clear();
        _salvarContatos();
      }
    });
  }

  void _removerContato(int index) {
    setState(() {
      // Remove um contato da lista e salva
      _contatos.removeAt(index);
      _salvarContatos();
    });
  }

  void _editarContato(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: _contatos[index].nome),
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  setState(() {
                    _contatos[index].nome = value;
                  });
                },
              ),
              TextField(
                controller:
                    TextEditingController(text: _contatos[index].telefone),
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (value) {
                  setState(() {
                    _contatos[index].telefone = value;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                // Salva as alterações no contato e fecha o diálogo
                _salvarContatos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Contatos'),
      ),
      body: ListView.builder(
        itemCount: _contatos.length,
        itemBuilder: (context, index) {
          final contato = _contatos[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/batman.png'), // Substitua pelo caminho da imagem do avatar
              radius: 30,
            ),
            title: Text(contato.nome),
            subtitle: Text(contato.telefone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editarContato(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removerContato(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Adicionar Contato'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Adicionar'),
                    onPressed: () {
                      _adicionarContato();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Contato {
  String nome;
  String telefone;

  Contato({required this.nome, required this.telefone});

  bool isValid() {
    return nome.isNotEmpty && telefone.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'telefone': telefone,
    };
  }

  factory Contato.fromJson(Map<String, dynamic> json) {
    return Contato(
      nome: json['nome'],
      telefone: json['telefone'],
    );
  }
}
