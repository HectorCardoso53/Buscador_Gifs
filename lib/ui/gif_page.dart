import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  // Construtor com o parâmetro necessário
  const GifPage({super.key, required this.gifData});

  // Campo final inicializado no construtor
  final Map<String, dynamic> gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: TextStyle(color: Colors.white),
          gifData["title"] ??
              'GIF Details', // Garantia de título, caso 'title' não exista
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        // Dewfinindo a cor branca para meu icone
        actions: [
          IconButton(
            onPressed: () {
              //função de compartilhamento
              Share.share( gifData["images"]["fixed_height"]["url"]);
            },
            icon: Icon(
              Icons.share,
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(
          gifData["images"]["fixed_height"]["url"] ?? '',
          // Garantia de URL, caso 'url' não exista
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
