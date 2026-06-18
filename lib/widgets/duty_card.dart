import 'package:flutter/material.dart';
import '../models/duty_task_model.dart';
import '../utils/constants.dart';

class DutyCard extends StatelessWidget {
  final DutyTask duty;
  final bool isAdminView;

  final VoidCallback? onUploadSingleProof;
  final VoidCallback? onDeleteSingleProof;

  final Function(int checklistIndex)? onUploadChecklistProof;
  final Function(int checklistIndex)? onDeleteChecklistProof;

  const DutyCard({
    super.key,
    required this.duty,
    required this.isAdminView,
    this.onUploadSingleProof,
    this.onDeleteSingleProof,
    this.onUploadChecklistProof,
    this.onDeleteChecklistProof,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Text(
              duty.dutyType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              duty.time.isEmpty ? duty.day : "${duty.day} • ${duty.time}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 4),

            Text("Area / Role: ${duty.location}"),

            const SizedBox(height: 4),

            Text("Teacher: ${duty.teacherName}"),

            const Divider(height: 24),

            /// STATUS
            Row(
              children: [
                Icon(
                  duty.isCompleted
                      ? Icons.check_circle
                      : Icons.pending_actions,
                  color: duty.isCompleted
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  duty.isCompleted
                      ? "Completed"
                      : "Pending",
                  style: TextStyle(
                    color: duty.isCompleted
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              duty.progressText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            if (duty.proofMode == ProofMode.checklistImages)
              _buildChecklistSection(),

            if (duty.proofMode == ProofMode.singleImage)
              _buildSingleImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImageSection() {
    final hasProof = duty.singleProofImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasProof)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              duty.singleProofImageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Text("Unable to load image"),
                  ),
                );
              },
            ),
          ),

        if (!isAdminView) ...[
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: onUploadSingleProof,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    hasProof
                        ? "Resubmit Proof"
                        : "Upload Proof",
                  ),
                ),
              ),

              if (hasProof) ...[
                const SizedBox(width: 8),

                IconButton(
                  onPressed: onDeleteSingleProof,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Checklist & Proof Upload",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 10),

        ...List.generate(
          duty.checklist.length,
          (index) {
            final item = duty.checklist[index];

            final proofPath =
                duty.checklistProofImages[index];

            final hasProof = proofPath != null;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasProof
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasProof
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: hasProof
                            ? Colors.green
                            : Colors.grey,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(item),
                      ),
                    ],
                  ),

                  if (hasProof) ...[
                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8),
                      child: Image.network(
                        proofPath,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return Container(
                            height: 140,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Text(
                                "Unable to load image",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  if (!isAdminView) ...[
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.accent,
                              foregroundColor:
                                  Colors.black,
                            ),
                            onPressed: () =>
                                onUploadChecklistProof
                                    ?.call(index),
                            icon: const Icon(
                              Icons.camera_alt,
                            ),
                            label: Text(
                              hasProof
                                  ? "Resubmit Image"
                                  : "Upload Image",
                            ),
                          ),
                        ),

                        if (hasProof) ...[
                          const SizedBox(width: 8),

                          IconButton(
                            onPressed: () =>
                                onDeleteChecklistProof
                                    ?.call(index),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}