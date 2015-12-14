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
		strength = 6 + atlas.availableCountries.length * (1 + random.nextInt(2));

		List<String> otherCountries = new List<String>();

		Atlas.countryNames.forEach((String countryCode, String countryName) {
			if(country != countryCode && !Atlas.borders[country].contains(countryCode)) otherCountries.add(countryCode);
		});

		while(enemies.length < 3) {
			num randomIndex = random.nextInt(otherCountries.length);
			String randomCountry = otherCountries[randomIndex];

			enemies[randomCountry] = country;

			otherCountries.remove(randomIndex);
		}

		enemies.forEach((attacker, attacking) {
			enemyOverlays.add(Atlas.overlays[attacker]);
		});
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