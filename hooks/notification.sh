#!/bin/bash
# Notification Hook - Claude Code 알림 시 텔레그램 알림 전송

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
    CONTENT=$(echo "$INPUT" | jq -r '.content // "Claude notification"' 2>/dev/null || echo "Claude notification")
    TYPE=$(echo "$INPUT" | jq -r '.type // "notification"' 2>/dev/null || echo "notification")
else
    # jq 없이 간단한 파싱 (fallback)
    PROJECT_NAME="unknown"
    CONTENT="Claude notification"
    TYPE="notification"
fi

# 메시지 포맷 (Markdown)
MESSAGE="🔔 *Claude Code 알림*
📁 \`${PROJECT_NAME}\`
타입: ${TYPE}
내용: ${CONTENT}"

# Telegram API 호출
curl -s -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "{
        \"chat_id\": \"${TELEGRAM_CHAT_ID}\",
        \"text\": $(echo "$MESSAGE" | jq -Rs .),
        \"parse_mode\": \"Markdown\"
    }" > /dev/null

exit 0
