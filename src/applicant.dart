import "dart:math";
import "dart:html";

import "featureset.dart";
import "utils.dart" as utils;

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

		height = 2 + (random.nextInt(3));

		visualFeatures.randomize();
	}

	render(CanvasRenderingContext2D context, num x, num y) {
		num renderY = y - height * 100;
		num renderX = x;

		utils.drawRect(context, renderX, renderY, 200, y - renderY, "rgba(0, 0, 0, 0.2)");

		// Placeholder "graphics"
		if (visualFeatures.hatType != 0) {
		 	num hatColor = (255 / visualFeatures.hatType).round();
			utils.drawRect(context, renderX - 20, renderY - 90, 240, 120, "rgb($hatColor, ${hatColor * 2}, $hatColor)");
		}

		if (visualFeatures.beardType != 0) {
			num beardColor = (255 / visualFeatures.beardType).round();
			utils.drawRect(context, renderX + 40, renderY + 90, 120, 50, "rgb($beardColor, $beardColor, ${beardColor * 2})");
		}

		if (visualFeatures.shirtType != 0) {
			num shirtColor = (255 / visualFeatures.shirtType).round();
			utils.drawRect(context, renderX, renderY + 175, 200, y - renderY, "rgb(${shirtColor * 2}, $shirtColor, $shirtColor)");
		}

		utils.drawText(context, "STRENGTH: $strength", 50, 50, "Propaganda", 25, "#fff", false);
		utils.drawText(context, "FOOD: $requiredFood", 50, 80, "Propaganda", 25, "#fff", false);
		utils.drawText(context, "GOLD: $requiredGold", 50, 110, "Propaganda", 25, "#fff", false);
	}
}