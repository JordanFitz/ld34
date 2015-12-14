import 'dart:math';

class FeatureSet {
	num hatType = 0;
	num eyeType = 0;
	num mouthType = 0;
	num mustacheType = 0;
	num beardType = 0;

	num eyeTypeVariant = 0;

	Rectangle eyeRect;
	Rectangle hatRect;
	Rectangle mouthRect;
	Rectangle mustacheRect;
	Rectangle beardRect;

	randomize() {
		Random random = new Random();

		hatType = random.nextInt(10);
		eyeType = random.nextInt(19);
		mouthType = random.nextInt(9);
		mustacheType = random.nextInt(10);
		beardType = random.nextInt(4);

		eyeRect = new Rectangle(0, 677 + (eyeType * 145), 240, 145);
		hatRect = new Rectangle(240, 677 + (hatType * 256), 320, 256);
		mouthRect = new Rectangle(559, 677 + (mouthType * 250), 250, 250);
		mustacheRect = new Rectangle(809, 677 + (mustacheType * 250), 250, 250);
		beardRect = new Rectangle(559, 2927 + (beardType * 250), 250, 250);
	}
}