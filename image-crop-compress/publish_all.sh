#!/bin/bash
set -e

echo "Committing changes..."
git add .
git commit -m 'Fix pub.dev scoring issues' || true
git push || true

for pkg in image_crop_compress_core image_crop_compress_ui image_crop_compress_android image_crop_compress_ios image_crop_compress; do
  echo "🚀 Publishing $pkg 0.0.3..."
  cd $pkg
  fvm flutter pub publish --force
  cd ..
done

echo "✅ All packages published successfully!"
