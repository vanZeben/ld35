part of alpha;

class Level {
  int tileW;
  int tileH;
  String spritePath;
  Sprites spriteSheet;
  Level() {

  }

  void render(Matrix4 mvMatrix) {
    spriteSheet.render(mvMatrix);
  }
}
