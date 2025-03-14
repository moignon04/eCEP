import 'package:flutter/material.dart';

class PaymentConfirmationPage extends StatelessWidget {
  final String paymentReference = "PAY123456789";
  final String paymentDate = "07/12/2024";
  final double amountPaid = 49.99;

  final List<Map<String, String>> trendingItems = [
    {"title": "Article 1", "image": "https://via.placeholder.com/150"},
    {"title": "Article 2", "image": "https://via.placeholder.com/150"},
    {"title": "Article 3", "image": "https://via.placeholder.com/150"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Réussi"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message de confirmation
            Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 40),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Votre paiement a été effectué avec succès !",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Référence : $paymentReference"),
                    Text("Date : $paymentDate"),
                    Text("Montant : \$${amountPaid.toStringAsFixed(2)}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Titre Tendances
            const Text(
              "Tendances pour vous",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Section des Tendances
            Expanded(
              child: GridView.builder(
                itemCount: trendingItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = trendingItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            item["image"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bouton Retour
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text("Retour à l'accueil", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}