import "dart:html";

import "texture.dart";
import "utils.dart" as utils;

class Atlas {
	static Map countryCodes = {
		"0,0,0": "NONE"
	};

	static Map countryNames = {

	};

	Point offset = new Point(0, 0);

	Texture visibleMap = new Texture("images/map_friendly.png");
	Texture coloredMap = new Texture("images/map_colors.png");

	CanvasElement colorsCanvas = new CanvasElement();
	CanvasRenderingContext2D colorsContext;

	String baseCountry = null;

	num width = 0;
	num height = 0;

	Atlas(this.width, this.height) {
		colorsCanvas.width = width;
		colorsCanvas.height = height;

		colorsContext = colorsCanvas.context2D;

		colorsContext.drawImage(coloredMap.image, 0 - offset.x, 0 - offset.y);
	}

	String getCountry(num x, num y) {
		List<int> data = colorsContext.getImageData(x, y, 1, 1).data;

		string colorCode = "${data[0]},${data[1]},${data[2]}";
		string countryCode = countryCodes[colorCode];

		if (countryCode == "NONE") return null;

		return colorCode;
	}

	render(CanvasRenderingContext2D context) {
		if (offset.x < 0) offset = new Point(0, offset.y);
		if (offset.y < 0) offset = new Point(offset.x, 0);

		if (offset.x > visibleMap.image.width - width) offset = new Point(visibleMap.image.width - width, offset.y);
		if (offset.y > visibleMap.image.height - height) offset = new Point(offset.x, visibleMap.image.height - height);

		Rectangle destination = new Rectangle(0, 0, width, height);
		Rectangle source = new Rectangle(offset.x, offset.y, width, height);

		context.drawImageToRect(visibleMap.image, destination, sourceRect: source);
		colorsContext.drawImageToRect(coloredMap.image, destination, sourceRect: source);

		if (baseCountry == null) {
			utils.drawText(context, "Select a base country", 21, 21, "Propaganda", 30, "rgba(255, 255, 255, 0.6)", false);
			utils.drawText(context, "Select a base country", 20, 20, "Propaganda", 30, "#000", false);

			utils.drawText(context, "Use middle mouse button to pan", 21, 56, "Propaganda", 21, "rgba(255, 255, 255, 0.6)", false);
			utils.drawText(context, "Use middle mouse button to pan", 20, 55, "Propaganda", 21, "#000", false);
		}
	}
}