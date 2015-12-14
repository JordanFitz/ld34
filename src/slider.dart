import "dart:html";

import "texture.dart";
import "utils.dart" as utils;

class Slider {
	num high;
	num max;
	num value;

	num handleX = null;
	num sliderX;
	num sliderWidth;

	Rectangle rect = null;

	Slider(this.high, this.max) {
		value = max;
	}

	setValue() {
		num sx = handleX - sliderX;
		num ratio = sx / sliderWidth;

		value = high * (sx / sliderWidth);
	}

	num getValue() {
		if (value < 1) value = 1;
		if (value > max) value = max;

		return value.floor();
	}

	render(CanvasRenderingContext2D context, Texture spritesheet, Map<String, Rectangle> textureRects, num startX, num y) {
		if (value < 1) value = 1;
		if (value > max) value = max;

		print("$value $max $high");

		num width = textureRects["slider"].width;
		num height = textureRects["slider"].height;

		num x = startX - width / 2;

		sliderX = x;
		sliderWidth = width;

		Rectangle destination = new Rectangle(x, y, width, height);

		context.drawImageToRect(spritesheet.image, destination, sourceRect: textureRects["slider"]);

		if(high != 0) {
			num ratio = value / high;
			handleX = x + (width * ratio);
		} else {
			handleX = x;
		}

		destination = new Rectangle(handleX - textureRects["sliderHandle"].width / 2, y - 10, textureRects["sliderHandle"].width, textureRects["sliderHandle"].height);
		rect = destination;
		context.drawImageToRect(spritesheet.image, destination, sourceRect: textureRects["sliderHandle"]);

		utils.drawTextWithShadow(context, "${value.floor()}", handleX, y - 32, "Propaganda", 20, true);

		utils.drawTextWithShadow(context, "0", x - 28, y + 1, "Propaganda", 20, false);
		utils.drawTextWithShadow(context, "$high", x + width + 16, y + 1, "Propaganda", 20, false, color: max < high ? "#993638" : "#fff");
	}
}