#!/bin/bash
# Fix git tracking for recyclarr configs

echo "🔧 Fixing git tracking for configs/recyclarr/"
echo ""

cd ~/projects/mother || exit 1

# First, make sure files are in the right place
if [ ! -d "configs/recyclarr" ]; then
    echo "❌ configs/recyclarr/ doesn't exist yet!"
    echo "Run ./fix_recyclarr_location.sh first"
    exit 1
fi

echo "📁 Files in configs/recyclarr/:"
ls -lh configs/recyclarr/
echo ""

# Remove from git cache (if previously ignored)
echo "🗑️  Removing configs/ from git cache..."
git rm -r --cached configs/ 2>/dev/null || echo "   (was not tracked, that's ok)"
echo ""

# Add the updated .gitignore
echo "📝 Adding updated .gitignore..."
git add .gitignore
echo ""

# Now add recyclarr configs
echo "✅ Adding configs/recyclarr/..."
git add configs/recyclarr/
echo ""

# Show what will be committed
echo "📊 Status:"
git status
echo ""

echo "✅ Ready to commit!"
echo ""
echo "Run:"
echo "  git commit -m 'Add recyclarr configs with TRaSH templates'"
echo "  git push origin main"
