import 'package:flutter/material.dart';
import 'package:medikiosk/app/design_tokens.dart';

class AbhaAccountSelector extends StatelessWidget {
  final List<dynamic> accounts;
  final Function(Map<String, dynamic> selectedAccount) onAccountSelected;

  const AbhaAccountSelector({
    super.key,
    required this.accounts,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.primary50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_box_outlined,
                  color: DesignTokens.primary700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select ABHA Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.neutral950,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Multiple ABHA IDs found linked to this phone number',
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignTokens.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final account = accounts[index] as Map<String, dynamic>;
                final name = account['fullName'] ?? account['name'] ?? 'Patient';
                final abhaId = account['abhaId'] ?? 'ABHA ID Not Found';
                final gender = account['gender'] ?? '';
                final dob = account['dateOfBirth'] ?? '';

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onAccountSelected(account);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DesignTokens.neutral50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DesignTokens.neutral200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: DesignTokens.primary100,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'P',
                            style: const TextStyle(
                              color: DesignTokens.primary700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: DesignTokens.neutral950,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ABHA: $abhaId',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.primary700,
                                ),
                              ),
                              if (dob.isNotEmpty || gender.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '$gender ${dob.isNotEmpty ? "• DOB: $dob" : ""}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: DesignTokens.neutral500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: DesignTokens.neutral400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}