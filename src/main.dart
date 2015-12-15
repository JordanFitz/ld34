import "dart:html";
import "dart:async";
import "dart:math";

import "utils.dart" as utils;
import "mouse.dart" as mouse;
import "texture.dart";
import "applicant.dart";
import "atlas.dart";
import "army.dart";
import "fadetoblack.dart";

CanvasElement canvas = querySelector("canvas#canvas");
CanvasRenderingContext2D context = canvas.context2D;

const num WIDTH = 1280;
const num HEIGHT = 720;

num backgroundOpacity = 0.0;
bool backgroundDirection = false;

enum GameState {
	MENU, MAP, INTERVIEW, NEWS, OVER, LOADING, HOW
}

GameState gameState = GameState.MENU;

Map keys = new Map<num, bool>();
Map keycodes = {
	"w": 87,
	"a": 65,
	"s": 83,
	"d": 68,
	"r": 82
};

Map textures = new Map<String, Texture>();
Map textureRects = new Map<String, Rectangle>();
Map textureSizes = new Map<String, Point>();
Map textureLocations = new Map<String, Rectangle>();

num lastDelta = 0;

Rectangle playButton = new Rectangle(WIDTH / 2, 310, 500, 45);
Rectangle howtoButton = new Rectangle(WIDTH / 2, 365, 500, 45);
Rectangle backButton = new Rectangle(20, HEIGHT - 65, 300, 45);

Applicant applicant = new Applicant(army);

Atlas atlas = new Atlas(WIDTH, HEIGHT);
Army army;

FadeToBlack fadeToBlack = new FadeToBlack();
FadeToBlack interviewTransition = new FadeToBlack();

update(num d) {
	num delta = d - lastDelta;

	if(gameState == GameState.LOADING) {
		bool loaded = true;

		textures.forEach((id, texture) {
			if(!texture.loaded) loaded = false;
		});

		loaded = loaded && atlas.texturesLoaded();

		if(loaded) gameState = GameState.MENU;
	}

	if (gameState == GameState.MAP && !fadeToBlack.fading && army != null && (army.lost || army.won)) gameState = GameState.OVER;

	if (gameState == GameState.MENU && utils.withinBox(mouse.x, mouse.y, playButton) && mouse.down) {
		gameState = GameState.MAP;
	}

	if (gameState == GameState.MENU && utils.withinBox(mouse.x, mouse.y, howtoButton) && mouse.down) {
		gameState = GameState.HOW;
	}

	if(gameState == GameState.MAP && !fadeToBlack.fading && !interviewTransition.fading) {
		Rectangle buttons = new Rectangle(textureLocations["recruitButton"].left,
				textureLocations["nextButton"].top,
				textureLocations["nextButton"].width + textureLocations["recruitButton"].width + 40,
				textureLocations["nextButton"].height);

		if(fadeToBlack.finished && fadeToBlack.direction == 0) {
			army.progress();
			gameState = GameState.NEWS;
		} else if (fadeToBlack.finished && fadeToBlack.direction == 1) {
			army.events.clear();
		} else if(!utils.withinBox(mouse.x, mouse.y, buttons)) {
			if(keys.containsKey(keycodes["w"]) || mouse.y < 100) {
				atlas.offset += new Point(0, -0.3 * delta);
			}

			if(keys.containsKey(keycodes["s"]) || mouse.y > HEIGHT - 100) {
				atlas.offset += new Point(0, 0.3 * delta);
			}

			if(keys.containsKey(keycodes["a"]) || mouse.x < 100) {
				atlas.offset += new Point(-0.3 * delta, 0);
			}

			if(keys.containsKey(keycodes["d"]) || mouse.x > WIDTH - 100) {
				atlas.offset += new Point(0.3 * delta, 0);
			}
		}
	}

	if(army != null && army.food <= 0) {
		army.food = 0;
		army.lost = true;
	}

	fadeToBlack.update(delta);
	interviewTransition.update(delta);

	lastDelta = d;
}

draw() {
	context.clearRect(0, 0, WIDTH, HEIGHT);

	if (gameState == GameState.MENU) {
		context.drawImage(textures["menuBackground"].image, 0, 0);
		context.drawImageToRect(textures["menu"].image, new Rectangle(HEIGHT / 2 - textures["menu"].image.height / 2, 150, textures["menu"].image.width, textures["menu"].image.height));

		if (utils.withinBox(mouse.x, mouse.y, playButton)) {
			utils.drawBox(context, playButton, "rgba(255,255,255,0.7)");
		} else {
			utils.drawBox(context, playButton, "rgba(255,255,255,0.6)");
		}

		if (utils.withinBox(mouse.x, mouse.y, howtoButton)) {
			utils.drawBox(context, howtoButton, "rgba(255,255,255,0.7)");
		} else {
			utils.drawBox(context, howtoButton, "rgba(255,255,255,0.6)");
		}

		utils.drawText(context, "PLAY", playButton.left + playButton.width / 2, playButton.top + 15, "Propaganda", 25, "#000", true);
		utils.drawText(context, "How to play", howtoButton.left + howtoButton.width / 2, howtoButton.top + 15, "Propaganda", 25, "#000", true);

	} else if (gameState == GameState.MAP) {
		atlas.render(context, army, textures["spritesheet"], textureRects);

		String countryCode = atlas.getCountry(mouse.x, mouse.y);
		String country = Atlas.countryNames[countryCode];

		if (country != null &&
				(atlas.slider == null || atlas.slider.rect == null || !utils.withinBox(mouse.x, mouse.y, atlas.slider.rect)) &&
				(atlas.defenseSlider == null || atlas.defenseSlider.rect == null || !utils.withinBox(mouse.x, mouse.y, atlas.defenseSlider.rect))) {
			if(army != null && atlas.currentCountries.contains(countryCode)) {
				utils.drawTextWithShadow(context, "[${Atlas.strength[countryCode].floor()}] $country", mouse.x, mouse.y - 40, "Propaganda", 25, true);
			} else {
				utils.drawTextWithShadow(context, country, mouse.x, mouse.y - 40, "Propaganda", 25, true);
			}
		}

		if(atlas.baseCountry != null) {
			context.globalAlpha = 1;

			if (!utils.withinBox(mouse.x, mouse.y, textureLocations["nextButton"])) {
				context.globalAlpha = 0.95;
			} else if (mouse.down && !fadeToBlack.fading) {
				context.globalAlpha = 1;
				if (!fadeToBlack.fading) fadeToBlack.fade();
			}

			context.drawImageToRect(textures["spritesheet"].image, textureLocations["nextButton"], sourceRect: textureRects["nextButton"]);

			context.globalAlpha = 1;
			if (army.weekRecruits > 0) {
				if (!utils.withinBox(mouse.x, mouse.y, textureLocations["recruitButton"])) {
					context.globalAlpha = 0.95;
				} else if (mouse.down && !fadeToBlack.fading) {
					if (!interviewTransition.fading) interviewTransition.fade();
				}

				if (interviewTransition.finished) {
					gameState = GameState.INTERVIEW;
				}

				context.drawImageToRect(textures["spritesheet"].image, textureLocations["recruitButton"], sourceRect: textureRects["recruitButton"]);

				context.globalAlpha = 1;
			}
		}

		interviewTransition.render(context, WIDTH, HEIGHT);
		fadeToBlack.render(context, WIDTH, HEIGHT);
	}

	if (gameState == GameState.INTERVIEW) {
		if(interviewTransition.finished && interviewTransition.direction == 0) {
			if(army.weekRecruits <= 0) {
				List<String> strengthDumpCandidates = new List<String>();

				Atlas.strength.forEach((country, strength) {
					if(atlas.currentCountries.contains(country)) {
						strengthDumpCandidates.add(country);
					}
				});

				String randomCountry = strengthDumpCandidates[new Random().nextInt(strengthDumpCandidates.length)];

				Atlas.strength[randomCountry] += army.recruitStrength;
				army.strength += army.recruitStrength;
				army.recruitStrength = 0;

				gameState = GameState.MAP;
			}

			interviewTransition.fade();
			applicant = new Applicant(army);
			applicant.randomize();
		}

		context.drawImage(textures["applicantBackground"].image, 0, 0);

		applicant.render(context, textures["spritesheet"], textureRects, WIDTH, HEIGHT);

		interviewTransition.render(context, WIDTH, HEIGHT);

		context.drawImage(textures["applicantOverlay"].image, 0, 0);

		utils.drawText(context, "Food: ${army.food}", 50, 5, "Propaganda", 25, "#e5e5e5", false);
		utils.drawText(context, "Gold: ${army.gold}", 65 + utils.measure(context, "Food: ${army.food}", "Propaganda", 25), 5, "Propaganda", 25, "#e5e5e5", false);

//		context.globalAlpha = 0.9;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["acceptButton"])) {
//			context.globalAlpha = 0.95;

			if (mouse.down && !interviewTransition.fading && army.gold >= applicant.requiredGold) {
//				context.globalAlpha = 1;
				army.men.add(applicant);
				army.recruitStrength += applicant.strength;
				army.weekRecruits--;
				army.gold -= applicant.requiredGold;
				interviewTransition.fade();
			}
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["acceptButton"], sourceRect: textureRects["acceptButton"]);

//		context.globalAlpha = 0.9;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["denyButton"])) {
//			context.globalAlpha = 0.95;
			if (mouse.down && !interviewTransition.fading) {
//				context.globalAlpha = 1;
				army.weekRecruits--;
				interviewTransition.fade();
			}
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["denyButton"], sourceRect: textureRects["denyButton"]);

		context.globalAlpha = 1;
	} else if (gameState == GameState.NEWS) {
		utils.drawRect(context, 0, 0, WIDTH, HEIGHT, "#000");

		utils.drawTextWithShadow(context, "Week ${army.week}", 20, 20, "Propaganda", 37, false);

		num i = 0;
		army.events.forEach((event) {
			utils.drawTextWithShadow(context, event, 20, 65 + (i * 35), "Propaganda", 35, false);
			i++;
		});

		utils.drawTextWithShadow(context, "Continue", WIDTH - 150, HEIGHT - 50, "Propaganda", 35, false);

		if (mouse.down && utils.within(mouse.x, mouse.y, WIDTH - 150, HEIGHT - 50, 120, 20)) {
			gameState = GameState.MAP;
			fadeToBlack.fade();
		}
	} else if (gameState == GameState.OVER) {
		if (army.won) {
			utils.drawText(context, "You won!", WIDTH / 2, HEIGHT / 2, "Propaganda", 75, "#000", true, horiz: true);
			utils.drawText(context, "(click anywhere to restart)", WIDTH / 2, HEIGHT / 2 + 40, "Propaganda", 17, "#000", true, horiz: true);
		} else if (army.lost) {
			utils.drawText(context, army.food > 0 ? "You lost" : "You ran out of food", WIDTH / 2, HEIGHT / 2, "Propaganda", 75, "#000", true, horiz: true);
			utils.drawText(context, "(click anywhere to restart)", WIDTH / 2, HEIGHT / 2 + 40, "Propaganda", 17, "#000", true, horiz: true);
		}
	} else if (gameState == GameState.LOADING) {
		utils.drawText(context, "Loading textures", WIDTH / 2, HEIGHT / 2, "Propaganda", 75, "#000", true, horiz: true);
		utils.drawText(context, "Please wait...", WIDTH / 2, HEIGHT / 2 + 40, "Propaganda", 17, "#000", true, horiz: true);
	} else if (gameState == GameState.HOW) {
		String how = "You are Twobuttons, a manic looking to control the world.\n" +
					 "Or at least Europe.\n\n" +
					 "You'll first choose a country to start in. Each turn,\n" +
				     "you'll have the option to attack another country and/or\n" +
					 "support one of your own. You can also recruit new units\n" +
					 "who will add to your total strength. Each unit costs\n" +
					 "gold to hire and will require food each turn. If you\n" +
					 "run out of food, your empire will die! You can interview\n" +
					 "up to five units per turn.\n\n" +
					 "Your chances of winning a battle are based on your enemy's\n" +
					 "strength and a little bit of luck. Your enemies are\n" +
					 "highlighted in blue and will sometimes attack one of your\n" +
					 "countries if it's bordering them. Neutral countries bordering\n" +
					 "you will turn against you eventually.\n\n" +
					 "To attack a country, click on one of your countries and drag\n" +
					 "to the country you want to attack. The same goes for supporting,\n" +
					 "except you drag from one of your countries to another.";

		List<String> lines = how.split('\n');

		num i = 0;
		lines.forEach((line) {
			utils.drawText(context, "$line", 20, 20 + (i * 30), "Propaganda", 30, "#000", false);
			i++;
		});

		if (utils.withinBox(mouse.x, mouse.y, backButton)) {
			utils.drawBox(context, backButton, "rgba(0,0,0,0.7)");
			if (mouse.down) gameState = GameState.MENU;
		} else {
			utils.drawBox(context, backButton, "rgba(0,0,0,0.6)");
		}

		utils.drawText(context, "Back to menu", backButton.left + backButton.width / 2, backButton.top + 15, "Propaganda", 25, "#fff", true);
	}
}

tick(num delta) {
	update(delta);
	draw();

	window.animationFrame.then(tick);
}

init() {
	canvas.width = WIDTH;
	canvas.height = HEIGHT;

	window.onKeyDown.listen((e) {
		keys[e.keyCode] = true;
	});

	window.onKeyUp.listen((e) {
		if(keys.containsKey(keycodes["r"])) {
//			applicant.randomize();
		}

		keys.remove(e.keyCode);
	});

	canvas.onMouseMove.listen((e) {
		mouse.x = e.offset.x;
		mouse.y = e.offset.y;
	});

	canvas.onMouseDown.listen((e) {
		mouse.down = true;
		mouse.button = e.which;

		num downX = e.offset.x;
		num downY = e.offset.y;

		StreamSubscription mouseMoveStream = null;

		String countryCode = atlas.getCountry(downX, downY);

		bool mouseMoved = false;

		if (gameState == GameState.MAP && atlas.baseCountry == null && countryCode != null && e.which == 1) {
			atlas.baseCountry = countryCode;
			atlas.addCountry(countryCode);
			army = new Army(countryCode, atlas);
		} else if (gameState == GameState.MAP && atlas.baseCountry != null && e.which == 1) {
			if (atlas.slider != null && atlas.slider.rect != null && utils.withinBox(downX, downY, atlas.slider.rect)) {
				num dx = downX;

				StreamSubscription sliderStream = canvas.onMouseMove.listen((e) {
					num moveX = e.offset.x;
					num difference = moveX - dx;

					atlas.slider.handleX += difference;
					atlas.slider.setValue();

					dx = moveX;
				});

				window.onMouseUp.listen((e) {
					sliderStream.cancel();
				});
			}

			if (atlas.currentCountries.contains(countryCode) && atlas.target == null) {
				atlas.from = new Point(downX + atlas.offset.x, downY + atlas.offset.y);
				atlas.fromCountry = countryCode;
			}

			if (atlas.targetCountry == countryCode || atlas.currentCountries.contains(countryCode)) { // the player has taken over the country they clicked on
				if (atlas.target != null) {
					num targetX = atlas.target.x - atlas.offset.x;
					num targetY = atlas.target.y - atlas.offset.y;

					if (!utils.within(downX, downY, targetX - 10, targetY - 10, 20, 20)) return;

					atlas.target = null;
					atlas.targetCountry = null;
				}

				if (!atlas.currentCountries.contains(countryCode)) atlas.tempTarget = new Point(downX, downY);

				mouseMoveStream = canvas.onMouseMove.listen((e) {
					mouseMoved = true;

					num moveX = e.offset.x;
					num moveY = e.offset.y;

					atlas.tempTarget = new Point(moveX, moveY);
				});

				window.onMouseUp.listen((e) {
					mouseMoveStream.cancel();

					if (atlas.tempTarget != null && atlas.currentCountries.contains(atlas.fromCountry)) {
						atlas.tempTarget = null;

						String target = atlas.getCountry(e.offset.x, e.offset.y);

						if (target != null && Atlas.borders[atlas.fromCountry].contains(target) && atlas.availableCountries.contains(target)) {
							atlas.target = new Point(e.offset.x + atlas.offset.x, e.offset.y + atlas.offset.y);
							atlas.targetCountry = target;
						} else {
							atlas.from = null;
							atlas.fromCountry = null;
						}
					}
				});
			}
		} else if (gameState == GameState.MAP && atlas.baseCountry != null && e.which == 3) {
			e.preventDefault();

			if (atlas.currentCountries.contains(countryCode)) {
				atlas.defenseFrom = new Point(downX + atlas.offset.x, downY + atlas.offset.y);
				atlas.defenseFromCountry = countryCode;

				StreamSubscription defenseStream = canvas.onMouseMove.listen((e) {
					num moveX = e.offset.x;
					num moveY = e.offset.y;

					atlas.defenseTempTarget = new Point(moveX, moveY);
				});

				window.onMouseUp.listen((e) {
					defenseStream.cancel();

					if(e.which != 3) return;

					String target = atlas.getCountry(e.offset.x, e.offset.y);

					if (target != null &&
							atlas.currentCountries.contains(atlas.defenseFromCountry) &&
							atlas.currentCountries.contains(target) &&
							atlas.defenseFromCountry != target &&
							Atlas.borders[atlas.defenseFromCountry].contains(target)) {

						atlas.defenseTarget = new Point(e.offset.x + atlas.offset.x, e.offset.y + atlas.offset.y);
						atlas.defenseTargetCountry = target;
					} else if (target != null &&
							atlas.currentCountries.contains(atlas.defenseFromCountry) &&
							atlas.currentCountries.contains(target) &&
							atlas.defenseFromCountry == target) {

						atlas.defenseTarget = null;
						atlas.defenseTargetCountry = null;
						atlas.defenseFrom = null;
						atlas.defenseFromCountry = null;
					} else {
						atlas.defenseTarget = null;
						atlas.defenseTargetCountry = null;
						atlas.defenseFrom = null;
						atlas.defenseFromCountry = null;
					}

					atlas.defenseTempTarget = null;
				});
			}
		} else if (gameState == GameState.MAP && atlas.baseCountry != null && e.which == 1 && (atlas.target == null && atlas.tempTarget == null)) {
			if (atlas.defenseSlider != null && atlas.defenseSlider.rect != null && utils.withinBox(downX, downY, atlas.defenseSlider.rect)) {
				num dx = downX;

				StreamSubscription defenseSliderStream = canvas.onMouseMove.listen((e) {
					num moveX = e.offset.x;
					num difference = moveX - dx;

					atlas.defenseSlider.handleX += difference;
					atlas.defenseSlider.setValue();

					dx = moveX;
				});

				window.onMouseUp.listen((e) {
					defenseSliderStream.cancel();
				});
			}
		}
	});

	canvas.onContextMenu.listen((e) => e.preventDefault());

	window.onMouseUp.listen((e) {
		if(gameState == GameState.OVER) {
			window.location.href = window.location.href;
		}

		mouse.down = false;
	});

	textures["spritesheet"] = new Texture("images/spritesheet.png");
	textures["applicantOverlay"] = new Texture("images/applicant_overlay.png");
	textures["applicantBackground"] = new Texture("images/applicant_background.png");
	textures["menu"] = new Texture("images/menu.png");
	textures["menuBackground"] = new Texture("images/menu_background.png");

	textureRects["acceptButton"] = new Rectangle(0, 0, 247, 221);
	textureLocations["acceptButton"] = new Rectangle(452, HEIGHT - 158, 168, 148);

	textureRects["denyButton"] = new Rectangle(247, 0, 249, 223);
	textureLocations["denyButton"] = new Rectangle(646 + 10, HEIGHT - 158, 168, 148);

	textureRects["arrowsCenter"] = new Rectangle(497, 0, 56, 52);
	textureRects["arrows"] = new Rectangle(497, 52, 148, 138);
	textureRects["smallArrows"] = new Rectangle(452, 448, 100, 93);

	textureRects["slider"] = new Rectangle(226, 574, 175, 15);
	textureRects["sliderHandle"] = new Rectangle(401, 574, 18, 36);

	textureRects["nextButton"] = new Rectangle(553, 448, 85, 84);
	textureLocations["nextButton"] =  new Rectangle(WIDTH - textureRects["nextButton"].width - 20, HEIGHT - 60 - (textureRects["nextButton"].height / 2), textureRects["nextButton"].width, textureRects["nextButton"].height);

	textureRects["recruitButton"] = new Rectangle(452, 542, 115, 72);
	textureLocations["recruitButton"] =  new Rectangle(WIDTH - textureRects["recruitButton"].width - textureRects["nextButton"].width - 40, HEIGHT - 60 - (textureRects["recruitButton"].height / 2), textureRects["recruitButton"].width, textureRects["recruitButton"].height);

	textureRects["statsBoard"] = new Rectangle(0, 3425, 225, 351);

	applicant.randomize();

	window.animationFrame.then(tick);
}

main() {
	init();
}
