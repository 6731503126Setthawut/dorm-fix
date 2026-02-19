import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomController = TextEditingController(text: '301');
  RequestCategory _selectedCategory = RequestCategory.other;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    context.read<RequestProvider>().addRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          roomNumber: _roomController.text.trim(),
        );

    setState(() => _isSubmitting = false);
    if (mounted) {
      _showSuccessAndPop();
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Request submitted successfully!',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF34A853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('New Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              title: 'Category',
              child: _buildCategoryGrid(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Room Number',
              child: TextFormField(
                controller: _roomController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 301',
                  prefixIcon:
                      Icon(Icons.meeting_room_outlined, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter room number' : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Issue Title',
              child: TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Air conditioner not working',
                  prefixIcon: Icon(Icons.title_rounded, size: 20),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a title'
                    : v.trim().length < 5
                        ? 'Title is too short'
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Description',
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the issue in detail — when it started, what you\'ve tried, etc.',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please describe the issue'
                    : v.trim().length < 20
                        ? 'Please provide more detail (min 20 chars)'
                        : null,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Submit Request'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Your request will be reviewed by maintenance staff.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202124),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: RequestCategory.values
          .map((cat) => _CategoryTile(
                category: cat,
                isSelected: _selectedCategory == cat,
                onTap: () => setState(() => _selectedCategory = cat),
              ))
          .toList(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final RequestCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A73E8).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A73E8)
                : const Color(0xFFDADCE0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFF80868B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}