import 'package:flutter/material.dart';

class NutriscoreTooltipWidget extends StatelessWidget {
  const NutriscoreTooltipWidget({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nutri-Score',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "À quoi sert le Nutri-Score ?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Voici une définition du Nutri-Score. Il offre aux consommateurs une information claire et aisément compréhensible sur la qualité nutritionnelle globale d'un produit, directement sur l'emballage, facilitant ainsi les choix lors des achats. Cette étiquette permet de comparer aisément les aliments et d'opter pour ceux ayant une meilleure valeur nutritionnelle.\n\nCe repère visuel s'inspire des travaux de l'équipe du Pr Serge Hercberg. Le logo utilise une gamme de cinq couleurs, allant du vert foncé au orange foncé, et est associé à des lettres de A (indiquant la \"meilleure qualité nutritionnelle\") à E (représentant la \"qualité nutritionnelle la moins bonne\").",
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // This widget is not meant to be rendered directly
  }
}
