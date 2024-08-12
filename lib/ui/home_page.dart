import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'gif_page.dart'; // Importe a nova tela

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  int _offset = 0;
  List<dynamic> _gifs = [];
  bool _isLoading = false;
  String? _toastMessage;
  bool _showLoadMoreButton = false;
  String ? _errorText;

  Future<void> _getGifs({bool isInitial = false}) async {
    final String apiUrl = isInitial
        ? "https://api.giphy.com/v1/gifs/trending?api_key=5eLk9tzVJMdoErbqKMLGJqYfh6q59Opf&limit=25&offset=$_offset&rating=g&bundle=messaging_non_clips"
        : "https://api.giphy.com/v1/gifs/search?api_key=5eLk9tzVJMdoErbqKMLGJqYfh6q59Opf&q=$_search&limit=25&offset=$_offset&rating=g&lang=en&bundle=messaging_non_clips";

    setState(() {
      _isLoading = true;
    });

    final Uri uri = Uri.parse(apiUrl);

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodeResponse = json.decode(response.body);

        if (decodeResponse.containsKey('data') &&
            decodeResponse['data'] is List) {
          setState(() {
            if (isInitial) {
              _gifs = decodeResponse['data'];
              _showLoadMoreButton = false;
            } else {
              _gifs.addAll(decodeResponse['data']);
            }
            _isLoading = false;
            _toastMessage = _gifs.isEmpty
                ? 'Nenhum GIF encontrado.'
                : 'GIFs carregados com sucesso!';
          });
        } else {
          setState(() {
            _isLoading = false;
            _toastMessage = 'Erro: Dados da API inesperados.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _toastMessage = 'Erro na resposta da API: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _toastMessage = 'Erro ao buscar GIFs: $e';
      });
    }

    if (_toastMessage != null) {
      Fluttertoast.showToast(
        msg: _toastMessage!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getGifs(isInitial: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  errorText: _errorText,
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: _handleSearch,
            ),
          ),
          Expanded(
            child: _isLoading && _gifs.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5,
                    ),
                  )
                : _gifs.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum GIF encontrado.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Stack(
                        children: [
                          GridView.builder(
                            padding: EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _gifs.length,
                            itemBuilder: (context, index) {
                              final gif = _gifs[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GifPage(
                                        gifData: gif,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  // Função de compartilhamento para celular
                                  Share.share(
                                      gif['images']['fixed_height']['url']);
                                },
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: gif['images']['fixed_height']['url'],
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                          if (_showLoadMoreButton)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: ElevatedButton.icon(
                                onPressed: _loadMoreGifs,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black38,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                               // icon: Icon(Icons.add,color: Colors.white),
                                label: Text(
                                  'Carregar mais',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  void _loadMoreGifs() {
    setState(() {
      _offset += 25;
      _getGifs();
    });
  }
  void _handleSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        _errorText = 'Por favor, preencha o campo de pesquisa.';
      });
    } else {
      setState(() {
        _search = value;
        _offset = 0; // Reinicia o offset
        _gifs.clear(); // Limpa a lista de GIFs existentes
        _errorText = null; // Limpa a mensagem de erro
        _getGifs(); // Busca os novos GIFs
        _showLoadMoreButton = true; // Mostra o botão de carregar mais
      });
    }
  }

}
