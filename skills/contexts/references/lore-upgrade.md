# Lore Upgrade

If `scripts/migrate.sh --check` finds lore directories or instructions, propose an upgrade and
wait for explicit user confirmation. Never run `--apply` automatically. After confirmation, run
`scripts/migrate.sh --apply` from the same project root. The script:

1. checks every migration and reports all collisions before changing anything;
2. renames each scoped `.lores/` directory to `.contexts/`;
3. renames every `*.lore.md` below it to `*.md`;
4. adjusts only the migrated `.lores` and `.lore.md` path strings;
5. mechanically changes lore references to contexts in the relevant scope markers.

Migration does not clean up, summarize, reorganize, or otherwise rewrite document content beyond
those path adjustments. Legacy lifecycle content can therefore remain after migration; do not
silently remove it. Review or cleanup is a separate user-authorized operation. If preflight
reports a collision or an unscoped `.lores/` directory, report it and stop without mutation.
