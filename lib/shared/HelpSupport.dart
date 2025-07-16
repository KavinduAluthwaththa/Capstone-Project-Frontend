import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<FAQ> _faqs = [
    FAQ(
      question: "How do I identify plant diseases using the app?",
      answer:
          "Go to the Disease Identification section, take a clear photo of the affected plant part, select your crop type, and tap 'Analyze'. Our AI will provide diagnosis and treatment recommendations.",
    ),
    FAQ(
      question: "How accurate is the crop recommendation system?",
      answer:
          "Our crop recommendation system uses advanced algorithms considering soil conditions, weather patterns, and regional data. Accuracy is typically 85-90%, but local conditions may vary.",
    ),
    FAQ(
      question: "Can I connect with agricultural experts through the app?",
      answer:
          "Yes! Use our AI Chatbot for instant agricultural advice, or contact nearby agricultural shops for expert consultation and supplies.",
    ),
    FAQ(
      question: "How do I place orders for agricultural supplies?",
      answer:
          "Browse the Shop List, select your preferred shop, view their inventory, and place orders directly through the app. You can track order status in 'My Orders'.",
    ),
    FAQ(
      question: "Is my personal and farm data secure?",
      answer:
          "Absolutely! We use industry-standard encryption and security measures to protect your data. Your information is never shared without your consent.",
    ),
    FAQ(
      question: "How do I update my profile information?",
      answer:
          "Go to Settings from your Profile page, where you can update your personal information, farm details, and app preferences.",
    ),
    FAQ(
      question:
          "What crops are supported by the disease identification feature?",
      answer:
          "Currently, we support potato, tomato, corn, apple, grape, and several other major crops. We're continuously adding more crop types based on user feedback.",
    ),
    FAQ(
      question: "How do I calculate fertilizer requirements?",
      answer:
          "Use the Fertilizer Calculator by entering your crop type, soil conditions, and farm area. The app will recommend optimal fertilizer types and quantities.",
    ),
    FAQ(
      question: "Can I use the app offline?",
      answer:
          "Some features like viewing saved crop data work offline, but disease identification, weather updates, and shop connectivity require an internet connection.",
    ),
    FAQ(
      question: "How do I reset my password?",
      answer:
          "On the login screen, tap 'Forgot Password', enter your registered email, and follow the instructions sent to your email to reset your password.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildContactSection(),
            const SizedBox(height: 20),
            _buildFAQSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone Contact
          _buildContactItem(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+94 11 234 5678',
            description: 'Available 24/7 for urgent agricultural queries',
            onTap: () => _makePhoneCall('+94112345678'),
          ),

          const SizedBox(height: 16),

          // Email Contact
          _buildContactItem(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@smartagri.lk',
            description: 'Get detailed help within 24 hours',
            onTap: () => _sendEmail('support@smartagri.lk'),
          ),

          const SizedBox(height: 16),

          // WhatsApp Contact
          _buildContactItem(
            icon: Icons.chat,
            title: 'WhatsApp Support',
            subtitle: '+94 77 123 4567',
            description: 'Quick assistance via WhatsApp',
            onTap: () => _openWhatsApp('+94771234567'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.green[700], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.green[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return FAQItem(faq: _faqs[index]);
            },
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    _copyToClipboard(phoneNumber, 'Phone number copied to clipboard');
  }

  void _sendEmail(String email) {
    _copyToClipboard(email, 'Email address copied to clipboard');
  }

  void _openWhatsApp(String phoneNumber) {
    _copyToClipboard(phoneNumber, 'WhatsApp number copied to clipboard');
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}

class FAQItem extends StatefulWidget {
  final FAQ faq;

  const FAQItem({super.key, required this.faq});

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.green[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.faq.answer,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
