import 'package:flutter/material.dart';
import '../screens/chat_bot_page.dart';

/// Expandable floating chat panel. Initially shows a small tab; tap or drag up
/// to expand the chat. Tap the tab to toggle open/close.
class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton> with SingleTickerProviderStateMixin {
  // Height fraction of the screen occupied by the panel (0.0..1.0)
  double _fraction = 0.0; // 0 = collapsed, 0.6 = expanded
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_fraction == 0.0) {
        _fraction = 0.6;
        _anim.forward();
      } else {
        _fraction = 0.0;
        _anim.reverse();
      }
    });
  }

  void _onDragUpdate(DragUpdateDetails details, BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final delta = -details.delta.dy / h; // dragging up increases fraction
    setState(() {
      _fraction = (_fraction + delta).clamp(0.0, 0.95);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    // settle to nearest state
    setState(() {
      if (_fraction > 0.35) {
        _fraction = 0.6;
        _anim.forward();
      } else {
        _fraction = 0.0;
        _anim.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final panelH = _fraction * screenH;

    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onVerticalDragUpdate: (d) => _onDragUpdate(d, context),
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: panelH > 64 ? panelH : 56,
          width: panelH > 64 ? MediaQuery.of(context).size.width * 0.9 : 56,
          decoration: BoxDecoration(
            color: panelH > 64 ? Colors.white : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: panelH > 64
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      // Drag handle / header
                      Container(
                        height: 36,
                        color: Colors.grey.shade100,
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Container(width: 36, height: 6, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Чат-бот', style: TextStyle(fontWeight: FontWeight.bold))),
                            IconButton(icon: const Icon(Icons.close), onPressed: _toggle),
                          ],
                        ),
                      ),
                      Expanded(child: SafeArea(child: ChatBotPage())),
                    ],
                  ),
                )
              : InkWell(
                  onTap: _toggle,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: Icon(Icons.chat_bubble, color: Colors.white),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
