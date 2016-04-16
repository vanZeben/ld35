library alpha;

import 'dart:html';
import 'dart:web_gl' as GL;

import 'dart:async';

import 'dart:math'; // basic math functions
import 'dart:typed_data'; // include vars such as our Float32List and Int16List
import 'package:vector_math/vector_math.dart'; // allows us to perform vector math
import 'package:game_loop/game_loop_html.dart';
import 'dart:convert';

part 'shader.dart';
part 'texture.dart';
part 'sprites.dart';
part 'level.dart';
GL.RenderingContext gl;

const int GAME_WIDTH = 420;
const int GAME_HEIGHT = 240;
const double GAME_SCALE = 2.0;

Matrix4 pMatrix;
class Game {
  static bool running = false;
  CanvasElement canvas;
  GameLoopHtml gameLoop;
  Game() {
    canvas = querySelector("#game");
    gameLoop = new GameLoopHtml(canvas);
    gl = canvas.getContext('webgl'); // Initialize the GL context
    if (gl == null) gl = canvas.getContext('experimental-webgl'); // Some browsers require experimental versions
    if (gl == null) querySelector('#webgl_missing').setAttribute('style', 'display: all'); // Error out of we still cant find WebGL
    else start();
  }

  void resize() {
    int w = window.innerWidth;
    int h = window.innerHeight;
    double xScale = w/GAME_WIDTH;
    double yScale = h/GAME_HEIGHT;

    if (xScale < yScale) {
      int newHeight = (GAME_HEIGHT*xScale).floor();
      canvas.setAttribute("style", "width: ${w}px; height: ${GAME_HEIGHT * xScale}px; left:0px;top:${(h-newHeight)/2}px");
    } else {
      int newWidth = (GAME_WIDTH*yScale).floor();
      canvas.setAttribute("style", "width: ${GAME_WIDTH * yScale}px; height: ${h}px; left:${(w-newWidth)/2}px;top:0px");
    }
  }

  Sprites test;
  Sprite base;
  Level level;
  void start() {
    pMatrix = makeOrthographicMatrix(0.0, GAME_WIDTH + 0.0, GAME_HEIGHT + 0.0, 0.0, -10.0, 10.0);
    pMatrix.scale(GAME_SCALE, GAME_SCALE, 1.0);

    window.onResize.listen((event) => resize());

    level = new Level();

    new Texture("tex/bg.png");
    Texture.loadAll();

  //  test = new Sprites(testShader, tex.texture);
  //  base = new Sprite(1.0 * 16.0, 0.0, 16.0, 16.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, true);
  //  test.addSprite(base);

    gameLoop.addTimer(render, 0.001, periodic: true);
    gameLoop.start();
  }


  void render(GameLoopTimer timer) {
    double time = timer.gameLoop.gameTime * 1000;
    if (!running) {
      if (time >= 10 * 1000) {
        print("Game could not be initialized, took too long to load resources");
        gameLoop.stop();
        return;
      }
      print("Game has not yet been initialized, please buckle your pants");
      return;
    }

    gl.viewport(0, 0, canvas.width, canvas.height); // Inform WebGL of our rendering viewport
    gl.clearColor(0.1, 0.1, 0.1, 1.0); // Set clear color to a "close to black", fully opaque
    gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT); // Clear the GL context to that color

    level.render(new Matrix4.identity());
  }
}

Future<String> loadString(String url) {
  Completer<String> completer = new Completer();
  HttpRequest req = new HttpRequest();
  req.open("get", url);
  req.onLoadEnd.first.then((e) {
    if (req.status ~/ 100 == 2) {
      completer.complete(req.response as String);
    } else {
      completer.completeError("Can't load url ${url}. Response type ${req.status}");
    }
  });
  req.send("");
  return completer.future;
}

void main() {
  new Game();
}
