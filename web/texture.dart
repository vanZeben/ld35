part of alpha;

class Texture {
  static List<Texture> _all = new List<Texture>(); // Cache of all our textures
  static void loadAll() {
    _all.forEach((texture) => texture.load()); // Load each texture
  }
  static void areAllLoaded() {
    bool loaded = true;
    for(Texture tex in _all) {
      if (!tex.loaded) {
        tex.load();
        loaded = false;
        break;
      }
    }
    if (loaded) {
      Game.running = true;
    }
  }
  
  String url; // URL/filepath of our texture
  GL.Texture texture; // Texture constant 
  Texture(this.url) {
    _all.add(this); // Add texture to our cache for loading
  }
  bool loaded = false;
  load() {
    ImageElement img = new ImageElement(); // Create empty image
    texture = gl.createTexture(); // Instantiate texture
    img.onLoad.listen((e) { 
      gl.bindTexture(GL.TEXTURE_2D, texture); // Bind the texture 
      gl.texImage2DImage(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, img); // Bind the image to our texture in RGBA formating
      gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST); // Use nearest neighbour for scaling down
      gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST); // Use nearest neighbour for scaling up
      loaded = true;
      areAllLoaded();
    });
    img.src = url;
  }
}