// Report Pi to Herdr as blocked while it waits for the user.
//
// Herdr's own extension, herdr-agent-state.ts, reports "blocked" only while
// another extension holds a "herdr:blocked" event open, and it counts each
// { active: true } until a matching { active: false }. Pi emits ui_prompt_start
// and ui_prompt_end around every extension dialog, including the
// questionnaire's custom screen, and joins nested dialogs into one span. So
// each span becomes one balanced pair of events.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	// The questionnaire's screen has no title, so its first question is the label.
	let question: string | undefined;

	pi.on("tool_execution_start", (event) => {
		if (event.toolName === "questionnaire") question = event.args?.questions?.[0]?.prompt;
	});
	pi.on("tool_execution_end", (event) => {
		if (event.toolName === "questionnaire") question = undefined;
	});

	pi.on("ui_prompt_start", (event) => {
		pi.events.emit("herdr:blocked", { active: true, label: event.title ?? question });
	});
	pi.on("ui_prompt_end", () => {
		pi.events.emit("herdr:blocked", { active: false });
	});
}
