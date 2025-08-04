import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_config.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/multi_model_api_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => ApiKeyDialog(
        onApiKeySubmitted: (apiKey) {
          // Update the API key
          ApiKeys.setOpenAIApiKey(apiKey);
          setState(() {});
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'API key updated successfully!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF89A8B2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAiModelDialog() {
    showDialog(
      context: context,
      builder: (context) => MultiModelApiDialog(
        onApiKeysUpdated: () {
          setState(() {}); // Refresh UI to reflect changes
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF89A8B2).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF89A8B2),
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Settings",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF89A8B2),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // API Configuration Section
                  _buildSectionHeader('API Configuration'),
                  const SizedBox(height: 12),
                  
                  _buildSettingsCard(
                    icon: Icons.smart_toy,
                    title: 'AI Model Settings',
                    subtitle: 'Configure AI models and API keys',
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF89A8B2),
                      size: 16,
                    ),
                    onTap: _showAiModelDialog,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildSettingsCard(
                    icon: Icons.key,
                    title: 'OpenAI API Key (Legacy)',
                    subtitle: ApiKeys.hasOpenAIApiKey 
                        ? 'API key configured'
                        : 'No API key set',
                    trailing: Icon(
                      ApiKeys.hasOpenAIApiKey 
                          ? Icons.check_circle 
                          : Icons.warning,
                      color: ApiKeys.hasOpenAIApiKey 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                    onTap: _showApiKeyDialog,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildSettingsCard(
                    icon: Icons.science,
                    title: 'API Mode',
                    subtitle: AppConfig.useMockApi 
                        ? 'Mock API (Development)' 
                        : 'Live API (Production)',
                    trailing: Switch(
                      value: !AppConfig.useMockApi,
                      onChanged: null, // Disabled for now - would need app restart
                      activeColor: const Color(0xFF89A8B2),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Information Section
                  _buildSectionHeader('App Information'),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.info_outline,
                    title: 'Version',
                    value: AppConfig.appVersion,
                  ),

                  const SizedBox(height: 8),

                  _buildInfoCard(
                    icon: Icons.apps,
                    title: 'App Name',
                    value: AppConfig.appName,
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF89A8B2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF89A8B2).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: const Color(0xFF89A8B2),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quick Setup',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Get your API key from platform.openai.com\n'
                          '2. Tap "OpenAI API Key" above to enter it\n'
                          '3. Start chatting with your AI assistant!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF89A8B2),
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E1DA).withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF89A8B2).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF89A8B2).withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF89A8B2),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF89A8B2),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E1DA).withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89A8B2).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF89A8B2),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF89A8B2),
            ),
          ),
        ],
      ),
    );
  }
}
