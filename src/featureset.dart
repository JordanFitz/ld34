import 'dart:math';

class FeatureSet {
	List firstNames = ["Devin", "Moshe", "Hershel", "Arthur", "Wilmer", "Clyde", "Chet", "Roger", "Toby", "Porter", "Scottie", "Denis", "Neal", "Elbert", "Sebastian", "Chong", "Loren", "Dustin", "Jefferson", "Zachary", "Bruce", "Frederick", "Carrol", "Markus", "Jaime", "Billy", "Rufus", "Michael", "Quentin", "Geoffrey", "Antony", "Vernon", "Cliff", "Brain", "Brent", "Adam", "Edgardo", "Hong", "Clifford", "Harris", "Eddy", "Johnny", "Rob", "Aurelio", "Kristofer", "Carlton", "Olen", "Kurt", "Abdul", "Steven"];
	List lastNames = ["Beyer", "Pound", "Beard", "Mangus", "Innes", "Lavigne", "Ploof", "Eckler", "Antley", "Seibert", "Schaefer", "Sharrock", "Horrigan", "Neiss", "Dople", "Meraz", "Valadez", "Tibbits", "Likes", "Anthony", "Silvestre", "Vert", "Quarles", "Shupe", "Baade", "Dykema", "Buster", "Chapell", "Renna", "Weissinger", "Ramerez", "Rosato", "Godard", "Rogue", "Longacre", "Kadel", "Roach", "Costantino", "Newsome", "Moultrie", "Lent", "Litteral", "Spalding", "Bulluck", "Bain", "Danley", "Hallee", "Westbury", "Porcaro", "Moskowitz"];

	num hatType = 0;
	num eyeType = 0;
	num mouthType = 0;
	num mustacheType = 0;
	num beardType = 0;
	num shirtType = 0;
	num accessoryType = 0;

	String firstName;
	String lastName;

	Rectangle eyeRect;
	Rectangle hatRect;
	Rectangle mouthRect;
	Rectangle mustacheRect;
	Rectangle beardRect;
	Rectangle shirtRect;
	Rectangle accessoryRect;

	randomize() {
		Random random = new Random();

		hatType = random.nextInt(10);
		eyeType = random.nextInt(19);
		mouthType = random.nextInt(9);
		mustacheType = random.nextInt(10);
		beardType = random.nextInt(4);
		shirtType = random.nextInt(6);
		accessoryType = random.nextInt(8);

		eyeRect = new Rectangle(0, 677 + (eyeType * 145), 240, 145);
		hatRect = new Rectangle(240, 677 + (hatType * 256), 320, 256);
		mouthRect = new Rectangle(559, 677 + (mouthType * 250), 250, 250);
		mustacheRect = new Rectangle(809, 677 + (mustacheType * 250), 250, 250);
		beardRect = new Rectangle(559, 2927 + (beardType * 250), 250, 250);
		shirtRect = new Rectangle(1056, 677 + (shirtType * 366), 255, 366);
		accessoryRect = new Rectangle(1310, 677 + (accessoryType * 366), 255, 366);

		firstName = firstNames[random.nextInt(firstNames.length)];
		lastName = lastNames[random.nextInt(lastNames.length)];
	}
}