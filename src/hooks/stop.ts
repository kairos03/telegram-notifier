#!/usr/bin/env node
/**
 * Stop Hook - Claude Code 정지 시 호출
 */

import { TelegramClient } from '../telegram.js';
import { formatStopMessage, type NotificationData } from '../formatter.js';

async function main() {
  // 환경 변수에서 설정 읽기
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;

  if (!botToken || !chatId) {
    console.error('Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID environment variables');
    process.exit(0); // Hook 실패해도 Claude Code 동작은 계속되어야 함
  }

  // stdin에서 데이터 읽기
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  const input = Buffer.concat(chunks).toString('utf-8');

  let data: NotificationData;
  try {
    data = JSON.parse(input);
  } catch {
    // JSON 파싱 실패시 기본 데이터 사용
    data = {
      type: 'stop',
      content: 'Claude Code stopped',
    };
  }

  // 텔레그램 메시지 전송
  const client = new TelegramClient({ botToken, chatId });
  const message = formatStopMessage(data);

  await client.sendMessage({
    text: message,
    parse_mode: 'Markdown',
  });
}

main().catch(console.error);
