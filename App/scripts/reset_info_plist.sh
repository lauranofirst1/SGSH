#!/bin/bash

# 현재 스크립트가 위치한 디렉토리 기준으로 경로 계산
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_FILE="$SCRIPT_DIR/../ios/Runner/Info.plist"

if [ ! -f "$PLIST_FILE" ]; then
  echo "❌ Info.plist 파일이 존재하지 않습니다: $PLIST_FILE"
  exit 1
fi

/usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY ''" "$PLIST_FILE" \
  && echo "🧹 Info.plist: GOOGLE_MAPS_API_KEY 비워짐"
