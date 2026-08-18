import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('MergeRequestApprovals', () {
    test('parses required count, approvers, and whether the user approved', () {
      final a = MergeRequestApprovals.fromJson(const {
        'approvals_required': 2,
        'user_has_approved': true,
        'approved_by': [
          {
            'user': {'id': 7, 'username': 'jungwon', 'name': 'Jungwon'},
          },
          {
            'user': {'id': 8, 'username': 'minsu', 'name': 'Minsu'},
          },
        ],
      });

      expect(a.approvalsRequired, 2);
      expect(a.userHasApproved, isTrue);
      expect(a.approvedBy.map((u) => u.username), ['jungwon', 'minsu']);
      expect(a.approvedCount, 2);
    });

    test('handles an empty approvals payload', () {
      final a = MergeRequestApprovals.fromJson(const {});
      expect(a.approvalsRequired, 0);
      expect(a.userHasApproved, isFalse);
      expect(a.approvedBy, isEmpty);
    });
  });
}
