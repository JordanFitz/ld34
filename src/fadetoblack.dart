import "dart:html";

class FadeToBlack {
	num opacity = 0.0;
	num direction = 1;
	bool fading = false;
	bool finished = false;

	render(CanvasRenderingContext2D context, num width, num height) {
		String oldStyle = context.fillStyle;

		context.fillStyle = "rgba(0,0,0,$opacity)";
		context.fillRect(0, 0, width, height);

		context.fillStyle = oldStyle;
	}

	fade() {
		fading = true;
	}

	update(delta) {
		if (finished) finished = false;

		if (fading && direction == 1) {
			opacity += 0.002 * delta;

			if(opacity >= 1) {
				fading = false;
				direction = 0;
				opacity = 1;
				finished = true;
			}
		} else if (fading && direction == 0) {
			opacity -= 0.002 * delta;

			if(opacity <= 0) {
				fading = false;
				direction = 1;
				opacity = 0;
				finished = true;
			}
		}
	}
}