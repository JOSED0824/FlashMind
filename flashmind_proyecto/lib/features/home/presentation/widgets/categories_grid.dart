import 'package:flutter/material.dart';
import '../../../../../core/widgets/category_card.dart';
import '../../domain/entities/category_entity.dart';

class CategoriesGrid extends StatelessWidget {
  final List<CategoryEntity> categories;
  final void Function(CategoryEntity) onCategoryTap;

  const CategoriesGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            name: category.name,
            icon: IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
            totalTopics: category.totalTopics,
            gradientType: category.gradientType,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}
