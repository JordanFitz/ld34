import "dart:html";
import "dart:math";

drawText(CanvasRenderingContext2D context, String text, num x, num y, String font, num size, String color, bool centered) {
	String oldFillStyle = context.fillStyle;
	String oldBaseline = context.textBaseline;
	String oldAlign = context.textAlign;
	String oldFont = context.font;

	context.font = '${size}px "$font"';
	context.textAlign = centered ? "center" : "left";
	context.textBaseline = "top";
	context.fillStyle = color;
	context.fillText(text, x, y);

	context.font = oldFont;
	context.textAlign = oldAlign;
	context.textBaseline = oldBaseline;
	context.fillStyle = oldFillStyle;
}

drawRect(CanvasRenderingContext2D context, num x, num y, num width, num height, String color) {
	String oldFillStyle = context.fillStyle;

	context.fillStyle = color;
	context.fillRect(x, y, width, height);

	context.fillStyle = oldFillStyle;
}

drawBox(CanvasRenderingContext2D context, Rectangle box, String color) {
	String oldFillStyle = context.fillStyle;

	context.fillStyle = color;
	context.fillRect(box.left, box.top, box.width, box.height);

	context.fillStyle = oldFillStyle;
}

within(num x1, num y1, num x2, num y2, num width, num height) {
	return (x1 > x2 && x1 <= x2 + width && y1 > y2 && y1 <= y2 + height);
}

withinBox(num x, num y, Rectangle box) {
	return (x > box.left && x <= box.left + box.width && y > box.top && y <= box.top + box.height);
}

num chance(num d, num variations) {
	if (d < 0.1) d = 0.1;

	num percentage = 1 / variations;
	num result = variations;

	for(num i = 0; i < variations; i++) {
		if (d >= result * percentage) return 1 + new Random().nextInt(i);

		result--;
	}
}