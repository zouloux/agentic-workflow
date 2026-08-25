# Mission Completion

Before marking `M-* DONE`:

1. Read the mission and resolve its declared `C-*` contexts when the contexts skill is available.
2. Identify durable facts or decisions learned by the mission that future work needs.
3. Transfer only those facts to the appropriate referenced contexts. Do not invent facts, create a
   context without authorization, or add mission backlinks.
4. If required facts cannot be transferred because a reference is missing, ambiguous, or
   unavailable, report the blocker and leave the mission active.
5. Update the mission to its final current state, clear obsolete work items, and ensure
   `## Done when` is satisfied.
6. Run `scripts/done.sh M-*`.

If there are no durable facts to transfer, complete the mission without manufacturing context
content.
