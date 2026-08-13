/**
 * Firestore Security Rules — Comprehensive static validation tests.
 *
 * Validates the rules file structure, required patterns, and key invariants
 * without needing the Firebase emulator. For runtime integration tests,
 * run: firebase emulators:exec './functions/node_modules/.bin/jest --forceExit __tests__/firestore_rules.test.js'
 */

const fs = require('fs');
const path = require('path');

const RULES = fs.readFileSync(
  path.resolve(__dirname, '..', '..', 'firestore.rules'),
  'utf8'
);

// ──────────────────────────────────────────────
// File integrity
// ──────────────────────────────────────────────
describe('firestore.rules — file integrity', () => {
  test('rules file exists and is non-empty', () => {
    expect(RULES.length).toBeGreaterThan(100);
  });

  test('rules_version is 2', () => {
    expect(RULES).toMatch(/rules_version\s*=\s*'2'/);
  });

  test('matches cloud.firestore service', () => {
    expect(RULES).toMatch(/service\s+cloud\.firestore/);
  });

  test('has database wildcard', () => {
    expect(RULES).toMatch(/match\s+\/databases\/\{database\}\/documents/);
  });
});

// ──────────────────────────────────────────────
// Default deny
// ──────────────────────────────────────────────
describe('firestore.rules — default deny', () => {
  test('has default deny-all rule for all documents', () => {
    expect(RULES).toMatch(/match\s+\/\{document=\*\*\}\s*\{[\s\S]*?allow\s+read,\s*write:\s*if\s+false/);
  });
});

// ──────────────────────────────────────────────
// Users collection
// ──────────────────────────────────────────────
describe('firestore.rules — users collection', () => {
  test('users/{userId} path exists', () => {
    expect(RULES).toMatch(/match\s+\/users\/\{userId\}/);
  });

  test('owner-only read access', () => {
    expect(RULES).toMatch(/request\.auth\.uid\s*==\s*userId/);
  });

  test('isProfileCreate and isProfileUpdate functions exist', () => {
    expect(RULES).toMatch(/function\s+isProfileCreate\(\)/);
    expect(RULES).toMatch(/function\s+isProfileUpdate\(\)/);
  });

  test('profileKeys includes essential fields', () => {
    const profileFields = [
      'firstName', 'lastName', 'email', 'age', 'photoUrl',
      'lastLoginDate', 'onboardingCompleted',
      'dailyGoalMinutes', 'dailyLessonsGoal', 'preferredLanguage',
      'referralSource', 'routeType', 'motivation', 'updatedAt',
    ];
    for (const field of profileFields) {
      expect(RULES).toContain(`'${field}'`);
    }
  });

  test('economic fields are NOT in profileKeys', () => {
    const economicFields = [
      'learning_gems', 'learning_total_gems', 'learning_total_xp',
      'learning_level', 'currentStreak', 'longestStreak',
      'shop_streak_shields', 'shop_purchased_xp_boosts',
      'shop_purchased_gem_multipliers', 'shop_purchased_luck_boosts',
      'lessonsCompleted', 'streak_last_activity',
      'streakFrozen',
    ];
    for (const field of economicFields) {
      expect(RULES).not.toMatch(new RegExp(`'${field}'`));
    }
  });

  test('nested sub-collections have write:if false', () => {
    expect(RULES).toContain('allow write: if false; // Server-only via Cloud Functions');
  });

  test('age validation: >= 13 and <= 120', () => {
    expect(RULES).toMatch(/data\.age\s*>=\s*13/);
    expect(RULES).toMatch(/data\.age\s*<=\s*120/);
  });

  test('firstName is string and size <= 50', () => {
    expect(RULES).toMatch(/data\.firstName is string/);
    expect(RULES).toMatch(/data\.firstName\.size\(\)\s*<=\s*50/);
  });

  test('lastName is string and size <= 50', () => {
    expect(RULES).toMatch(/data\.lastName is string/);
    expect(RULES).toMatch(/data\.lastName\.size\(\)\s*<=\s*50/);
  });

  test('email is string and size <= 254', () => {
    expect(RULES).toMatch(/data\.email is string/);
    expect(RULES).toMatch(/data\.email\.size\(\)\s*<=\s*254/);
  });

  test('photoUrl is string and size <= 500', () => {
    expect(RULES).toMatch(/data\.photoUrl is string/);
    expect(RULES).toMatch(/data\.photoUrl\.size\(\)\s*<=\s*500/);
  });

  test('onboardingCompleted is bool', () => {
    expect(RULES).toMatch(/data\.onboardingCompleted is bool/);
  });

  test('dailyGoalMinutes is int, >= 0, <= 480', () => {
    expect(RULES).toMatch(/data\.dailyGoalMinutes is int/);
    expect(RULES).toMatch(/data\.dailyGoalMinutes\s*>=\s*0/);
    expect(RULES).toMatch(/data\.dailyGoalMinutes\s*<=\s*480/);
  });

  test('dailyLessonsGoal is int, >= 0, <= 50', () => {
    expect(RULES).toMatch(/data\.dailyLessonsGoal is int/);
    expect(RULES).toMatch(/data\.dailyLessonsGoal\s*>=\s*0/);
    expect(RULES).toMatch(/data\.dailyLessonsGoal\s*<=\s*50/);
  });

  test('preferredLanguage is string and size <= 10', () => {
    expect(RULES).toMatch(/data\.preferredLanguage is string/);
    expect(RULES).toMatch(/data\.preferredLanguage\.size\(\)\s*<=\s*10/);
  });

  test('hasOnly(profileKeys) prevents arbitrary field writes', () => {
    expect(RULES).toMatch(/data\.keys\(\)\.hasOnly\(profileKeys\(\)\)/);
    expect(RULES).toMatch(/function\s+profileKeys\(\)/);
  });
});

// ──────────────────────────────────────────────
// Transaction logs
// ──────────────────────────────────────────────
describe('firestore.rules — transaction_logs', () => {
  test('transaction_logs path exists', () => {
    expect(RULES).toMatch(/match\s+\/transaction_logs\/\{logId\}/);
  });

  test('create/update/delete denied for clients', () => {
    expect(RULES).toMatch(/transaction_logs[\s\S]*?allow\s+create,\s*update,\s*delete:\s*if\s+false/);
  });

  test('read requires matching userId', () => {
    expect(RULES).toMatch(/transaction_logs[\s\S]*?allow\s+read[\s\S]*?resource\.data\.userId\s*==\s*request\.auth\.uid/);
  });
});

// ──────────────────────────────────────────────
// Payment logs (server-only)
// ──────────────────────────────────────────────
describe('firestore.rules — payment_logs (server-only)', () => {
  test('payment_logs path exists', () => {
    expect(RULES).toMatch(/match\s+\/payment_logs\/\{paymentId\}/);
  });

  test('all access denied', () => {
    expect(RULES).toMatch(/payment_logs[\s\S]*?allow\s+read,\s*write:\s*if\s+false/);
  });
});

// ──────────────────────────────────────────────
// Admins (server-only)
// ──────────────────────────────────────────────
describe('firestore.rules — admins (server-only)', () => {
  test('admins path exists', () => {
    expect(RULES).toMatch(/match\s+\/admins\/\{adminId\}/);
  });

  test('all access denied', () => {
    expect(RULES).toMatch(/admins[\s\S]*?allow\s+read,\s*write:\s*if\s+false/);
  });
});

// ──────────────────────────────────────────────
// Rate limits (server-only)
// ──────────────────────────────────────────────
describe('firestore.rules — rate_limits (server-only)', () => {
  test('rate_limits path exists', () => {
    expect(RULES).toMatch(/match\s+\/rate_limits\/\{userId\}/);
  });

  test('all access denied', () => {
    expect(RULES).toMatch(/rate_limits[\s\S]*?allow\s+read,\s*write:\s*if\s+false/);
  });
});

// ──────────────────────────────────────────────
// Config (server-only)
// ──────────────────────────────────────────────
describe('firestore.rules — config (server-only)', () => {
  test('config path exists', () => {
    expect(RULES).toMatch(/match\s+\/config\/\{docId\}/);
  });

  test('all access denied', () => {
    expect(RULES).toMatch(/config[\s\S]*?allow\s+read,\s*write:\s*if\s+false/);
  });
});

// ──────────────────────────────────────────────
// Pending payments — field validation
// ──────────────────────────────────────────────
describe('firestore.rules — pending_payments', () => {
  test('pending_payments path exists', () => {
    expect(RULES).toMatch(/match\s+\/pending_payments\/\{paymentId\}/);
  });

  test('create requires matching userId', () => {
    expect(RULES).toMatch(/pending_payments[\s\S]*?allow\s+create[\s\S]*?request\.resource\.data\.userId\s*==\s*request\.auth\.uid/);
  });

  test('paymentMethod is string with size 1-20', () => {
    expect(RULES).toMatch(/request\.resource\.data\.paymentMethod is string/);
    expect(RULES).toMatch(/request\.resource\.data\.paymentMethod\.size\(\)\s*>\s*0/);
    expect(RULES).toMatch(/request\.resource\.data\.paymentMethod\.size\(\)\s*<=\s*20/);
  });

  test('operationId is string with size 1-100', () => {
    expect(RULES).toMatch(/request\.resource\.data\.operationId is string/);
    expect(RULES).toMatch(/request\.resource\.data\.operationId\.size\(\)\s*>\s*0/);
    expect(RULES).toMatch(/request\.resource\.data\.operationId\.size\(\)\s*<=\s*100/);
  });

  test('amount must be 0 on creation (server records real amount)', () => {
    expect(RULES).toMatch(/request\.resource\.data\.amount\s*==\s*0/);
  });

  test('status must be pending', () => {
    expect(RULES).toMatch(/request\.resource\.data\.status\s*==\s*'pending'/);
  });

  test('max 10 keys per document', () => {
    expect(RULES).toMatch(/request\.resource\.data\.keys\.size\(\)\s*<=\s*10/);
  });

  test('update and delete are denied', () => {
    expect(RULES).toMatch(/pending_payments[\s\S]*?allow\s+update,\s*delete:\s*if\s+false/);
  });

  test('read requires owner or admin', () => {
    expect(RULES).toMatch(/resource\.data\.userId\s*==\s*request\.auth\.uid/);
    expect(RULES).toMatch(/get\(\/databases\/\$\(database\)\/documents\/admins\/\$\(request\.auth\.uid\)\)\.exists/);
  });
});

// ──────────────────────────────────────────────
// Economic integrity invariant
// ──────────────────────────────────────────────
describe('firestore.rules — economic integrity invariant', () => {
  test('no economic field appears in any allow write condition', () => {
    const economicFields = [
      'learning_gems', 'learning_total_gems', 'learning_total_xp',
      'learning_level', 'currentStreak', 'longestStreak',
      'shop_streak_shields', 'shop_purchased_xp_boosts',
      'shop_purchased_gem_multipliers', 'shop_purchased_luck_boosts',
    ];
    const writeSections = RULES.split(/allow\s+(create|update)/)
      .filter(s => !s.includes('allow'));

    for (const section of writeSections) {
      for (const field of economicFields) {
        expect(section).not.toContain(field);
      }
    }
  });

  test('no server-only collection allows client writes', () => {
    const serverOnlyCollections = ['payment_logs', 'admins', 'rate_limits', 'config'];
    for (const col of serverOnlyCollections) {
      const startIdx = RULES.indexOf(`match /${col}/`);
      expect(startIdx).toBeGreaterThan(-1);
      // Find the next match/ or end of document
      const endIdx = RULES.indexOf('match /', startIdx + 10);
      const colSection = RULES.substring(startIdx, endIdx > 0 ? endIdx : RULES.length);
      expect(colSection).toMatch(/allow\s+read,\s*write:\s*if\s+false/);
    }
  });
});

// ──────────────────────────────────────────────
// Authentication checks
// ──────────────────────────────────────────────
describe('firestore.rules — authentication checks', () => {
  test('all read rules require authentication (except deny-all)', () => {
    const readRules = RULES.match(/allow\s+read[^;]*;/g) || [];
    for (const rule of readRules) {
      if (rule.includes('if false')) continue;
      expect(rule).toMatch(/request\.auth\s*!=\s*null/);
    }
  });

  test('all create rules require authentication (except deny-all)', () => {
    const createRules = RULES.match(/allow\s+create[^;]*;/g) || [];
    for (const rule of createRules) {
      if (rule.includes('if false')) continue;
      expect(rule).toMatch(/request\.auth\s*!=\s*null/);
    }
  });

  test('all update rules require authentication (except deny-all)', () => {
    const updateRules = RULES.match(/allow\s+update[^;]*;/g) || [];
    for (const rule of updateRules) {
      if (rule.includes('if false')) continue;
      expect(rule).toMatch(/request\.auth\s*!=\s*null/);
    }
  });

  test('all delete rules are deny-all', () => {
    const deleteRules = RULES.match(/allow\s+delete[^;]*;/g) || [];
    for (const rule of deleteRules) {
      expect(rule).toMatch(/if\s+false/);
    }
  });
});

// ──────────────────────────────────────────────
// Cross-cutting security invariants
// ──────────────────────────────────────────────
describe('firestore.rules — cross-cutting invariants', () => {
  test('no wildcard match allows unauthenticated access', () => {
    // The default deny rule should block everything
    const defaultDeny = RULES.match(/match\s+\/\{document=\*\*\}\s*\{[\s\S]*?allow[^}]+\}/);
    expect(defaultDeny).toBeTruthy();
    if (defaultDeny) {
      expect(defaultDeny[0]).toMatch(/allow\s+read,\s*write:\s*if\s+false/);
    }
  });

  test('users collection has owner-only restrictions on all operations', () => {
    const usersSection = RULES.substring(
      RULES.indexOf('match /users/{userId}'),
      RULES.indexOf('match /transaction_logs/')
    );
    // All user operations should check request.auth.uid == userId
    const authChecks = usersSection.match(/request\.auth\.uid\s*==\s*userId/g) || [];
    expect(authChecks.length).toBeGreaterThanOrEqual(3); // read, create, update, nested read
  });

  test('rules file has no syntax errors (basic brace matching)', () => {
    let braceCount = 0;
    for (const char of RULES) {
      if (char === '{') braceCount++;
      if (char === '}') braceCount--;
    }
    expect(braceCount).toBe(0);
  });
});
