import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('À propos'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consommer Tunisien',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cette application vous permet de vérifier si un produit est fabriqué en Tunisie en scannant son code-barres.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comment ça marche ?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Icon(
                            Icons.qr_code_scanner,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text('Scannez un code-barres'),
                          subtitle: const Text(
                            'Utilisez la caméra pour scanner le code-barres d\'un produit',
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text('Vérification'),
                          subtitle: const Text(
                            'L\'application vérifie si le produit est fabriqué en Tunisie',
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.info,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: const Text('Informations'),
                          subtitle: const Text(
                            'Consultez les détails du produit si disponibles',
                          ),
                        ),
                      ],
                    ),
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
