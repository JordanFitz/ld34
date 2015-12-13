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
		hatType = 1 + random.nextInt(9);
		eyeType = 1 + random.nextInt(19);

		num eyeX;
		num eyeY;



		eyeRect = new Rectangle((eyeType / 4).floor() * 243, 678 + (eyeType / 5).floor() * 147, 243, 147);
		hatRect = new Rectangle((hatType / 3).floor() * 301, 1263 + (hatType / 4).floor() * 241, 301, 241);

		print(eyeRect.toString());
	}
}