import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/features/home/models/offer.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;

  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER : titre + type de contrat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.business_center_rounded, color: theme.primaryColor, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    offer.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (offer.contractType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      offer.contractType!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Entreprise / Source
            Row(
              children: [
                Icon(Icons.apartment, color: Colors.grey.shade500, size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    offer.companyDescription ?? offer.source,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (offer.secteur != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text(offer.secteur!, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Lieu / Date de publication
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey.shade500, size: 18),
                const SizedBox(width: 5),
                Text(
                  offer.location ?? "Non renseigné",
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 16),
                const SizedBox(width: 2),
                Text(
                  offer.publishedAt != null
                      ? DateFormat('dd MMM y', 'fr_FR').format(DateTime.parse(offer.publishedAt!))
                      : 'Date inconnue',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // DESCRIPTION
            if (offer.description != null)
              Text(
                offer.description!,
                style: theme.textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 14),
            // Actions : Lien + Source
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Source: ${offer.source}",
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Ouvre le lien dans un navigateur
                    // Utilise url_launcher ou équivalent
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text("Voir l’offre"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}