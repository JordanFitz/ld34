import "dart:math";
import "dart:html";

import "featureset.dart";
import "utils.dart" as utils;
import "texture.dart";

class Applicant {
	// 1 = short, 2 = medium, 3 = tall
	num height = 0;

	num strength = 0;
	num requiredGold = 0;
	num requiredFood = 0;

	FeatureSet visualFeatures = new FeatureSet();

	randomize() {
		Random random = new Random();

		strength = utils.chance(random.nextDouble(), 11);

		requiredGold = (1 + random.nextInt(15) / (strength / 4)).round();
		requiredFood = (1 + random.nextInt(15) / (strength / 4)).round();

		height = random.nextInt(3);

		visualFeatures.randomize();
	}

	render(CanvasRenderingContext2D context, Texture spritesheet, num width, num height) {
		num bodyHeight = 0;

		switch (this.height) {
			case 0:
				bodyHeight = 448;

				break;
			case 1:
				bodyHeight = 334;

				break;
			case 2:
				bodyHeight = 218;

				break;
		}

		Rectangle bodySource = new Rectangle(this.height * 226, 230, 226, bodyHeight);
		Rectangle bodyDestination = new Rectangle(width / 2 - 113, height - 200 - bodyHeight, 226, bodyHeight);

		context.drawImageToRect(spritesheet.image, bodyDestination, sourceRect: bodySource);

		Rectangle eyeDestination = new Rectangle(width / 2 - 120, height - 200 - bodyHeight + 10, 240, 145);
		context.drawImageToRect(spritesheet.image, eyeDestination, sourceRect: visualFeatures.eyeRect);

		Rectangle hatDestination = new Rectangle(width / 2 - 160, height - 200 - bodyHeight - 140, 320, 256);
		context.drawImageToRect(spritesheet.image, hatDestination, sourceRect: visualFeatures.hatRect);

		// Placeholder "graphics"
		if (visualFeatures.hatType != 0) {

		}

		if (visualFeatures.beardType != 0) {

		}

		if (visualFeatures.eyeType != 0) {

		}
	}
}