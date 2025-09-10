import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:dio/dio.dart';
import 'package:frontend/dto/request/ban_user_request_dto.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/error_utils.dart';

class ReportedUsersPage extends StatefulWidget {
  const ReportedUsersPage({super.key});

  @override
  State<ReportedUsersPage> createState() => _ReportedUsersPageState();
}

class _ReportedUsersPageState extends State<ReportedUsersPage> {
  final _userService = getIt<UserService>();
  late Future<List<UserResponseDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _userService.listUsersReportedByModerators();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _userService.listUsersReportedByModerators();
    });
    await _future; // allow refresh indicators to complete
  }

  Future<void> _banUser(int id) async {
    final reason = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Permanent ban'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    try {
      await _userService.permanentlyBan(id, (reason == null || reason.isEmpty) ? null : BanUserRequestDto(reason: reason));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User permanently banned'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : 'Failed to ban user';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _unbanUser(int id) async {
    try {
      await _userService.unban(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unbanned'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : 'Failed to unban user';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported by Moderators'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<UserResponseDto>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final msg = snapshot.error is DioException ? mapDioError(snapshot.error as DioException) : 'Failed to load users';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(msg, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final items = snapshot.data ?? const <UserResponseDto>[];
            if (items.isEmpty) {
              return const Center(child: Text('No users reported by moderators'));
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final u = items[index];
                ImageProvider? avatar;
                if (u.base64Image != null && u.base64Image!.isNotEmpty) {
                  try {
                    avatar = MemoryImage(base64Decode(u.base64Image!));
                  } catch (_) {}
                }
                return ListTile(
                  leading: CircleAvatar(backgroundImage: avatar, child: avatar == null ? const Icon(Icons.person) : null),
                  title: Text(u.username),
                  subtitle: Text(u.email),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _banUser(u.id),
                        icon: const Icon(Icons.gavel_outlined),
                        label: const Text('Ban'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _unbanUser(u.id),
                        icon: const Icon(Icons.lock_open_outlined),
                        label: const Text('Unban'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
