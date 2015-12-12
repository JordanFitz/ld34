import "dart:html";

CanvasElement canvas = querySelector("canvas#canvas");
CanvasRenderingContext2D context = canvas.context2D;

const num WIDTH = 1280;
const num HEIGHT = 720;

update(num delta) {

}

draw() {
	context.clearRect(0, 0, WIDTH, HEIGHT);
}

tick(num delta) {
	update(delta);
	draw();

	window.animationFrame.then(tick);
}

init() {
	canvas.width = WIDTH;
	canvas.height = HEIGHT;

	window.animationFrame.then(tick);
}

main() {
	init();
}
