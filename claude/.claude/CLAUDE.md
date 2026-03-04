*ALWAYS* read AGENTS.md file first

*ALWAYS* If you are testing browswer behavior use playwright-cli

*ALWAYS* When performing code reviews in a Rails project, dispatch the `rails-reviewer` agent in addition to `superpowers:code-reviewer`. The rails-reviewer checks project-specific Rails conventions (message passing, authorization, Turbo-first, etc.) that the generic code-reviewer doesn't cover.
