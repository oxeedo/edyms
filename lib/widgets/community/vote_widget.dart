import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';

class VoteWidget extends StatefulWidget {
  final String type;
  final int id;
  final int initialVotes;
  final int initialUserVote;

  const VoteWidget({
    super.key,
    required this.type,
    required this.id,
    required this.initialVotes,
    required this.initialUserVote,
  });

  @override
  State<VoteWidget> createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  late int _votes;
  late int _userVote;
  bool _isVoting = false;
  final CommunityService _service = CommunityService();

  @override
  void initState() {
    super.initState();
    _votes = widget.initialVotes;
    _userVote = widget.initialUserVote;
  }

  Future<void> _handleVote(int voteValue) async {
    if (_isVoting) return;

    final int originalUserVote = _userVote;
    final int originalVotes = _votes;

    int nextUserVote = voteValue;
    if (_userVote == voteValue) {
      nextUserVote = 0; // Toggle off
    }

    setState(() {
      _userVote = nextUserVote;
      _votes = originalVotes - originalUserVote + nextUserVote;
      _isVoting = true;
    });

    try {
      await _service.vote(widget.type, widget.id, nextUserVote);
      if (mounted) {
        setState(() => _isVoting = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userVote = originalUserVote;
          _votes = originalVotes;
          _isVoting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(
            _userVote == 1 ? Icons.arrow_upward : Icons.arrow_upward_outlined,
            size: 18,
            color: _userVote == 1
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getTextColor(context).withValues(alpha: 0.5),
          ),
          onPressed: () => _handleVote(1),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 4),
        Text(
          '$_votes',
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            _userVote == -1
                ? Icons.arrow_downward
                : Icons.arrow_downward_outlined,
            size: 18,
            color: _userVote == -1
                ? Colors.red
                : AppTheme.getTextColor(context).withValues(alpha: 0.5),
          ),
          onPressed: () => _handleVote(-1),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
