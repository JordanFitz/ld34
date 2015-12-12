import "dart:html";

import "utils.dart" as utils;
import "mouse.dart" as mouse;
import "box.dart";

CanvasElement canvas = querySelector("canvas#canvas");
CanvasRenderingContext2D context = canvas.context2D;

const num WIDTH = 1280;
const num HEIGHT = 720;

num backgroundOpacity = 0.0;
bool backgroundDirection = false;

enum GameState {
	MENU, MAP, INTERVIEW
}

GameState gameState = GameState.MENU;

Map keys = new Map<num, bool>();
Map keycodes = {

};

num lastDelta = 0;

Box playButton = new Box(WIDTH / 2 - (150), 400, 300, 50);

update(num d) {
	num delta = d - lastDelta;

	if (backgroundDirection) {
		if (backgroundOpacity < 0.3) {
			backgroundOpacity += 0.06 / delta;
		} else {
			backgroundDirection = false;
		}
	} else {
		if (backgroundOpacity > 0) {
			backgroundOpacity -= 0.06 / delta;
		} else {
			backgroundDirection = true;
		}
	}

	lastDelta = d;
}

draw() {
	context.clearRect(0, 0, WIDTH, HEIGHT);

	context.fillStyle = "rgba(0, 0, 0, $backgroundOpacity)";
	context.fillRect(0, 0, WIDTH, HEIGHT);

	if (gameState == GameState.MENU) {
		utils.drawText(context, "TwoButtons,", WIDTH / 2, 250, "Propaganda", 60, "#000", true);
		utils.drawText(context, "Controls", WIDTH / 2, 300, "Propaganda", 60, "#000", true);

		if (utils.withinBox(mouse.x, mouse.y, playButton)) {
			utils.drawBox(context, playButton, "rgba(0, 0, 0, 0.7)");
		} else {
			utils.drawBox(context, playButton, "rgba(0, 0, 0, 0.6)");
		}

		utils.drawText(context, "PLAY", WIDTH / 2, 418, "Propaganda", 25, "#fff", true);
	}
}

tick(num delta) {
	update(delta);
	draw();

	window.animationFrame.then(tick);
}

init() {
	canvas.width = WIDTH;
	canvas.height = HEIGHT;

	window.onKeyDown.listen((e) {
		keys[e.keyCode] = true;
	});

	window.onKeyUp.listen((e) {
		keys.remove(e.keyCode);
	});

	canvas.onMouseMove.listen((e) {
		mouse.x = e.offset.x;
		mouse.y = e.offset.y;
	});

	canvas.onMouseDown.listen((e) {
		mouse.down = true;
	});

	canvas.onMouseUp.listen((e) {
		mouse.down = false;
	});

	window.animationFrame.then(tick);
}

main() {
	init();
}
