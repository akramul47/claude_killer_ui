import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../constants/app_config.dart';

class ApiKeyDialog extends StatefulWidget {
  final Function(String) onApiKeySubmitted;

  const ApiKeyDialog({super.key, required this.onApiKeySubmitted});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key,
                  color: AppColors.darkBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'API Configuration',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (!AppConfig.useMockApi)
              Text(
                'Enter your Claude API key to enable real AI conversations:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              )
            else
              Text(
                'Currently using mock API for demonstration. You can still enter your API key for future use:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _controller,
              obscureText: _isObscured,
              decoration: InputDecoration(
                hintText: 'sk-ant-api03-...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textGray.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.mediumBlue.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.darkBlue),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textGray,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                ElevatedButton(
                  onPressed: () {
                    final apiKey = _controller.text.trim();
                    if (apiKey.isNotEmpty) {
                      widget.onApiKeySubmitted(apiKey);
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, Function(String) onApiKeySubmitted) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ApiKeyDialog(onApiKeySubmitted: onApiKeySubmitted),
    );
  }
}
