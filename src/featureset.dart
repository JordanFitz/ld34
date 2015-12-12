import 'dart:math';

class FeatureSet {
	num hatType = 0;
	num beardType = 0;
	num shirtType = 0;
	num hairType = 0;

	randomize() {
		Random random = new Random();

		hatType = random.nextInt(6);
		beardType = random.nextInt(6);
		shirtType = random.nextInt(6);
		hairType = random.nextInt(6);
	}
}