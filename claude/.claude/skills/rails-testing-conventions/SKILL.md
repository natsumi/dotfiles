---
name: rails-testing-conventions
description: "Use when creating or modifying MiniTest tests in test/. TRIGGER when: editing files in test/, creating new test files, writing assertions, setting up fixtures/factories, or user mentions testing/test coverage. DO NOT TRIGGER when: not in a Rails project, editing application code without test changes."
---

# Rails Testing Conventions

Conventions for MiniTest tests in this project.

## Core Principles (Non-Negotiable)

1. **Never test mocked behavior** - If you mock it, you're not testing it
2. **No mocks in integration tests** - Request/system tests use real data. WebMock for external APIs only
3. **Pristine test output** - Capture and verify expected errors, don't let them pollute output
4. **All failures are your responsibility** - Even pre-existing. Never ignore failing tests
5. **Coverage cannot decrease** - Never delete a failing test, fix the root cause

## Test Types

| Type      | Location           | Use For                                               |
| --------- | ------------------ | ----------------------------------------------------- |
| Request   | `test/requests/`   | Single action (CRUD, redirects). Never test auth here |
| System    | `test/system/`     | Multi-step flows. Use `assert_text`, never `sleep`    |
| Model     | `test/models/`     | Public interface + Shoulda matchers                   |
| Policy    | `test/policies/`   | ALL authorization tests belong here                   |
| Component | `test/components/` | ViewComponent rendering                               |

## Factory Rules

- **Explicit attributes** - `create(:company_user, role: :mentor)` not `create(:user)`
- **Use traits** - `:published`, `:draft` for variations
- **`setup` for shared state** - Use `setup` blocks for test fixtures
- **Create in final state** - No `update!` in setup blocks

## Quick Reference

| Do                            | Don't                     |
| ----------------------------- | ------------------------- |
| Test real behavior            | Test mocked behavior      |
| WebMock for external APIs     | Mock internal classes     |
| Explicit factory attributes   | Rely on factory defaults  |
| `setup` for shared state      | Redundant setup per test  |
| Capture expected errors       | Let errors pollute output |
| Wait for elements             | Use `sleep`               |
| Assert content in index tests | Only check HTTP status    |

## Common Mistakes

1. **Testing mocks** - You're testing nothing
2. **Mocking policies** - Use real authorized users
3. **Auth tests in request tests** - Move to policy tests
4. **`sleep` in system tests** - Use Capybara's waiting matchers
5. **Deleting failing tests** - Fix the root cause

**Remember:** Tests verify behavior, not implementation.
