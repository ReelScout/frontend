import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/dto/request/verification_decision_request_dto.dart';
import 'package:frontend/dto/response/verification_request_response_dto.dart';
import 'package:frontend/services/verification_service.dart';

class VerificationRequestsPage extends StatefulWidget {
  const VerificationRequestsPage({super.key});

  @override
  State<VerificationRequestsPage> createState() => _VerificationRequestsPageState();
}

class _VerificationRequestsPageState extends State<VerificationRequestsPage> {
  late final VerificationService _service;
  bool _loading = true;
  String? _error;
  List<VerificationRequestResponseDto> _items = const [];

  @override
  void initState() {
    super.initState();
    final dio = getIt<Dio>();
    _service = VerificationService(
      dio,
      baseUrl: "${dio.options.baseUrl}/user/verification",
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.listPendingRequests();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _approve(int id) async {
    try {
      await _service.approve(id);
      if (!mounted) return;
      setState(() {
        _items = _items.where((r) => r.id != id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: $e')),
      );
    }
  }

  Future<void> _reject(int id) async {
    final reason = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        bool submitting = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Reject request'),
              content: TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Reason (optional)'
                ),
                enabled: !submitting,
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.of(context).pop<String?>(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () {
                          setStateDialog(() => submitting = true);
                          Navigator.of(context).pop<String?>(controller.text.trim());
                        },
                  child: submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Reject'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || reason == null) return;
    try {
      await _service.reject(
        id,
        VerificationDecisionRequestDto(reason: reason.isEmpty ? null : reason),
      );
      if (!mounted) return;
      setState(() {
        _items = _items.where((r) => r.id != id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification requests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No pending requests')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final r = _items[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            r.requesterUsername,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('PENDING'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if ((r.message ?? '').isNotEmpty) ...[
                                      Text(r.message!),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      'Created: ${r.createdAt.toLocal()}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _approve(r.id),
                                            icon: const Icon(Icons.check),
                                            label: const Text('Approve'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _reject(r.id),
                                            icon: const Icon(Icons.close),
                                            label: const Text('Reject'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

