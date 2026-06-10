import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vocabulary.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../data/countries.dart';

class CountrySelectionScreen extends ConsumerWidget {
  const CountrySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    // Only show countries that have vocabulary data
    final supportedCountries = countriesData
        .where((c) => vocabularyData.containsKey(c.id))
        .toList();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('select_country'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: supportedCountries.length,
        itemBuilder: (context, index) {
          final country = supportedCountries[index];
          final languageName = countryLanguageMap[country.id] ?? country.name;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.pop(context, country.id);
              },
              borderRadius: BorderRadius.circular(24),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          country.flagPath,
                          width: 60,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        l10n.translate(languageName),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded, 
                      color: secondaryTextColor.withValues(alpha: 0.3), 
                      size: 16
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
