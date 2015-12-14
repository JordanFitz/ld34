import "applicant.dart";
import "atlas.dart";
import "dart:math";

class Army {
	num gold;
	num food;
	num strength;

	List<Applicant> men = new List<Applicant>();

	Map<String, String> enemies = new Map<String, String>();
	List<Map<String, num>> enemyOverlays = new List<Map<String, num>>();

	String country;

	Map<String, num> defense = new Map<String, num>();

	Atlas atlas;

	Army(this.country, this.atlas) {
		Random random = new Random();

		gold = 80;
		food = 100;
		strength = atlas.availableCountries.length * (2 + random.nextInt(4));

		List<String> otherCountries = new List<String>();

		Atlas.countryNames.forEach((String countryCode, String countryName) {
			if(country != countryCode && !Atlas.borders[country].contains(countryCode)) otherCountries.add(countryCode);
		});

		enemies[otherCountries[random.nextInt(otherCountries.length)]] = country;
		enemies[otherCountries[random.nextInt(otherCountries.length)]] = country;
		enemies[otherCountries[random.nextInt(otherCountries.length)]] = country;

		enemies.forEach((attacker, attacking) {
			enemyOverlays.add(Atlas.overlays[attacker]);
		});

		defense[country] = strength;
	}

	hireApplicant(Applicant applicant) {
		gold -= applicant.requiredGold;
		food -= applicant.requiredFood;
		strength += applicant.strength;

		men.add(applicant);
	}

	progress() {
		men.forEach((man) {
			food -= man.requiredFood;
		});

		atlas.availableCountries.forEach((borderingCountry) {

		});
	}
}