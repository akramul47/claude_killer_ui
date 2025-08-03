import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/api_model.dart';
import '../services/api_factory.dart';

class MultiModelApiDialog extends StatefulWidget {
  final Function()? onApiKeysUpdated;

  const MultiModelApiDialog({
    super.key,
    this.onApiKeysUpdated,
  });

  @override
  State<MultiModelApiDialog> createState() => _MultiModelApiDialogState();
}

class _MultiModelApiDialogState extends State<MultiModelApiDialog> {
  final Map<ApiModel, TextEditingController> _controllers = {};
  final Map<ApiModel, bool> _obscureText = {};
  ApiModel _selectedModel = ApiModel.cohere;

  @override
  void initState() {
    super.initState();
    _selectedModel = ApiFactory.getCurrentModel();
    
    // Initialize controllers and obscure text for each model
    for (final model in ApiModel.values) {
      _controllers[model] = TextEditingController();
      _obscureText[model] = true;
    }
    
    _loadExistingKeys();
  }

  Future<void> _loadExistingKeys() async {
    for (final model in ApiModel.values) {
      final existingKey = await ApiFactory.getApiKey(model);
      if (existingKey != null && existingKey.isNotEmpty) {
        _controllers[model]?.text = existingKey;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAndClose() async {
    // Save all API keys
    for (final model in ApiModel.values) {
      final key = _controllers[model]?.text.trim() ?? '';
      if (key.isNotEmpty) {
        await ApiFactory.setApiKey(model, key);
      }
    }

    // Switch to selected model
    await ApiFactory.switchModel(_selectedModel);

    // Notify parent
    widget.onApiKeysUpdated?.call();

    // Close dialog
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFF1F0E8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF89A8B2),
                        Color(0xFFB3C8CF),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Model Settings',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Choose your AI model and configure API keys',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF89A8B2),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Model Selection
            Text(
              'Select AI Model',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Model Cards
            Expanded(
              child: ListView.builder(
                itemCount: ApiModel.values.length,
                itemBuilder: (context, index) {
                  final model = ApiModel.values[index];
                  final isSelected = _selectedModel == model;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF89A8B2).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF89A8B2) : const Color(0xFFB3C8CF).withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedModel = model;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<ApiModel>(
                                  value: model,
                                  groupValue: _selectedModel,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedModel = value!;
                                    });
                                  },
                                  activeColor: const Color(0xFF89A8B2),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            model.displayName,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2C3E50),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (model.isFree)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'FREE',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        'by ${model.provider}',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF89A8B2),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        model.description,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF89A8B2),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // API Key field (if not mock)
                            if (model != ApiModel.mock) ...[
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFB3C8CF).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _controllers[model],
                                  obscureText: _obscureText[model] ?? true,
                                  decoration: InputDecoration(
                                    hintText: model.apiKeyLabel,
                                    hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF89A8B2).withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        (_obscureText[model] ?? true) ? Icons.visibility : Icons.visibility_off,
                                        color: const Color(0xFF89A8B2),
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText[model] = !(_obscureText[model] ?? true);
                                        });
                                      },
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF2C3E50),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (model.getKeyUrl.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Get your key from ${model.getKeyUrl}',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF89A8B2).withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF89A8B2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF89A8B2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save & Use',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
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
}
