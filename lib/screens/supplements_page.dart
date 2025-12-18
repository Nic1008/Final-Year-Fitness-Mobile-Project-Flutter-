import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  State<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
  String selectedCategory = "All";

  final List<Map<String, String>> supplements = [
    {
      "name": "Whey Protein",
      "price": "RM380",
      "category": "Protein",
      "image": "https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/5bb2aa884e16d4b5f4d2f5bc3b73fb78362b2faf/proteinimg/Whey%20Protein.png",
      "url": "https://shopee.com.my/Optimum-Nutrition-100-ORIGINAL-ON-gold-standard-whey-5lbs-i.55940991.905613857?extraParams=%7B%22display_model_id%22%3A187914699623%2C%22model_selection_logic%22%3A3%7D&sp_atk=06c3763b-faa6-4c45-9908-f3cbbc437cba&xptdk=06c3763b-faa6-4c45-9908-f3cbbc437cba"
    },
    {
      "name": "Creatine Monohydrate",
      "price": "RM99",
      "category": "Creatine",
      "image": "https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/5bb2aa884e16d4b5f4d2f5bc3b73fb78362b2faf/proteinimg/creatine.png",
      "url": "https://shopee.com.my/Optimum-Nutrition-Micronized-Creatine-Powder-Monohydrate-Unflavored-Strength-Endurance-Muscle-i.23767.5989718?extraParams=%7B%22display_model_id%22%3A295859866%2C%22model_selection_logic%22%3A3%7D&sp_atk=dec07113-6fba-4f6e-ba3c-3db0c377aefc&xptdk=dec07113-6fba-4f6e-ba3c-3db0c377aefc"
    },
    {
      "name": "BCAA Amino",
      "price": "RM68",
      "category": "Amino",
      "image": "https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/main/proteinimg/Bcaa%20amino.png",
      "url": "https://shopee.com.my/RULE-1-Essential-Amino-9-(30-Servings)-i.1352122896.26264193975?extraParams=%7B%22display_model_id%22%3A157503353615%2C%22model_selection_logic%22%3A3%7D&sp_atk=8a980eab-04f5-4547-a226-df300debeb8a&xptdk=8a980eab-04f5-4547-a226-df300debeb8a"
    },
  ];

  void _openShopee(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == "All"
        ? supplements
        : supplements.where((s) => s["category"] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text("Supplements Store"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [
          // CATEGORY FILTER
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                categoryChip("All"),
                categoryChip("Protein"),
                categoryChip("Creatine"),
                categoryChip("Amino"),
              ],
            ),
          ),

          // GRID VIEW OF PRODUCTS
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 240,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return GestureDetector(
                  onTap: () => _openShopee(item["url"]!),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(
                            item["image"]!,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"]!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["price"]!,
                                style: const TextStyle(
                                  color: Color(0xFFFE8D3A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORY CHIP WIDGET
  Widget categoryChip(String label) {
    final isSelected = label == selectedCategory;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFE8D3A) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
