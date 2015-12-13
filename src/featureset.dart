import 'dart:math';

class FeatureSet {
	num hatType = 0;
	num beardType = 0;
	num eyeType = 0;

	num eyeTypeVariant = 0;

	Rectangle eyeRect;
	Rectangle hatRect;

	randomize() {
		Random random = new Random();

		beardType = random.nextInt(6);
		hatType = random.nextInt(9);
		eyeType = random.nextInt(19);

		eyeRect = new Rectangle(0, 677 + (eyeType * 145), 240, 145);
		hatRect = new Rectangle(240, 677 + (hatType * 256), 320, 256);
	}
}