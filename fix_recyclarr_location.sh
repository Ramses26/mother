#!/bin/bash
# Fix recyclarr directory location
# Run this from ~/projects/mother directory

echo "Moving recyclarr config from config/ to configs/..."

# Move all files from config/recyclarr to configs/recyclarr
if [ -d "config/recyclarr" ]; then
    # Copy files to correct location
    cp -r config/recyclarr/* configs/recyclarr/
    
    echo "✅ Files copied to configs/recyclarr/"
    echo ""
    echo "Files in configs/recyclarr/:"
    ls -lh configs/recyclarr/
    echo ""
    
    # Remove old directory
    read -p "Remove old config/recyclarr directory? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf config/recyclarr
        rmdir config 2>/dev/null  # Remove config dir if empty
        echo "✅ Old directory removed"
    fi
else
    echo "❌ config/recyclarr not found - maybe already moved?"
fi

echo ""
echo "✅ Done! Now commit the changes:"
echo "   git add .gitignore configs/recyclarr/"
echo "   git commit -m 'Fix recyclarr location - moved to configs/'"
echo "   git push origin main"
