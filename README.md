# Telegram Notifier for Claude Code

Claude Code의 Stop 및 Notification hook에서 텔레그램으로 알림을 보내는 플러그인입니다.

## 기능

- **Stop Hook**: Claude Code가 정지될 때 텔레그램 알림
- **Notification Hook**: Claude Code에서 알림이 발생할 때 텔레그램 알림
- **Shell Script 기반**: Node.js 의존성 없이 bash + curl + jq로 동작

## 설치

### 방법 1: Claude Code Plugin Marketplace (권장)

```bash
/plugin install kairos9603/telegram-notifier
```

또는 CLI에서:

```bash
claude plugin install kairos9603/telegram-notifier
```

플러그인 설치 후 환경 변수 설정만 하면 바로 사용 가능합니다.

### 필수 요구사항

- **bash**: Shell 스크립트 실행
- **curl**: Telegram API 호출
- **jq**: JSON 파싱 (선택사항, 없어도 기본 동작 가능)

```bash
# jq 설치 (Ubuntu/Debian)
sudo apt-get install jq

# jq 설치 (macOS)
brew install jq
```

### 방법 2: 수동 설치

#### 1. 텔레그램 봇 생성

1. 텔레그램에서 [@BotFather](https://t.me/botfather)와 대화
2. `/newbot` 명령어로 새 봇 생성
3. Bot Token 저장 (예: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`)

#### 2. Chat ID 확인

1. 생성한 봇과 대화 시작 (아무 메시지나 전송)
2. 브라우저에서 다음 URL 접속:
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
   ```
3. 응답에서 `chat.id` 값 확인

#### 3. 환경 변수 설정

`~/.bashrc`, `~/.zshrc` 또는 `~/.profile`에 다음 추가:

```bash
# Telegram Notifier for Claude Code
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
```

저장 후 터미널 재시작 또는:
```bash
source ~/.bashrc  # or ~/.zshrc, ~/.profile
```

#### 4. Hook 설정

플러그인은 자동으로 설치되며, shell 스크립트가 실행됩니다. 별도 빌드 과정이 필요하지 않습니다.

Hook은 다음 경로에서 자동으로 실행됩니다:
- Stop Hook: `hooks/stop.sh`
- Notification Hook: `hooks/notification.sh`

## 메시지 형식

### Stop Hook
```
⏸️ Claude Code 정지
📁 project-name
타입: stop
내용: Claude Code stopped
```

### Notification Hook
```
🔔 Claude Code 알림
📁 project-name
타입: idle_prompt
내용: Claude is waiting for your input
```

## 테스트

Hook 테스트:

```bash
# Stop hook 테스트
echo '{"type":"stop","projectPath":"/home/user/project","content":"Test stop"}' | \
  bash ~/.claude/plugins/cache/telegram-notifier-marketplace/telegram-notifier/1.1.0/hooks/stop.sh

# Notification hook 테스트
echo '{"type":"idle_prompt","projectPath":"/home/user/project","content":"Test notification"}' | \
  bash ~/.claude/plugins/cache/telegram-notifier-marketplace/telegram-notifier/1.1.0/hooks/notification.sh
```

## 문제 해결

### 메시지가 전송되지 않음

1. 환경 변수가 올바르게 설정되었는지 확인:
   ```bash
   echo $TELEGRAM_BOT_TOKEN
   echo $TELEGRAM_CHAT_ID
   ```

2. Bot Token과 Chat ID가 올바른지 확인

3. 봇이 차단되지 않았는지 확인

4. jq 설치 확인 (선택사항):
   ```bash
   jq --version
   ```

### Hook이 실행되지 않음

1. shell 스크립트 실행 권한 확인:
   ```bash
   chmod +x ~/.claude/plugins/cache/telegram-notifier-marketplace/telegram-notifier/1.1.0/hooks/*.sh
   ```

2. bash와 curl 설치 확인:
   ```bash
   bash --version
   curl --version
   ```

## 개발자 가이드

### 로컬에서 플러그인 테스트

```bash
# 로컬 디렉토리에서 플러그인 테스트
claude --plugin-dir /data/develop/telegram-notifier

# 플러그인 구조 검증
claude plugin validate /data/develop/telegram-notifier

# Hook 스크립트 직접 테스트
echo '{"type":"stop","projectPath":"'$(pwd)'","content":"Test"}' | \
  bash ./hooks/stop.sh
```

### 플러그인 구조

```
telegram-notifier/
├── .claude-plugin/
│   ├── plugin.json          # 플러그인 매니페스트
│   └── marketplace.json     # Marketplace 설정
├── hooks/
│   ├── hooks.json           # Hook 설정
│   ├── stop.sh              # Stop hook shell script
│   └── notification.sh      # Notification hook shell script
├── src/                     # TypeScript 소스 (레거시)
├── README.md
├── LICENSE
└── package.json
```

## GitHub 배포 가이드

1. GitHub 저장소 생성
2. 코드 푸시:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/kairos9603/telegram-notifier.git
   git push -u origin main
   ```
3. 릴리스 태그 생성:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

배포 후 사용자는 `/plugin install kairos9603/telegram-notifier`로 설치 가능합니다.

## 라이선스

MIT
