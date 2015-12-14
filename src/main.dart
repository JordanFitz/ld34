import "dart:html";
import "dart:async";

import "utils.dart" as utils;
import "mouse.dart" as mouse;
import "texture.dart";
import "applicant.dart";
import "atlas.dart";
import "army.dart";

CanvasElement canvas = querySelector("canvas#canvas");
CanvasRenderingContext2D context = canvas.context2D;

const num WIDTH = 1280;
const num HEIGHT = 720;

num backgroundOpacity = 0.0;
bool backgroundDirection = false;

enum GameState {
	MENU, MAP, INTERVIEW
}

GameState gameState = GameState.MAP;

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

	if(gameState == GameState.MAP) {
		if(keys.containsKey(keycodes["w"]) || mouse.y < 200) {
			atlas.offset += new Point(0, -0.3 * delta);
		}

		if(keys.containsKey(keycodes["s"]) || mouse.y > HEIGHT - 200) {
			atlas.offset += new Point(0, 0.3 * delta);
		}

		if(keys.containsKey(keycodes["a"]) || mouse.x < 200) {
			atlas.offset += new Point(-0.3 * delta, 0);
		}

		if(keys.containsKey(keycodes["d"]) || mouse.x > WIDTH - 200) {
			atlas.offset += new Point(0.3 * delta, 0);
		}
	}

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

		if (country != null && (atlas.slider == null || atlas.slider.rect == null || !utils.withinBox(mouse.x, mouse.y, atlas.slider.rect)) /*&& atlas.baseCountry == null*/) {
			if(army != null && atlas.currentCountries.contains(countryCode)) {
				utils.drawTextWithShadow(context, "[${Atlas.strength[countryCode]}] $country", mouse.x, mouse.y - 40, "Propaganda", 25, true);
			} else {
				utils.drawTextWithShadow(context, country, mouse.x, mouse.y - 40, "Propaganda", 25, true);
			}
		}
	} else if (gameState == GameState.INTERVIEW) {
		utils.drawRect(context, 0, 0, WIDTH, HEIGHT, "#4D4D4D");

		applicant.render(context, textures["spritesheet"], WIDTH, HEIGHT);

		utils.drawRect(context, 0, 0, WIDTH, 50, "#C4C4C4");
		utils.drawRect(context, 0, 0, 75, HEIGHT, "#C4C4C4");
		utils.drawRect(context, WIDTH - 75, 0, 75, HEIGHT, "#C4C4C4");
		utils.drawRect(context, 0, HEIGHT - 200, WIDTH, 200, "#C4C4C4");

		context.drawImage(textures["applicantOverlay"].image, 0, 0);

		context.globalAlpha = 0.93;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["acceptButton"])) {
			context.globalAlpha = 0.9;
			if (mouse.down) context.globalAlpha = 1;
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["acceptButton"], sourceRect: textureRects["acceptButton"]);

		context.globalAlpha = 0.93;

		if (utils.withinBox(mouse.x, mouse.y, textureLocations["denyButton"])) {
			context.globalAlpha = 0.9;
			if (mouse.down) context.globalAlpha = 1;
		}

		context.drawImageToRect(textures["spritesheet"].image, textureLocations["denyButton"], sourceRect: textureRects["denyButton"]);

		context.globalAlpha = 1;
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
			applicant.randomize();

			if (gameState == GameState.MAP) {
				army.progress();
			}
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
		} else {
			if (gameState == GameState.MAP && atlas.baseCountry != null && e.which == 1) {
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

						if (atlas.tempTarget != null && (atlas.availableCountries.contains(countryCode) || atlas.currentCountries.contains(countryCode))) {
							atlas.tempTarget = null;

							String target = atlas.getCountry(e.offset.x, e.offset.y);

							if (mouseMoved == true && target != null && !atlas.currentCountries.contains(target) && atlas.availableCountries.contains(target)) {
								atlas.target = new Point(e.offset.x + atlas.offset.x, e.offset.y + atlas.offset.y);
								atlas.targetCountry = target;
							}
						}
					});
				}
			}
		}
	});

	window.onMouseUp.listen((e) {
		mouse.down = false;
	});

	textures["spritesheet"] = new Texture("images/spritesheet.png");
	textures["applicantOverlay"] = new Texture("images/applicant_overlay.png");

	textureRects["acceptButton"] = new Rectangle(0, 0, 249, 230);
	textureLocations["acceptButton"] = new Rectangle(425, HEIGHT - 150, 124.5, 115);

	textureRects["denyButton"] = new Rectangle(249, 0, 249, 230);
	textureLocations["denyButton"] = new Rectangle(WIDTH - 425 - 124.5, HEIGHT - 150, 124.5, 115);

	textureRects["arrowsCenter"] = new Rectangle(497, 0, 56, 52);
	textureRects["arrows"] = new Rectangle(497, 52, 148, 138);

	textureRects["slider"] = new Rectangle(226, 574, 175, 15);
	textureRects["sliderHandle"] = new Rectangle(401, 574, 18, 36);

	applicant.randomize();

	window.animationFrame.then(tick);
}

main() {
	init();
}
