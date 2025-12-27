#!/bin/bash
# Clean up recyclarr git tracking - remove Docker runtime files

echo "🧹 Cleaning up recyclarr git tracking..."
echo ""

cd ~/projects/mother || exit 1

# Check if configs/recyclarr exists
if [ ! -d "configs/recyclarr" ]; then
    echo "❌ configs/recyclarr/ doesn't exist!"
    exit 1
fi

echo "📁 Current status of configs/recyclarr/:"
git status configs/recyclarr/
echo ""

echo "🗑️  Removing Docker runtime files from git (if tracked)..."
echo ""

# Remove runtime directories from git tracking (keeps local files)
git rm -r --cached configs/recyclarr/cache 2>/dev/null && echo "   ✅ Removed cache/" || echo "   ℹ️  cache/ not tracked"
git rm -r --cached configs/recyclarr/configs 2>/dev/null && echo "   ✅ Removed configs/" || echo "   ℹ️  configs/ not tracked"
git rm -r --cached configs/recyclarr/includes 2>/dev/null && echo "   ✅ Removed includes/" || echo "   ℹ️  includes/ not tracked"
git rm -r --cached configs/recyclarr/logs 2>/dev/null && echo "   ✅ Removed logs/" || echo "   ℹ️  logs/ not tracked"
git rm -r --cached configs/recyclarr/repos 2>/dev/null && echo "   ✅ Removed repos/" || echo "   ℹ️  repos/ not tracked"

# Remove runtime files from git tracking
git rm --cached configs/recyclarr/settings.yml 2>/dev/null && echo "   ✅ Removed settings.yml" || echo "   ℹ️  settings.yml not tracked"

echo ""
echo "✅ Adding .gitignore to prevent re-tracking..."
git add configs/recyclarr/.gitignore
echo ""

echo "📊 Final status:"
git status configs/recyclarr/
echo ""

echo "✅ Done! Now commit:"
echo ""
echo "  git commit -m 'Clean up recyclarr - remove Docker runtime files from git'"
echo "  git push origin main"
echo ""
echo "From now on, only these will be tracked:"
echo "  - recyclarr.yml (config)"
echo "  - .env.example (template)"
echo "  - *.md (documentation)"
echo "  - .gitignore (ignore rules)"
