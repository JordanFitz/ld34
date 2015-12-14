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
	MENU, MAP, INTERVIEW, NEWS
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

Rectangle playButton = new Rectangle(WIDTH / 2 - (150), 400, 300, 50);

Applicant applicant = new Applicant();

Atlas atlas = new Atlas(WIDTH, HEIGHT);
Army army;

FadeToBlack fadeToBlack = new FadeToBlack();
FadeToBlack interviewTransition = new FadeToBlack();

update(num d) {
	num delta = d - lastDelta;

	if (backgroundDirection) {
		if (backgroundOpacity < 0.3) {
			backgroundOpacity += 0.06 / delta;
		} else {
			backgroundDirection = false;
		}
	} else {
		if (backgroundOpacity > 0) {
			backgroundOpacity -= 0.06 / delta;
		} else {
			backgroundDirection = true;
		}
	}

	if (gameState == GameState.MENU && utils.withinBox(mouse.x, mouse.y, playButton) && mouse.down) {
		gameState = GameState.MAP;
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

	fadeToBlack.update(delta);
	interviewTransition.update(delta);

	lastDelta = d;
}

draw() {
	context.clearRect(0, 0, WIDTH, HEIGHT);

	if (gameState == GameState.MENU) {
		context.fillStyle = "rgba(0, 0, 0, $backgroundOpacity)";
		context.fillRect(0, 0, WIDTH, HEIGHT);

		utils.drawText(context, "Twobuttons", WIDTH / 2, 250, "Propaganda", 60, "#000", true);
		utils.drawText(context, "Controls", WIDTH / 2, 300, "Propaganda", 60, "#000", true);

		if (utils.withinBox(mouse.x, mouse.y, playButton)) {
			utils.drawBox(context, playButton, "rgba(0,0 0,0.7)");
		} else {
			utils.drawBox(context, playButton, "rgba(0,0,0,0.6)");
		}

		utils.drawText(context, "PLAY", WIDTH / 2, 418, "Propaganda", 25, "#fff", true);
	} else if (gameState == GameState.MAP) {
		atlas.render(context, army, textures["spritesheet"], textureRects);

		String countryCode = atlas.getCountry(mouse.x, mouse.y);
		String country = Atlas.countryNames[countryCode];

		if (country != null &&
				(atlas.slider == null || atlas.slider.rect == null || !utils.withinBox(mouse.x, mouse.y, atlas.slider.rect)) &&
				(atlas.defenseSlider == null || atlas.defenseSlider.rect == null || !utils.withinBox(mouse.x, mouse.y, atlas.defenseSlider.rect))) {
			if(army != null && atlas.currentCountries.contains(countryCode)) {
				utils.drawTextWithShadow(context, "[${Atlas.strength[countryCode]}] $country", mouse.x, mouse.y - 40, "Propaganda", 25, true);
			} else {
				utils.drawTextWithShadow(context, country, mouse.x, mouse.y - 40, "Propaganda", 25, true);
			}
		}

		if(atlas.baseCountry != null) {
			context.globalAlpha = 1;

			if (!utils.withinBox(mouse.x, mouse.y, textureLocations["nextButton"])) {
				context.globalAlpha = 0.95;
			} else if (mouse.down) {
				context.globalAlpha = 1;
				if (!fadeToBlack.fading) fadeToBlack.fade();
			}

			context.drawImageToRect(textures["spritesheet"].image, textureLocations["nextButton"], sourceRect: textureRects["nextButton"]);

			context.globalAlpha = 1;
			if (army.weekRecruits > 0) {
				if (!utils.withinBox(mouse.x, mouse.y, textureLocations["recruitButton"])) {
					context.globalAlpha = 0.95;
				} else if (mouse.down) {
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
			applicant = new Applicant();
			applicant.randomize();
		}

		context.drawImage(textures["applicantBackground"].image, 0, 0);

		applicant.render(context, textures["spritesheet"], textureRects, WIDTH, HEIGHT);

		/*utils.drawRect(context, 0, 0, WIDTH, 50, "#C4C4C4");
		utils.drawRect(context, 0, 0, 75, HEIGHT, "#C4C4C4");
		utils.drawRect(context, WIDTH - 75, 0, 75, HEIGHT, "#C4C4C4");
		utils.drawRect(context, 0, HEIGHT - 200, WIDTH, 200, "#C4C4C4");*/

		interviewTransition.render(context, WIDTH, HEIGHT);

		context.drawImage(textures["applicantOverlay"].image, 0, 0);

		context.globalAlpha = 0.93;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["acceptButton"])) {
			context.globalAlpha = 0.9;

			if (mouse.down && !interviewTransition.fading) {
				context.globalAlpha = 1;
				army.men.add(applicant);
				army.recruitStrength += applicant.strength;
				army.weekRecruits--;
				interviewTransition.fade();
			}
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["acceptButton"], sourceRect: textureRects["acceptButton"]);

		context.globalAlpha = 0.93;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["denyButton"])) {
			context.globalAlpha = 0.9;
			if (mouse.down && !interviewTransition.fading) {
				context.globalAlpha = 1;
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
		mouse.down = false;
	});

	textures["spritesheet"] = new Texture("images/spritesheet.png");
	textures["applicantOverlay"] = new Texture("images/applicant_overlay.png");
	textures["applicantBackground"] = new Texture("images/applicant_background.png");

	textureRects["acceptButton"] = new Rectangle(0, 0, 249, 230);
	textureLocations["acceptButton"] = new Rectangle(450, HEIGHT - 140, 124.5, 115);

	textureRects["denyButton"] = new Rectangle(249, 0, 249, 230);
	textureLocations["denyButton"] = new Rectangle(WIDTH - 450 - 124.5, HEIGHT - 140, 124.5, 115);

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
