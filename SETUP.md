# Telegram Notifier 설정 가이드

## 빠른 시작 (5분 설정)

### 1단계: 텔레그램 봇 생성 (2분)

1. 텔레그램 앱에서 [@BotFather](https://t.me/botfather) 검색 및 대화 시작
2. `/newbot` 명령어 입력
3. 봇 이름 입력 (예: `My Claude Notifier`)
4. 봇 사용자명 입력 (예: `my_claude_bot`)
5. **Bot Token 저장** (형식: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2단계: Chat ID 확인 (1분)

방법 1 (추천):
1. [@userinfobot](https://t.me/userinfobot)과 대화
2. 봇에게 아무 메시지나 전송
3. 응답에서 `Id` 값 확인 (예: `123456789`)

방법 2:
1. 1단계에서 만든 봇과 대화 시작
2. 봇에게 아무 메시지나 전송
3. 브라우저에서 접속:
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
   ```
4. JSON 응답에서 `"chat":{"id":123456789}` 형태의 값 확인

### 3단계: 환경 변수 설정 (1분)

셸 설정 파일 편집:
```bash
# Bash 사용자
nano ~/.bashrc

# Zsh 사용자
nano ~/.zshrc
```

파일 끝에 추가:
```bash
# Telegram Notifier for Claude Code
export TELEGRAM_BOT_TOKEN="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"  # 실제 토큰으로 변경
export TELEGRAM_CHAT_ID="123456789"  # 실제 Chat ID로 변경
```

저장 후 적용:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### 4단계: 설정 확인 (30초)

```bash
# 환경 변수 확인
echo $TELEGRAM_BOT_TOKEN
echo $TELEGRAM_CHAT_ID

# 둘 다 값이 출력되어야 함
```

### 5단계: Hook 설정 (30초)

`~/.claude/settings.json` 파일 편집:

```json
{
  "hooks": {
    "stop": "node ~/develop/telegram-notifier/dist/hooks/stop.js",
    "notification": "node ~/develop/telegram-notifier/dist/hooks/notification.js"
  }
}
```

**주의**: 기존 `hooks` 섹션이 있다면 병합해야 합니다:

```json
{
  "hooks": {
    "existing_hook": "existing command",
    "stop": "node ~/develop/telegram-notifier/dist/hooks/stop.js",
    "notification": "node ~/develop/telegram-notifier/dist/hooks/notification.js"
  }
}
```

### 6단계: 테스트 (1분)

```bash
# Stop hook 테스트
echo '{"type":"stop","projectPath":"/home/user/project","content":"Test stop message"}' | \
  TELEGRAM_BOT_TOKEN="your_token" TELEGRAM_CHAT_ID="your_chat_id" \
  node ~/develop/telegram-notifier/dist/hooks/stop.js

# Notification hook 테스트
echo '{"type":"idle_prompt","projectPath":"/home/user/project","content":"Claude is waiting for your input"}' | \
  TELEGRAM_BOT_TOKEN="your_token" TELEGRAM_CHAT_ID="your_chat_id" \
  node ~/develop/telegram-notifier/dist/hooks/notification.js
```

텔레그램에서 메시지를 받으면 설정 완료!

## 고급 설정

### 여러 Chat ID에 전송

쉼표로 구분된 Chat ID 사용 (미래 기능):
```bash
export TELEGRAM_CHAT_ID="123456789,987654321"
```

### 조용한 알림 (무음)

`formatter.ts`에서 `disable_notification: true` 설정

### 메시지 커스터마이징

`src/formatter.ts` 파일의 메시지 포맷 수정 후 재빌드:
```bash
cd ~/develop/telegram-notifier
npm run build
```

## 문제 해결

### 메시지가 전송되지 않음

1. **환경 변수 확인**:
   ```bash
   echo $TELEGRAM_BOT_TOKEN
   echo $TELEGRAM_CHAT_ID
   ```
   - 비어있으면: 3단계 재확인 및 터미널 재시작

2. **봇 토큰 확인**:
   ```bash
   curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe"
   ```
   - `"ok":true` 응답이 와야 함
   - 에러 시: Bot Token 재확인

3. **Chat ID 확인**:
   - 봇과 대화를 시작했는지 확인
   - Chat ID가 숫자인지 확인 (음수도 가능)

### Hook이 실행되지 않음

1. **빌드 확인**:
   ```bash
   ls ~/develop/telegram-notifier/dist/hooks/
   ```
   - stop.js, notification.js 파일이 있어야 함

2. **설정 파일 확인**:
   ```bash
   cat ~/.claude/settings.json | grep -A 3 hooks
   ```
   - JSON 형식이 올바른지 확인 (쉼표, 괄호)

3. **권한 확인**:
   ```bash
   chmod +x ~/develop/telegram-notifier/dist/hooks/*.js
   ```

### Claude Code에서 Hook이 호출되지 않음

Claude Code 재시작:
```bash
# 현재 세션 종료 후 재시작
```

디버그 로그 확인:
```bash
tail -f ~/.claude/logs/*.log
```

## 지원

이슈 리포트: GitHub Issues 또는 텔레그램 봇 개발자 문의
