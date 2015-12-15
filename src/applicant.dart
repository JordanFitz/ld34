import "dart:math";
import "dart:html";

import "featureset.dart";
import "utils.dart" as utils;
import "texture.dart";
import "army.dart";

class Applicant {
	// 1 = short, 2 = medium, 3 = tall
	num height = 0;

	num strength = 0;
	num requiredGold = 0;
	num requiredFood = 0;

	Army army;

	FeatureSet visualFeatures = new FeatureSet();

	Applicant(this.army);

	randomize() {
		Random random = new Random();

		strength = utils.chance(random.nextDouble(), 11);

		requiredGold = (1 + random.nextInt(15) / (strength / 10)).round();
		requiredFood = (1 + random.nextInt(15) / (strength / 3)).round();

		height = random.nextInt(3);

		visualFeatures.randomize();
	}

	render(CanvasRenderingContext2D context, Texture spritesheet, Map<String, Rectangle> textureRects, num width, num height) {
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

		Rectangle statsDestination = new Rectangle(125, 0, textureRects["statsBoard"].width, textureRects["statsBoard"].height);
		context.drawImageToRect(spritesheet.image, statsDestination, sourceRect: textureRects["statsBoard"]);

		utils.drawText(context, "${visualFeatures.firstName}", 160, 135, "Propaganda", 25, "#bcbcbc", false);
		utils.drawText(context, "${visualFeatures.lastName}", 160, 155, "Propaganda", 25, "#bcbcbc", false);

		utils.drawText(context, "$strength", 200, 225, "Propaganda", 25, "#bcbcbc", false);
		utils.drawText(context, "$requiredFood", 282, 225, "Propaganda", 25, "#bcbcbc", false);

		if (army != null && army.gold >= requiredGold)
			utils.drawText(context, "$requiredGold", 200, 295, "Propaganda", 25, "#bcbcbc", false);
		else
			utils.drawText(context, "$requiredGold", 200, 295, "Propaganda", 25, "#aa3b3d", false);

		Rectangle bodySource = new Rectangle(this.height * 226, 230, 226, bodyHeight);
		Rectangle bodyDestination = new Rectangle(width / 2 - 113, height - 200 - bodyHeight, 226, bodyHeight);

		context.drawImageToRect(spritesheet.image, bodyDestination, sourceRect: bodySource);

		Rectangle eyeDestination = new Rectangle(width / 2 - 120, height - 200 - bodyHeight + 10, 240, 145);
		context.drawImageToRect(spritesheet.image, eyeDestination, sourceRect: visualFeatures.eyeRect);

		Rectangle mouthAreaDestination = new Rectangle(width / 2 - 125, height - 200 - bodyHeight - 30, 250, 250);

		context.drawImageToRect(spritesheet.image, mouthAreaDestination, sourceRect: visualFeatures.mouthRect);
		context.drawImageToRect(spritesheet.image, mouthAreaDestination, sourceRect: visualFeatures.mustacheRect);
		context.drawImageToRect(spritesheet.image, mouthAreaDestination, sourceRect: visualFeatures.beardRect);

		Rectangle shirtDest = new Rectangle(width / 2 - 133, height - 200 - bodyHeight + 98, 255, 366);

		context.drawImageToRect(spritesheet.image, shirtDest, sourceRect: visualFeatures.shirtRect);
		context.drawImageToRect(spritesheet.image, shirtDest, sourceRect: visualFeatures.accessoryRect);

		Rectangle hatDestination = new Rectangle(width / 2 - 160, height - 200 - bodyHeight - 140, 320, 256);
		context.drawImageToRect(spritesheet.image, hatDestination, sourceRect: visualFeatures.hatRect);
	}
}