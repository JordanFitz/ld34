import "dart:html";
import "dart:convert";
import "dart:math";

import "texture.dart";
import "utils.dart" as utils;
import "army.dart";
import "slider.dart";

class Atlas {
	static Map countryCodes = {
		"0,0,0": "NONE",
		"241,185,214": "NORWAY",
		"191,211,160": "FINLAND",
		"179,177,216": "SWEDEN",
		"235,207,204": "DENMARK",
		//"255,251,167": "RUSSIA",
		"246,152,153": "UNITED_KINGDOM",
		"159,186,84": "IRELAND",
		"254,205,103": "FRANCE",
		"105,189,68": "BELGIUM",
		"251,244,156": "NETHERLANDS",
		"252,226,103": "GERMANY",
		"227,251,173": "POLAND",
		"203,154,199": "LITHUANIA",
		"105,189,88": "LATVIA",
		"254,199,129": "BELARUS",
		"203,151,101": "ESTONIA",
		"203,154,157": "SPAIN",
		"253,255,172": "PORTUGAL",
		"254,204,153": "CZECH_REP.",
		"168,207,88": "AUSTRIA",
		"246,235,21": "SWITZERLAND",
		"206,193,223": "UKRAINE",
		"135,209,212": "SLOVAKIA",
		"253,255,171": "HUNGARY",
		"226,226,252": "ITALY",
		"232,191,251": "SLOVENIA",
		"240,239,157": "CROATIA",
		"203,159,75": "BOSNIA",
		"195,226,221": "SERBIA",
		"248,133,138": "MONTENEGRO",
		"179,169,192": "ALBANIA",
		"234,213,192": "KOSOVO",
		"246,215,21": "MACEDONIA",
		"133,156,70": "GREECE",
		"199,247,189": "TURKEY",
		"254,220,146": "ARMENIA",
		"247,229,207": "GEORGIA",
		"246,152,131": "ROMANIA",
		"189,150,94": "BULGARIA",
		"250,247,194": "MOLDOVA"
	};

	static Map countryNames = {
		"NORWAY": "Norway",
		"FINLAND": "Finland",
		"SWEDEN": "Sweden",
		"DENMARK": "Denmark",
//		"RUSSIA": "Russia",
		"UNITED_KINGDOM": "United Kingdom",
		"IRELAND": "Ireland",
		"FRANCE": "France",
		"BELGIUM": "Belgium",
		"NETHERLANDS": "Netherlands",
		"GERMANY": "Germany",
		"POLAND": "Poland",
		"LITHUANIA": "Lithuania",
		"LATVIA": "Latvia",
		"BELARUS": "Belarus",
		"ESTONIA": "Estonia",
		"SPAIN": "Spain",
		"PORTUGAL": "Portugal",
		"CZECH_REP.": "Czech Rep.",
		"AUSTRIA": "Austria",
		"SWITZERLAND": "Switzerland",
		"UKRAINE": "Ukraine",
		"SLOVAKIA": "Slovakia",
		"HUNGARY": "Hungary",
		"ITALY": "Italy",
		"SLOVENIA": "Slovenia",
		"CROATIA": "Croatia",
		"BOSNIA": "Bosnia",
		"SERBIA": "Serbia",
		"MONTENEGRO": "Montenegro",
		"ALBANIA": "Albania",
		"KOSOVO": "Kosovo",
		"MACEDONIA": "Macedonia",
		"GREECE": "Greece",
		"TURKEY": "Turkey",
		"ARMENIA": "Armenia",
		"GEORGIA": "Georgia",
		"ROMANIA": "Romania",
		"BULGARIA": "Bulgaria",
		"MOLDOVA": "Moldova"
	};

	static Map borders = new Map<String, List<String>>();
	static Map overlays = new Map<String, Map<String, num>>();
	static Map strength = new Map<String, num>();

	List<String> availableCountries = new List<String>();
	List<String> currentCountries = new List<String>();

	List<Map<String, num>> currentOverlays = new List<Map<String, num>>();

	Point offset = new Point(85, 0);
	Point downOffset = null;

	Texture visibleMap = new Texture("images/map_friendly.png");
	Texture coloredMap = new Texture("images/map_colors.png");
	Texture outlineMap = new Texture("images/map_outline.png");
	Texture countryOverlays = new Texture("images/overlays.png");
	Texture enemyOverlays = new Texture("images/overlays_blue.png");
	Texture water = new Texture("images/water.png");

	CanvasElement colorsCanvas = new CanvasElement();
	CanvasRenderingContext2D colorsContext;

	String baseCountry = null;

	Point from = null;
	Point target = null;
	Point tempTarget = null;

	String targetCountry = null;
	String fromCountry = null;

	Point defenseFrom = null;
	Point defenseTarget = null;
	Point defenseTempTarget = null;

	String defenseTargetCountry = null;
	String defenseFromCountry = null;

	Slider slider;
	Slider defenseSlider;

	num arrowsRotation = 0;

	num width = 0;
	num height = 0;

	Atlas(this.width, this.height) {
		colorsCanvas.width = width;
		colorsCanvas.height = height;

		colorsContext = colorsCanvas.context2D;

		HttpRequest.getString("borders.json").then((response) {
			borders = JSON.decode(response);
		});

		HttpRequest.getString("overlays.json").then((response) {
			overlays = JSON.decode(response);
		});

		Atlas.countryNames.forEach((String countryCode, String countryName) {
			strength[countryCode] = (5 + new Random().nextInt(5));
		});
	}

	bool texturesLoaded() {
		return (visibleMap.loaded && coloredMap.loaded && outlineMap.loaded && countryOverlays.loaded && enemyOverlays.loaded && water.loaded);
	}

	String getCountry(num x, num y) {
		List<int> data = colorsContext.getImageData(x, y, 1, 1).data;

		String colorCode = "${data[0]},${data[1]},${data[2]}";
		String countryCode = countryCodes[colorCode];

		if (countryCode == "NONE" || !countryCodes.containsKey(colorCode)) return null;

		return countryCodes[colorCode];
	}

	addCountry(String countryCode) {
		if (availableCountries.contains(countryCode)) {
			availableCountries.remove(countryCode);
		}

		if (!currentCountries.contains(countryCode)) {
			currentCountries.add(countryCode);
			currentOverlays.add(overlays[countryCode]);
		}

		List<String> borderingCountries = borders[countryCode];

		for (num i = 0; i < borderingCountries.length; i++) {
			String country = borderingCountries[i];
			if (!availableCountries.contains(country) && !currentCountries.contains(country)) {
				availableCountries.add(country);
			}
		}
	}

	removeCountry(String countryCode) {
		if (currentCountries.contains(countryCode)) {
			currentCountries.remove(countryCode);
		}

		availableCountries.clear();

		currentCountries.forEach((country) {
			List<String> borderingCountries = borders[country];

			for (num i = 0; i < borderingCountries.length; i++) {
				String country = borderingCountries[i];
				if (!availableCountries.contains(country) && !currentCountries.contains(country)) {
					availableCountries.add(country);
				}
			}
		});
	}

	render(CanvasRenderingContext2D context, Army army, Texture spritesheet, Map textureRects) {
		if (offset.x < 85) offset = new Point(85, offset.y);
		if (offset.y < 0) offset = new Point(offset.x, 0);

		if (offset.x > visibleMap.image.width - width - 32) offset = new Point(visibleMap.image.width - width - 32, offset.y);
		if (offset.y > visibleMap.image.height - height - 75) offset = new Point(offset.x, visibleMap.image.height - height - 75);

		Rectangle destination = new Rectangle(0, 0, width, height);
		Rectangle source = new Rectangle(offset.x, offset.y, width, height);

		colorsContext.clearRect(0, 0, width, height);

		colorsContext.drawImageToRect(coloredMap.image, destination, sourceRect: source);

		context.drawImageToRect(water.image, destination, sourceRect: source);
		context.drawImageToRect(visibleMap.image, destination, sourceRect: source);

		if (army != null) {
			army.enemies.forEach((enemy, attacking) {
				Map<String, num> overlay = overlays[enemy];

				Rectangle overlaySource = new Rectangle(overlay["sourceX"], overlay["sourceY"], overlay["width"], overlay["height"]);
				Rectangle overlayDestination = new Rectangle(overlay["destX"] - offset.x, overlay["destY"] - offset.y, overlay["width"], overlay["height"]);

				context.drawImageToRect(enemyOverlays.image, overlayDestination, sourceRect: overlaySource);
			});
		}

		if(tempTarget != null) {
			availableCountries.forEach((country) {
				if(fromCountry != null && borders[fromCountry].contains(country)) {
					Map<String, num> overlay = overlays[country];

					Rectangle overlaySource = new Rectangle(overlay["sourceX"], overlay["sourceY"], overlay["width"], overlay["height"]);
					Rectangle overlayDestination = new Rectangle(overlay["destX"] - offset.x, overlay["destY"] - offset.y, overlay["width"], overlay["height"]);

					context.globalAlpha = 0.3;
					context.drawImageToRect(countryOverlays.image, overlayDestination, sourceRect: overlaySource);
					context.globalAlpha = 1;
				}
			});
		}

		currentCountries.forEach((country) {
			Map<String, num> overlay = overlays[country];

			Rectangle overlaySource = new Rectangle(overlay["sourceX"], overlay["sourceY"], overlay["width"], overlay["height"]);
			Rectangle overlayDestination = new Rectangle(overlay["destX"] - offset.x, overlay["destY"] - offset.y, overlay["width"], overlay["height"]);

			context.drawImageToRect(countryOverlays.image, overlayDestination, sourceRect: overlaySource);
		});

		context.drawImage(outlineMap.image, -offset.x, -offset.y);

		if (baseCountry == null) {
			utils.drawTextWithShadow(context, "Select a base country", 20, 20, "Propaganda", 30, false);
		} else if (from != null) {
			context.setLineDash([14, 14]);
			context.strokeStyle = "#fff";
			context.lineWidth = 7;

			context.beginPath();
			context.moveTo(from.x - offset.x, from.y - offset.y);

			if (tempTarget != null) {
				context.lineTo(tempTarget.x, tempTarget.y);
				context.stroke();
			}

			if (target != null) {
				num x = target.x - offset.x;
				num y = target.y - offset.y;

				context.lineTo(x, y);
				context.stroke();
			}

			if(tempTarget != null || target != null) {
				num circleWidth = textureRects["arrowsCenter"].width / 2;
				num circleHeight = textureRects["arrowsCenter"].width / 2;

				num arrowsWidth = textureRects["arrows"].width / 2;
				num arrowsHeight = textureRects["arrows"].height / 2;

				num x;
				num y;

				if(target != null) {
					x = target.x - offset.x;
					y = target.y - offset.y;

					if(slider == null) {
						slider = new Slider(strength[targetCountry], strength[fromCountry] < strength[targetCountry] ? strength[fromCountry] : strength[targetCountry]);
					}

					slider.render(context, spritesheet, textureRects, x, y - 70);
				} else {
					x = tempTarget.x;
					y = tempTarget.y;

					slider = null;
				}

				context.drawImageToRect(spritesheet.image, new Rectangle(x - circleWidth / 2, y - circleHeight / 2, circleWidth, circleHeight), sourceRect: textureRects["arrowsCenter"]);

				context.translate(x - arrowsWidth / 2, y - arrowsHeight / 2);
				context.translate(arrowsWidth / 2, arrowsHeight / 2);
				context.rotate(arrowsRotation);
				context.drawImageToRect(spritesheet.image, new Rectangle(-arrowsWidth / 2, -arrowsHeight / 2, arrowsWidth, arrowsHeight), sourceRect: textureRects["arrows"]);

				context.setTransform(1, 0, 0, 1, 0, 0);

				arrowsRotation += 0.01;
			}
		}

		if (defenseFrom != null) {
			context.strokeStyle = "#000";
			context.lineWidth = 5;

			context.beginPath();
			context.moveTo(defenseFrom.x - offset.x, defenseFrom.y - offset.y);

			num x;
			num y;

			if(defenseTempTarget != null) {
				x = defenseTempTarget.x;
				y = defenseTempTarget.y;

				context.lineTo(x, y);
				defenseSlider = null;
			} else if (defenseTarget != null) {
				x = defenseTarget.x - offset.x;
				y = defenseTarget.y - offset.y;

				context.lineTo(x, y);

				if (defenseSlider == null) {
					defenseSlider = new Slider(strength[defenseFromCountry], strength[defenseFromCountry]);
				} else {
					defenseSlider.render(context, spritesheet, textureRects, x, y - 50);
				}
			} else {
				x = -999;
				y = -999;
			}

			context.setLineDash([12, 12]);
			context.stroke();

			num arrowsWidth = textureRects["smallArrows"].width / 2;
			num arrowsHeight = textureRects["smallArrows"].height / 2;

			context.drawImageToRect(spritesheet.image, new Rectangle(x - arrowsWidth / 2, y - arrowsHeight / 2, arrowsWidth, arrowsHeight), sourceRect: textureRects["smallArrows"]);
		}

		if(army != null) {
			utils.drawTextWithShadow(context, "Strength: ${army.strength.floor()}", 20, 20, "Propaganda", 30, false);
			utils.drawTextWithShadow(context, "Food: ${army.food.floor()}", 20, 50, "Propaganda", 30, false);
			utils.drawTextWithShadow(context, "Gold: ${army.gold.floor()}", 20, 80, "Propaganda", 30, false);
		}
	}
}