import 'package:flutter/material.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/dto/request/promotion_decision_request_dto.dart';
import 'package:frontend/dto/response/promotion_request_response_dto.dart';
import 'package:frontend/model/role.dart';
import 'package:frontend/services/promotion_service.dart';

class PromotionRequestsPage extends StatefulWidget {
  const PromotionRequestsPage({super.key});

  @override
  State<PromotionRequestsPage> createState() => _PromotionRequestsPageState();
}

class _PromotionRequestsPageState extends State<PromotionRequestsPage>
    with TickerProviderStateMixin {
  late final PromotionService _service;
  TabController? _tabController;

  bool _loading = true;
  String? _error;

  List<PromotionRequestResponseDto> _verifiedItems = const [];
  List<PromotionRequestResponseDto> _moderatorItems = const [];

  @override
  void initState() {
    super.initState();
    _service = getIt<PromotionService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureTabsAndLoad();
  }

  void _configureTabsAndLoad() {
    // Fallback to DI role only if bloc not available in context
    Role? role;
    final bloc = context.read<UserProfileBloc?>();
    final state = bloc?.state;
    if (state is UserProfileLoaded) {
      role = state.user.role;
    } else {
      try {
        role = getIt<Role>();
      } catch (_) {}
    }
    final tabs = _tabsForRole(role);
    if (tabs.isEmpty) {
      _tabController?.dispose();
      _tabController = null;
    } else if (_tabController == null || _tabController!.length != tabs.length) {
      _tabController?.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    }
    _load(tabs: tabs);
  }

  List<_TabKind> _tabsForRole(Role? role) {
    if (role == Role.admin) return const [_TabKind.verified, _TabKind.moderator];
    if (role == Role.moderator) return const [_TabKind.verified];
    return const [];
  }

  Future<void> _load({required List<_TabKind> tabs}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (tabs.contains(_TabKind.verified)) {
        _verifiedItems = await _service.listPendingVerifiedRequests();
      } else {
        _verifiedItems = const [];
      }
      if (tabs.contains(_TabKind.moderator)) {
        _moderatorItems = await _service.listPendingModeratorRequests();
      } else {
        _moderatorItems = const [];
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _approve(_TabKind kind, int id) async {
    try {
      if (kind == _TabKind.verified) {
        await _service.approveVerified(id);
        _verifiedItems = _verifiedItems.where((r) => r.id != id).toList();
      } else {
        await _service.approveModerator(id);
        _moderatorItems = _moderatorItems.where((r) => r.id != id).toList();
      }
      if (!mounted) return;
      setState(() {});
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

  Future<void> _reject(_TabKind kind, int id) async {
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
                    border: OutlineInputBorder(), labelText: 'Reason (optional)'),
                enabled: !submitting,
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(context).pop<String?>(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () {
                          setStateDialog(() => submitting = true);
                          Navigator.of(context)
                              .pop<String?>(controller.text.trim());
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
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
      final dto =
          PromotionDecisionRequestDto(reason: reason.isEmpty ? null : reason);
      if (kind == _TabKind.verified) {
        await _service.rejectVerified(id, dto);
        _verifiedItems = _verifiedItems.where((r) => r.id != id).toList();
      } else {
        await _service.rejectModerator(id, dto);
        _moderatorItems = _moderatorItems.where((r) => r.id != id).toList();
      }
      if (!mounted) return;
      setState(() {});
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
    Role? role;
    final upState = context.watch<UserProfileBloc?>()?.state;
    if (upState is UserProfileLoaded) role = upState.user.role;
    final tabs = _tabsForRole(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotion requests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: tabs.isEmpty || _tabController == null
            ? null
            : TabBar(
                controller: _tabController!,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                tabs: [
                  if (tabs.contains(_TabKind.verified))
                    const Tab(text: 'Verified requests'),
                  if (tabs.contains(_TabKind.moderator))
                    const Tab(text: 'Moderator requests'),
                ],
              ),
      ),
      body: tabs.isEmpty || _tabController == null
          ? const Center(child: Text('No access to promotion requests'))
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 32),
                            const SizedBox(height: 8),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _load(tabs: tabs),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController!,
                      children: [
                        if (tabs.contains(_TabKind.verified))
                          _RequestsList(
                            items: _verifiedItems,
                            onApprove: (id) => _approve(_TabKind.verified, id),
                            onReject: (id) => _reject(_TabKind.verified, id),
                            onRefresh: () async => _load(tabs: tabs),
                            kind: _TabKind.verified,
                          ),
                        if (tabs.contains(_TabKind.moderator))
                          _RequestsList(
                            items: _moderatorItems,
                            onApprove: (id) => _approve(_TabKind.moderator, id),
                            onReject: (id) => _reject(_TabKind.moderator, id),
                            onRefresh: () async => _load(tabs: tabs),
                            kind: _TabKind.moderator,
                          ),
                      ],
                    ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

enum _TabKind { verified, moderator }

class _RequestsList extends StatelessWidget {
  const _RequestsList({
    required this.items,
    required this.onApprove,
    required this.onReject,
    required this.onRefresh,
    required this.kind,
  });

  final List<PromotionRequestResponseDto> items;
  final void Function(int id) onApprove;
  final void Function(int id) onReject;
  final Future<void> Function() onRefresh;
  final _TabKind kind;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No pending requests')),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = items[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.08),
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
                          onPressed: () => onApprove(r.id),
                          icon: const Icon(Icons.check),
                          label: Text(
                            kind == _TabKind.verified
                                ? 'Approve verification'
                                : 'Approve promotion',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => onReject(r.id),
                          icon: const Icon(Icons.close),
                          label: Text(
                            kind == _TabKind.verified
                                ? 'Reject verification'
                                : 'Reject promotion',
                          ),
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
    );
  }
}
