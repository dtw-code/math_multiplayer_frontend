import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'package:provider/provider.dart';

class AnswerInputView extends StatefulWidget {
  const AnswerInputView({super.key});

  @override
  State<AnswerInputView> createState() => _AnswerInputViewState();
}

class _AnswerInputViewState extends State<AnswerInputView> {
  final _controller = TextEditingController();
  Timer? _timer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final state = context.read<GameService>().state;
      if (!mounted) return;
      final left =
          state.roundDurationSec * 1000 -
          (DateTime.now().millisecondsSinceEpoch - state.serverTimestamp);
      if (left <= 0) {
        _submit();
      } else {
        setState(() {});
      }
    });
  }

  void _submit() {
    if (_submitted) return;
    _submitted = true;
    context.read<GameService>().submitAnswer(
      int.tryParse(_controller.text.trim()) ?? 0,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameService>().state;
    final left =
        ((state.roundDurationSec * 1000 -
                    (DateTime.now().millisecondsSinceEpoch -
                        state.serverTimestamp)) /
                1000)
            .ceil()
            .clamp(0, state.roundDurationSec);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Text(
              '$left',
              style: const TextStyle(color: Color(0xFF81F1FB), fontSize: 32),
            ),
            const SizedBox(height: 60),
            const Text(
              'ANSWER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              enabled: !_submitted,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 28),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF334A4D),
                border: OutlineInputBorder(),
                hintText: 'Sum',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitted ? null : _submit,
              child: Text(_submitted ? 'WAITING...' : 'SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}
