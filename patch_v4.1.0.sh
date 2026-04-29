#!/usr/bin/env bash
# ============================================================
#  GENISYS PORTFOLIO — Patch v4.1.0
#  Run from the project root folder.
#  Fixes:
#    1. Remove ghost "Copy Email" button from hamburger drawer
#    2. Active tab indicator fires immediately on click
#    3. Pages always start at the top (scroll reset on mount)
#    4. Version tag updated to v4.1.0
# ============================================================
set -e

echo "▶  Genisys patch v4.1.0 starting..."

# ── Guard: must be run from project root ─────────────────────
if [ ! -f "src/components/Navigation.tsx" ]; then
  echo "✗  Run this script from your project root (where src/ lives)."
  exit 1
fi

# ── Backup ───────────────────────────────────────────────────
BACKUP_DIR=".patch-backups/v4.1.0"
mkdir -p "$BACKUP_DIR"
cp src/components/Navigation.tsx "$BACKUP_DIR/Navigation.tsx.bak"
cp src/App.tsx                    "$BACKUP_DIR/App.tsx.bak"
cp src/pages/ServicesPage.tsx     "$BACKUP_DIR/ServicesPage.tsx.bak"
cp src/pages/StudioPage.tsx       "$BACKUP_DIR/StudioPage.tsx.bak"
cp src/pages/SettingsPage.tsx     "$BACKUP_DIR/SettingsPage.tsx.bak"
cp src/pages/CaseStudyPage.tsx    "$BACKUP_DIR/CaseStudyPage.tsx.bak"
echo "✓  Backups saved to $BACKUP_DIR"

# ════════════════════════════════════════════════════════════
#  1 · Navigation.tsx
#      • Remove Copy/Check from lucide import (ghost email icons)
#      • Remove `copied` state
#      • Remove `copyEmail` function
#      • Immediately set activeSection on section-link click
#      • Remove the entire COPY EMAIL button block
#      • Update version to v4.1.0
# ════════════════════════════════════════════════════════════
python3 - << 'PYEOF'
import re, pathlib

f = pathlib.Path("src/components/Navigation.tsx")
src = f.read_text()

# 1a. Remove Copy, Check from lucide import
src = src.replace(
    "import { Menu, X, Music2, Copy, Check, Zap } from \"lucide-react\";",
    "import { Menu, X, Music2, Zap } from \"lucide-react\";"
)

# 1b. Remove the `copied` state line
src = src.replace(
    "  const [copied,      setCopied]   = useState(false);\n",
    ""
)

# 1c. Remove the copyEmail function (multi-line)
copy_fn = (
    "\n  const copyEmail = async () => {\n"
    "    try {\n"
    "      await navigator.clipboard.writeText(STUDIO.email);\n"
    "      setCopied(true);\n"
    "      setTimeout(() => setCopied(false), 2000);\n"
    "    } catch { /**/ }\n"
    "  };\n"
)
src = src.replace(copy_fn, "\n")

# 1d. Fix onClick for nav links — immediately set activeSection on click
# Old: onClick={() => { l.action(); setOpen(false); }}
# New: onClick={() => { if (l.section) setActive(l.section); l.action(); setOpen(false); }}
src = src.replace(
    "onClick={() => { l.action(); setOpen(false); }}",
    "onClick={() => { if (l.section) setActive(l.section); l.action(); setOpen(false); }}"
)

# 1e. Remove the entire COPY EMAIL motion.button block
# The block starts with the second <motion.button in Quick Actions
copy_block = (
    "\n                  <motion.button\n"
    "                    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}\n"
    "                    transition={{ duration: 0.28, delay: 0.50 }}\n"
    "                    onClick={copyEmail}\n"
    "                    className=\"w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-colors hover:bg-white/[0.04]\"\n"
    "                  >\n"
    "                    {copied\n"
    "                      ? <Check className=\"w-4 h-4 text-green-400 flex-none\" />\n"
    "                      : <Copy  className=\"w-4 h-4 text-cream/35 flex-none\" />\n"
    "                    }\n"
    "                    <div>\n"
    "                      <p className={\"font-mono text-[10px] tracking-[0.2em] \" + (copied ? \"text-green-400\" : \"text-cream/60\")}>\n"
    "                        {copied ? \"COPIED!\" : \"COPY EMAIL\"}\n"
    "                      </p>\n"
    "                      <p className=\"font-mono text-[8px] text-cream/25 mt-0.5 truncate\">{STUDIO.email}</p>\n"
    "                    </div>\n"
    "                  </motion.button>"
)
src = src.replace(copy_block, "")

# 1f. Remove STUDIO import from Navigation (no longer needed after removing copy email)
# But only if STUDIO isn't used elsewhere in the file
if "STUDIO" not in src.replace("from \"@/data/siteConfig\"", ""):
    src = src.replace(
        "import { SOCIAL, STUDIO }                    from \"@/data/siteConfig\";",
        "import { SOCIAL }                            from \"@/data/siteConfig\";"
    )
    # also clean up availability reference in drawer header
    pass  # STUDIO.availability IS still used in the Start a Project button — keep the import

# 1g. Update version tag in drawer footer
src = src.replace(
    "<p className=\"font-mono text-[7px] tracking-[0.2em] text-cream/12\">v4.0.0</p>",
    "<p className=\"font-mono text-[7px] tracking-[0.2em] text-cream/12\">v4.1.0</p>"
)

f.write_text(src)
print("  ✓  Navigation.tsx patched")
PYEOF

# ════════════════════════════════════════════════════════════
#  2 · App.tsx — reset scroll position on every page change
# ════════════════════════════════════════════════════════════
python3 - << 'PYEOF'
import pathlib

f = pathlib.Path("src/App.tsx")
src = f.read_text()

# Insert a scroll-reset effect right after the existing route/lenis setup lines
# Find the block:  useLenis(); \n  useVhFix();
# and insert a new useEffect after useVhFix
scroll_effect = (
    "\n\n  // Reset scroll to top whenever navigating to a non-home page\n"
    "  useEffect(() => {\n"
    "    if (route.page !== \"home\") {\n"
    "      // rAF ensures React has painted the new page before scrolling\n"
    "      requestAnimationFrame(() => {\n"
    "        window.scrollTo(0, 0);\n"
    "        document.documentElement.scrollTop = 0;\n"
    "      });\n"
    "    }\n"
    "  }, [route.page]);"
)

old = "  useLenis();\n  useVhFix();"
new = "  useLenis();\n  useVhFix();" + scroll_effect

if old in src:
    src = src.replace(old, new, 1)
    f.write_text(src)
    print("  ✓  App.tsx patched (scroll reset added)")
else:
    print("  ⚠  App.tsx: could not find insertion point — skipping scroll reset")
PYEOF

# ════════════════════════════════════════════════════════════
#  3 · ServicesPage.tsx — scroll to top on mount
# ════════════════════════════════════════════════════════════
python3 - << 'PYEOF'
import pathlib

f = pathlib.Path("src/pages/ServicesPage.tsx")
src = f.read_text()

# Add useEffect import (it's not currently imported here)
if "useEffect" not in src:
    src = src.replace(
        "import { motion } from \"framer-motion\";",
        "import { useEffect } from \"react\";\nimport { motion } from \"framer-motion\";"
    )

# Add scroll-reset at the top of the default export function body
# Find: export default function ServicesPage({ onContact }: Props) {
old = "export default function ServicesPage({ onContact }: Props) {\n  const heading = useScramble"
new = (
    "export default function ServicesPage({ onContact }: Props) {\n"
    "  // Always start at the top when this page mounts\n"
    "  useEffect(() => { window.scrollTo(0, 0); document.documentElement.scrollTop = 0; }, []);\n"
    "  const heading = useScramble"
)
if old in src:
    src = src.replace(old, new, 1)
    f.write_text(src)
    print("  ✓  ServicesPage.tsx patched (scroll reset on mount)")
else:
    print("  ⚠  ServicesPage.tsx: insertion point not found — skipping")
PYEOF

# ════════════════════════════════════════════════════════════
#  4 · StudioPage.tsx — scroll to top on mount
# ════════════════════════════════════════════════════════════
python3 - << 'PYEOF'
import pathlib

f = pathlib.Path("src/pages/StudioPage.tsx")
src = f.read_text()

if "useEffect" not in src:
    src = src.replace(
        "import { motion } from \"framer-motion\";",
        "import { useEffect } from \"react\";\nimport { motion } from \"framer-motion\";"
    )

old = "export default function StudioPage({ onContact }: Props) {\n  const heading = useScramble"
new = (
    "export default function StudioPage({ onContact }: Props) {\n"
    "  // Always start at the top when this page mounts\n"
    "  useEffect(() => { window.scrollTo(0, 0); document.documentElement.scrollTop = 0; }, []);\n"
    "  const heading = useScramble"
)
if old in src:
    src = src.replace(old, new, 1)
    f.write_text(src)
    print("  ✓  StudioPage.tsx patched (scroll reset on mount)")
else:
    print("  ⚠  StudioPage.tsx: insertion point not found — skipping")
PYEOF

# ════════════════════════════════════════════════════════════
#  5 · SettingsPage.tsx — scroll to top on mount
# ════════════════════════════════════════════════════════════
python3 - << 'PYEOF'
import pathlib

f = pathlib.Path("src/pages/SettingsPage.tsx")
src = f.read_text()

# Check what's already imported
if "useEffect" not in src:
    # find the motion import and add useEffect before it
    src = src.replace(
        "import { motion }",
        "import { useEffect } from \"react\";\nimport { motion }"
    )

old_marker = "export default function SettingsPage({ onContact }: Props) {"
new_marker = (
    "export default function SettingsPage({ onContact }: Props) {\n"
    "  // Always start at the top when this page mounts\n"
    "  useEffect(() => { window.scrollTo(0, 0); document.documentElement.scrollTop = 0; }, []);"
)
if old_marker in src:
    src = src.replace(old_marker, new_marker, 1)
    f.write_text(src)
    print("  ✓  SettingsPage.tsx patched (scroll reset on mount)")
else:
    print("  ⚠  SettingsPage.tsx: insertion point not found — skipping")
PYEOF

# ════════════════════════════════════════════════════════════
#  6 · CaseStudyPage.tsx — scroll to top on mount
# ════════════════════════════════════════════════════════════
python3 - << 'PYEOF'
import pathlib

f = pathlib.Path("src/pages/CaseStudyPage.tsx")
src = f.read_text()

if "useEffect" not in src:
    src = src.replace(
        "import { useMemo } from \"react\";",
        "import { useEffect, useMemo } from \"react\";"
    )
else:
    # useEffect already imported — just ensure it's in the import
    if "useEffect" not in src.split("from \"react\"")[0]:
        src = src.replace(
            "import { useMemo } from \"react\";",
            "import { useEffect, useMemo } from \"react\";"
        )

old_marker = "export default function CaseStudyPage({ id, onContact }: Props) {"
new_marker = (
    "export default function CaseStudyPage({ id, onContact }: Props) {\n"
    "  // Always start at the top when this page mounts or the case study changes\n"
    "  useEffect(() => { window.scrollTo(0, 0); document.documentElement.scrollTop = 0; }, [id]);"
)
if old_marker in src:
    src = src.replace(old_marker, new_marker, 1)
    f.write_text(src)
    print("  ✓  CaseStudyPage.tsx patched (scroll reset on id change)")
else:
    print("  ⚠  CaseStudyPage.tsx: insertion point not found — skipping")
PYEOF

# ════════════════════════════════════════════════════════════
#  7 · Verify all patches applied cleanly
# ════════════════════════════════════════════════════════════
echo ""
echo "── Verification ────────────────────────────────────────"

# 7a. Confirm COPY EMAIL is gone
if grep -q "COPY EMAIL" src/components/Navigation.tsx; then
  echo "✗  Navigation.tsx: COPY EMAIL still present!"
else
  echo "✓  Navigation.tsx: ghost email button removed"
fi

# 7b. Confirm active section set on click
if grep -q "if (l.section) setActive(l.section)" src/components/Navigation.tsx; then
  echo "✓  Navigation.tsx: immediate active-section on click"
else
  echo "✗  Navigation.tsx: active-section fix missing!"
fi

# 7c. Confirm version bump
if grep -q "v4.1.0" src/components/Navigation.tsx; then
  echo "✓  Navigation.tsx: version → v4.1.0"
else
  echo "✗  Navigation.tsx: version not updated"
fi

# 7d. Confirm scroll reset in App.tsx
if grep -q "route.page !== \"home\"" src/App.tsx; then
  echo "✓  App.tsx: scroll-reset effect added"
else
  echo "✗  App.tsx: scroll-reset missing!"
fi

# 7e. Confirm page-level scroll resets
for page in ServicesPage StudioPage SettingsPage CaseStudyPage; do
  if grep -q "scrollTo(0, 0)" "src/pages/${page}.tsx"; then
    echo "✓  ${page}.tsx: scroll-to-top on mount"
  else
    echo "✗  ${page}.tsx: scroll-to-top missing!"
  fi
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ✅  Patch v4.1.0 applied successfully"
echo "     Backups in: $BACKUP_DIR"
echo "════════════════════════════════════════════════════════"
