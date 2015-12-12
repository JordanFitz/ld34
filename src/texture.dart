import "dart:html";

class Texture {
	ImageElement image;
	bool loaded;

	// Creates an image element with the given source.
	Texture(String source) {
		loaded = false;

		image = new ImageElement(src: source);

		image.onLoad.listen((e) {
			loaded = true;
		});
	}
}