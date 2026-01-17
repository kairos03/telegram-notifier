/**
 * 메시지 포맷터
 */

export interface NotificationData {
  type: string;
  projectPath?: string;
  content?: string;
  metadata?: Record<string, unknown>;
}

export function formatNotificationMessage(data: NotificationData): string {
  const projectName = data.projectPath
    ? data.projectPath.split('/').pop() || 'unknown'
    : 'unknown';

  let message = `🔔 Claude Code 알림\n`;
  message += `📁 ${projectName}\n`;
  message += `타입: ${data.type}\n`;

  if (data.content) {
    message += `내용: ${data.content}`;
  }

  return message;
}

export function formatStopMessage(data: NotificationData): string {
  const projectName = data.projectPath
    ? data.projectPath.split('/').pop() || 'unknown'
    : 'unknown';

  let message = `⏸️ Claude Code 정지\n`;
  message += `📁 ${projectName}\n`;
  message += `타입: ${data.type}\n`;

  if (data.content) {
    message += `내용: ${data.content}`;
  }

  return message;
}
