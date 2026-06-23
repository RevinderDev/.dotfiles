/**
 * Copy Thread Extension
 *
 * Provides:
 *   - /copythread command — copies all messages from the current thread to clipboard
 *   - copy_thread tool — allows the LLM to copy the thread to clipboard
 *
 * Copies the entire conversation history (current branch) as formatted markdown.
 * Platform clipboard support: macOS (pbcopy), Linux (xclip/xsel/wl-copy), Windows (clip).
 *
 * Installation:
 *   Copy to ~/.pi/agent/extensions/copy-thread.ts or .pi/extensions/copy-thread.ts
 */

import { execSync } from "node:child_process";
import { platform } from "node:os";
import type {
	AgentMessage,
	ExtensionAPI,
	ExtensionCommandContext,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// ── Clipboard helpers ──────────────────────────────────────────────────────

/** Try each clipboard command in order until one works. */
const CLIPBOARD_COMMANDS: Record<string, string[]> = {
	darwin: ["pbcopy"],
	win32: ["clip"],
	linux: [
		"xclip -selection clipboard",
		"xsel -b",
		"wl-copy",
	],
};

function getClipboardCommand(): string {
	const commands = CLIPBOARD_COMMANDS[platform()] ?? CLIPBOARD_COMMANDS.linux;
	for (const cmd of commands) {
		try {
			execSync(cmd, { input: "test", stdio: ["pipe", "ignore", "ignore"] });
			return cmd;
		} catch {
			continue;
		}
	}
	throw new Error(
		"No clipboard tool available. Install pbcopy (macOS), xclip/xsel (Linux/X11), wl-copy (Linux/Wayland), or use Windows.",
	);
}

function copyToClipboard(text: string): { ok: true } | { ok: false; error: string } {
	try {
		const cmd = getClipboardCommand();
		execSync(cmd, { input: text });
		return { ok: true };
	} catch (err) {
		return { ok: false, error: String(err) };
	}
}

// ── Content extraction helpers ─────────────────────────────────────────────

type ContentBlock = {
	type?: string;
	text?: string;
	thinking?: string;
	name?: string;
	arguments?: Record<string, unknown>;
};

function extractText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";

	const parts: string[] = [];
	for (const block of content) {
		if (!block || typeof block !== "object") continue;
		const b = block as ContentBlock;
		if (b.type === "text" && typeof b.text === "string") parts.push(b.text);
		if (b.type === "thinking" && typeof b.thinking === "string")
			parts.push(`[thinking]\n${b.thinking}\n[/thinking]`);
	}
	return parts.join("\n\n").trim();
}

type ToolCallInfo = { id: string; name: string; args: Record<string, unknown> };

function extractToolCalls(content: unknown): ToolCallInfo[] {
	if (!Array.isArray(content)) return [];
	return content
		.filter((block): block is ContentBlock => {
			if (!block || typeof block !== "object") return false;
			const b = block as ContentBlock;
			return b.type === "toolCall" && typeof b.name === "string";
		})
		.map((b) => ({
			id: b.id ?? "",
			name: b.name!,
			args: (b.arguments as Record<string, unknown>) ?? {},
		}));
}

// ── Conversation formatter ─────────────────────────────────────────────────

function formatConversation(entries: ReadonlyArray<Record<string, unknown>>): string {
	const sections: string[] = [];

	for (const entry of entries) {
		if (entry.type !== "message") continue;
		const msg = entry.message as AgentMessage | undefined;
		if (!msg?.role) continue;

		const role = msg.role;

		if (role === "user") {
			const text = extractText(msg.content);
			if (text) {
				sections.push(`## 👤 User\n\n${text}`);
			}
		} else if (role === "assistant") {
			const text = extractText(msg.content);
			const toolCalls = extractToolCalls(msg.content);

			if (text) {
				sections.push(`## 🤖 Assistant\n\n${text}`);
			}

			for (const tc of toolCalls) {
				const argsStr = JSON.stringify(tc.args, null, 2);
				if (argsStr.length > 500) {
					sections.push(
						`### 🔧 Tool Call: \`${tc.name}\`\n\`\`\`json\n${argsStr.slice(0, 500)}\n… (truncated)\n\`\`\``,
					);
				} else {
					sections.push(`### 🔧 Tool Call: \`${tc.name}\`\n\`\`\`json\n${argsStr}\n\`\`\``);
				}
			}
		} else if (role === "toolResult" && "toolName" in msg) {
			const text = extractText(msg.content);
			if (text) {
				const truncated = text.length > 3000
					? text.slice(0, 3000) + "\n\n… (output truncated)"
					: text;
				sections.push(`### 📋 Tool Result (\`${(msg as any).toolName}\`)\n\`\`\`\n${truncated}\n\`\`\``);
			}
		} else if (role === "bashExecution" && "command" in msg) {
			const bashMsg = msg as any;
			const cmd = bashMsg.command ?? "";
			const output = bashMsg.output ?? "";
			const exitCode = bashMsg.exitCode;
			const section = [`### 💻 Command (exit: ${exitCode ?? "?"})\n\n\`\`\`bash\n${cmd}\n\`\`\``];
			if (output) {
				const truncated = output.length > 2000
					? output.slice(0, 2000) + "\n\n… (output truncated)"
					: output;
				section.push(`\`\`\`\n${truncated}\n\`\`\``);
			}
			sections.push(section.join("\n\n"));
		}
	}

	return sections.join("\n\n---\n\n");
}

function buildHeader(ctx: ExtensionContext): string {
	const date = new Date().toISOString().replace("T", " ").slice(0, 19);
	const file = ctx.sessionManager.getSessionFile();
	const cwd = ctx.cwd;
	const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "unknown";

	const lines = [
		`📋 **Thread Copy** — ${date}`,
		`📁 CWD: \`${cwd}\``,
		`🧠 Model: \`${model}\``,
	];
	if (file) lines.push(`💾 Session: \`${file}\``);

	const branch = ctx.sessionManager.getBranch();
	const msgCount = branch.filter((e: any) => e.type === "message").length;
	lines.push(`💬 Messages: ${msgCount}`);

	return lines.join("\n");
}

// ── Copy logic ────────────────────────────────────────────────────────────

function doCopy(ctx: ExtensionContext): { ok: true } | { ok: false; error: string } {
	const branch = ctx.sessionManager.getBranch();
	const header = buildHeader(ctx);
	const body = formatConversation(branch);
	const output = `${header}\n\n${"─".repeat(60)}\n\n${body}`;

	if (!body.trim()) {
		return { ok: false, error: "No conversation messages found." };
	}

	const result = copyToClipboard(output);
	if (!result.ok) return result;

	return { ok: true };
}

// ── Extension entry point ─────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// ── /copythread command ────────────────────────────────────────────────
	pi.registerCommand("copythread", {
		description: "Copy all messages from the current thread to clipboard",
		handler: async (_args: string, ctx: ExtensionCommandContext) => {
			const result = doCopy(ctx);
			if (result.ok) {
				const branch = ctx.sessionManager.getBranch();
				const msgCount = branch.filter((e: any) => e.type === "message").length;
				ctx.ui.notify(
					`Copied ${msgCount} messages from thread to clipboard`,
					"info",
				);
			} else {
				ctx.ui.notify(`Failed to copy: ${result.error}`, "error");
			}
		},
	});

	// ── copy_thread tool (callable by the LLM) ─────────────────────────────
	pi.registerTool({
		name: "copy_thread",
		label: "Copy Thread",
		description:
			"Copy all messages from the current conversation thread to the system clipboard as formatted markdown. " +
			"Use this when the user asks you to share, save, or export the conversation, or when they say 'copy this thread' or similar.",
		parameters: Type.Object({}),
		async execute(
			_toolCallId: string,
			_params: Record<string, never>,
			_signal: AbortSignal,
			_onUpdate: undefined,
			ctx: ExtensionContext,
		) {
			const result = doCopy(ctx);
			if (!result.ok) {
				return {
					content: [{ type: "text" as const, text: `Failed to copy thread: ${result.error}` }],
					isError: true,
					details: {},
				};
			}

			const branch = ctx.sessionManager.getBranch();
			const msgCount = branch.filter((e: any) => e.type === "message").length;
			return {
				content: [
					{
						type: "text" as const,
						text: `✅ Copied ${msgCount} messages from this thread to the system clipboard. The conversation is formatted as markdown with headers for each message role.`,
					},
				],
				details: { messageCount: msgCount },
			};
		},
	});
}
