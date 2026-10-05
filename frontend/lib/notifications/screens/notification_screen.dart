import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController _controller = NotificationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadNotifications();
    });
  }

  void _showReminderModal([AppNotification? notification]) {
    final isEditing = notification != null;
    final titleController = TextEditingController(text: notification?.title ?? '');
    final messageController = TextEditingController(text: notification?.message ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Reminder' : 'Add Custom Reminder',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
                    return;
                  }
                  try {
                    if (isEditing) {
                      await _controller.editReminder(
                        notification.id,
                        titleController.text.trim(),
                        messageController.text.trim(),
                      );
                    } else {
                      await _controller.addReminder(
                        titleController.text.trim(),
                        messageController.text.trim(),
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving reminder: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'Update Reminder' : 'Save Reminder',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Scaffold(
            backgroundColor: AppColors.pageBg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'Notifications',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.navy),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_alert_rounded, color: AppColors.emerald),
                  onPressed: () => _showReminderModal(),
                ),
              ],
            ),
            body: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              if (_controller.isLoading && _controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.emerald));
              }

              if (_controller.error != null && _controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Failed to load notifications', style: GoogleFonts.plusJakartaSans()),
                      TextButton(
                        onPressed: _controller.loadNotifications,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              if (_controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, color: Colors.grey.shade400, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.emerald,
                onRefresh: _controller.loadNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _controller.notifications[index];
                    return _buildNotificationItem(context, notification, _controller);
                  },
                ),
              );
            },
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, AppNotification notification, NotificationController controller) {
    
    // Determine icon based on title/type logic
    IconData iconData = Icons.notifications_rounded;
    Color iconColor = AppColors.emerald;
    Color bgColor = const Color(0xFFE8F5E9); // Light green
    
    final lowerTitle = notification.title.toLowerCase();
    if (lowerTitle.contains('book')) {
      iconData = Icons.menu_book_rounded;
      iconColor = const Color(0xFF6366F1);
      bgColor = const Color(0xFFE0E7FF);
    } else if (lowerTitle.contains('seat')) {
      iconData = Icons.chair_alt_rounded;
      iconColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFEF3C7);
    } else if (notification.type == 'REMINDER') {
      iconData = Icons.edit_note_rounded;
      iconColor = AppColors.emerald;
      bgColor = const Color(0xFFD1FAE5);
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        controller.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: GestureDetector(
        onTap: () {
          controller.markAsRead(notification.id);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? Colors.grey.shade100 : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              if (!notification.isRead)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 20, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.navy,
                              fontWeight: notification.isRead ? FontWeight.w700 : FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.emerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: GoogleFonts.plusJakartaSans(
                        color: notification.isRead ? AppColors.textMuted : AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(notification.createdAt),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (notification.type == 'REMINDER')
                          GestureDetector(
                            onTap: () => _showReminderModal(notification),
                            child: Text(
                              'Edit Reminder',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.emerald,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
