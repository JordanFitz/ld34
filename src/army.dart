import "dart:math";

import "applicant.dart";
import "atlas.dart";
import "utils.dart" as utils;

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

		Atlas.strength[country] = strength;

		print(Atlas.strength.toString());

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

		if (atlas.target != null) {
			num currentStrength = atlas.slider.getValue();
			num enemyStrength = Atlas.strength[atlas.targetCountry];

			num d = new Random().nextDouble();

			if (currentStrength / enemyStrength > d) {
				atlas.addCountry(atlas.targetCountry);

				Atlas.strength[atlas.targetCountry] = (enemyStrength / 2).floor() + currentStrength;
				Atlas.strength[atlas.fromCountry] -= currentStrength;

				strength += (enemyStrength / 2).floor();
			}
		}

		List<String> otherCountries = new List<String>();

		Atlas.countryNames.forEach((String countryCode, String countryName) {
			if(!atlas.currentCountries.contains(countryCode)) {
				Atlas.strength[countryCode] += 8;
			}
		});

		atlas.availableCountries.forEach((borderingCountry) {

		});

		atlas.from = null;
		atlas.fromCountry = null;
		atlas.target = null;
		atlas.targetCountry = null;
	}
}