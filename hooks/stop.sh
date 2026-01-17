#!/bin/bash
# Stop Hook - Claude Code 정지 시 텔레그램 알림 전송

set -euo pipefail

# 환경 변수 확인
if [[ -z "${TELEGRAM_BOT_TOKEN:-}" ]] || [[ -z "${TELEGRAM_CHAT_ID:-}" ]]; then
    echo "Error: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set" >&2
    exit 0  # Hook 실패해도 Claude Code는 계속 실행
fi

# stdin에서 JSON 데이터 읽기
INPUT=$(cat)

# jq가 없으면 기본값 사용
if command -v jq >/dev/null 2>&1; then
    PROJECT_PATH=$(echo "$INPUT" | jq -r '.projectPath // "unknown"' 2>/dev/null || echo "unknown")
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    CONTENT=$(echo "$INPUT" | jq -r '.content // "Claude Code stopped"' 2>/dev/null || echo "Claude Code stopped")
    TYPE=$(echo "$INPUT" | jq -r '.type // "stop"' 2>/dev/null || echo "stop")
else
    # jq 없이 간단한 파싱 (fallback)
    PROJECT_NAME="unknown"
    CONTENT="Claude Code stopped"
    TYPE="stop"
fi

# 메시지 포맷 (Markdown)
MESSAGE="⏸️ *Claude Code 정지*
📁 \`${PROJECT_NAME}\`
타입: ${TYPE}
내용: ${CONTENT}"

# URL 인코딩 함수 (간단 버전)
urlencode() {
    echo "$1" | sed 's/ /%20/g' | sed 's/\n/%0A/g'
}

# Telegram API 호출
ENCODED_MESSAGE=$(echo -e "$MESSAGE" | jq -sRr @uri)

curl -s -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "{
        \"chat_id\": \"${TELEGRAM_CHAT_ID}\",
        \"text\": $(echo "$MESSAGE" | jq -Rs .),
        \"parse_mode\": \"Markdown\"
    }" > /dev/null

exit 0
