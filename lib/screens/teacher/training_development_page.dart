import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/training_service.dart';


class TrainingDevelopmentPage extends StatelessWidget {
  const TrainingDevelopmentPage({super.key});

  // Palet warna konsisten
  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    final TrainingService provider = context.watch<TrainingService>();

    if (!provider.isLoaded) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: navy),
        ),
      );
    }

    final kpi = provider.kpi;
    final history = provider.history;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. Header Premium
          _buildAppBar(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. SUMMARY CARD (Status Training)
                  _buildSummaryCard(provider),
                  const SizedBox(height: 24),

                  // 3. KPI CHECKLIST
                  const Text(
                    'Training KPI Checklist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistContainer(provider, kpi),
                  const SizedBox(height: 32),

                  // 4. TRAINING HISTORY
                  const Text(
                    'Training History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // LIST HISTORY
          if (history.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No training records found.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = history[index];
                    return _buildHistoryCard(item);
                  },
                  childCount: history.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: navyLight.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withOpacity(0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Training & Dev',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your professional growth',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TrainingService provider) {
    final bool isMet = provider.hasMetMinimum;
    final Color mainColor = isMet ? Colors.green.shade600 : Colors.amber.shade600;
    final Color bgColor = isMet ? Colors.green.shade50 : Colors.amber.shade50;
    final Color borderColor = isMet ? Colors.green.shade200 : Colors.amber.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
              ],
            ),
            child: Icon(
              isMet ? Icons.verified_rounded : Icons.info_outline_rounded,
              color: mainColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Training This Year: ${provider.totalTrainingThisYear}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isMet ? Colors.green.shade800 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMet 
                      ? 'Minimum requirement met (3/year)' 
                      : 'Has not met the minimum 3 trainings/year',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isMet ? Colors.green.shade700 : Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistContainer(TrainingService provider, dynamic kpi) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildChecklistTile(
              title: 'Attend required training (min 3 per year)',
              value: kpi.attendRequired,
              onChanged: (val) => provider.toggleChecklist('attend', val ?? false),
              isAutoCalculated: true,
            ),
            const Divider(height: 1),
            _buildChecklistTile(
              title: 'Applies knowledge from training',
              value: kpi.appliesKnowledge,
              onChanged: (val) => provider.toggleChecklist('applies', val ?? false),
            ),
            const Divider(height: 1),
            _buildChecklistTile(
              title: 'Shares learning with team',
              value: kpi.sharesLearning,
              onChanged: (val) => provider.toggleChecklist('shares', val ?? false),
            ),
            const Divider(height: 1),
            _buildChecklistTile(
              title: 'Improves teaching skills',
              value: kpi.improvesSkills,
              onChanged: (val) => provider.toggleChecklist('improves', val ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isAutoCalculated = false,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isAutoCalculated ? Colors.grey.shade700 : (value ? navy : Colors.black87),
        ),
      ),
      subtitle: isAutoCalculated 
          ? Text('Auto-calculated based on history', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)) 
          : null,
      value: value,
      onChanged: isAutoCalculated ? null : onChanged,
      activeColor: gold,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: navyLight.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.school_rounded, color: navyLight, size: 24),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: navy,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(item.date, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(item.organizer, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}