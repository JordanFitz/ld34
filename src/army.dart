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
	List events = new List<String>();

	num week = 0;

	Atlas atlas;

	num weekRecruits = 5;
	num recruitStrength = 0;

	Army(this.country, this.atlas) {
		Random random = new Random();

		gold = 80;
		food = 100;
		strength = 0;

		Atlas.strength[country] = strength;

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

	bool attack(num currentStrength, String attacking) {
		num enemyStrength = Atlas.strength[attacking];
		num d = new Random().nextDouble();

//		print("$enemyStrength $currentStrength");

		if (enemyStrength == 0) {
			return true;
		}

		if (currentStrength / enemyStrength > d) {
			return true;
		}

		return false;
	}

	progress() {
		men.forEach((man) {
			food -= man.requiredFood;
		});

		String target = atlas.targetCountry;
		String from = atlas.fromCountry;

		if (atlas.target != null) {
			num currentStrength = atlas.slider.getValue();
			num enemyStrength = Atlas.strength[atlas.targetCountry];

			if(attack(atlas.slider.getValue(), atlas.targetCountry)) {
				atlas.addCountry(atlas.targetCountry);

				Atlas.strength[atlas.targetCountry] = (enemyStrength / 2).floor() + currentStrength;
				Atlas.strength[atlas.fromCountry] -= currentStrength;
				if (enemies.containsKey(atlas.targetCountry)) enemies.remove(atlas.targetCountry);

				strength += (enemyStrength / 2).floor();
				food += ((enemyStrength / 4) * (1 + new Random().nextInt(5))).floor();
				gold += ((enemyStrength / 2) * (1 + new Random().nextInt(5))).floor();

				events.add("${Atlas.countryNames[atlas.targetCountry]} was captured by ${Atlas.countryNames[atlas.fromCountry]}!");
			} else {
				Atlas.strength[atlas.fromCountry] = (Atlas.strength[atlas.fromCountry] / 5) * 4;
				events.add("${Atlas.countryNames[atlas.targetCountry]} failed to capture ${Atlas.countryNames[atlas.fromCountry]}.");
			}

			atlas.from = null;
			atlas.fromCountry = null;
			atlas.target = null;
			atlas.targetCountry = null;
		}

		if (atlas.defenseTarget != null) {
			Atlas.strength[atlas.defenseFromCountry] -= atlas.defenseSlider.getValue();
			Atlas.strength[atlas.defenseTargetCountry] += atlas.defenseSlider.getValue();

			events.add("${Atlas.countryNames[atlas.defenseFromCountry]} reinforced ${Atlas.countryNames[atlas.defenseTargetCountry]}.");

			atlas.defenseFrom = null;
			atlas.defenseFromCountry = null;
			atlas.defenseTarget = null;
			atlas.defenseTargetCountry = null;
		}

		Map possibleAttackers = new Map<String, String>();
		List possibleAttackerCountries = new List<String>();

		enemies.forEach((attacker, attacking) {
			atlas.currentCountries.forEach((currentCountry) {
				if(Atlas.borders[attacker].contains(currentCountry) && currentCountry != target) {
					possibleAttackers[attacker] = currentCountry;
					possibleAttackerCountries.add(attacker);
				}
			});
		});

		bool generateEnemy = true;

		if(possibleAttackerCountries.length > 0) {
			String randomAttacker = possibleAttackerCountries[new Random().nextInt(possibleAttackerCountries.length)];

			num randomPercentage = new Random().nextDouble();

			if(randomPercentage < 0.5) {
				if(attack(Atlas.strength[randomAttacker], possibleAttackers[randomAttacker])) {
					strength -= Atlas.strength[possibleAttackers[randomAttacker]];

					if (Atlas.strength[randomAttacker] > Atlas.strength[possibleAttackers[randomAttacker]]) {
						Atlas.strength[possibleAttackers[randomAttacker]] += Atlas.strength[possibleAttackers[randomAttacker]];
						Atlas.strength[randomAttacker] -= Atlas.strength[randomAttacker];
					} else {
						Atlas.strength[randomAttacker] -= Atlas.strength[possibleAttackers[randomAttacker]];
					}

					atlas.removeCountry(possibleAttackers[randomAttacker]);

					enemies[possibleAttackers[randomAttacker]] = possibleAttackers[randomAttacker];

					generateEnemy = false;

					events.add("Ally ${Atlas.countryNames[randomAttacker]} has deafated ${Atlas.countryNames[possibleAttackers[randomAttacker]]}!");
				} else {
					events.add("Ally ${Atlas.countryNames[randomAttacker]} failed to deafat ${Atlas.countryNames[possibleAttackers[randomAttacker]]}.");
				}
			}
		}

		if(generateEnemy) {
			Atlas.countryNames.forEach((String countryCode, String countryName) {
				if(!atlas.currentCountries.contains(countryCode)) {
					Atlas.strength[countryCode] += 8;
				}
			});

			List<String> otherCountries = new List<String>();
			atlas.availableCountries.forEach((borderingCountry) {
				otherCountries.add(borderingCountry);
			});

			String randomEnemy = otherCountries[new Random().nextInt(otherCountries.length)];

			List<String> possibleCountries = new List<String>();
			Atlas.borders[randomEnemy].forEach((borderingCountry) {
				possibleCountries.add(borderingCountry);
			});

			String randomCountry = possibleCountries[new Random().nextInt(possibleCountries.length)];

			if(!enemies.containsKey(randomEnemy)) {
				enemies[randomEnemy] = randomCountry;
				enemyOverlays.add(Atlas.overlays[randomEnemy]);
				events.add("${Atlas.countryNames[randomEnemy]} has joined the allies.");
			}

			week++;
		}

//		hacky fix to -strength bug
		Atlas.strength.forEach((country, strength) {
			if(strength < 0) Atlas.strength[country] = 0;
		});
	}
}