// Copyright (c) 2015, Alden Ozburn. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';

num lastFrame = 0.0; // Time count for animation deltas
final int fps = 60; // Frames per second
final double interval = 1000 / fps; // Animation interval

List<Animatable> toRemove = [];
List<Animatable> animatables = [];

/// Main entry point
void main() {
  //querySelector('#output').text = 'Memorandum';
  //print(Tween.sinusoidal(0, 60, fps, 1.0));

  DivElement container = querySelector('#container');
  reshape(container, 1.5);
  window.onResize.listen((Event event) {
    reshape(container, 1.5);
  });

  int smallPnt = 5;
  int largePnt = 55;
  int initDim = 40;
  int finalDim = 90;

  DivElement tl = querySelector('#topleft');
  DivElement tr = querySelector('#topright');
  DivElement bl = querySelector('#bottomleft');
  DivElement br = querySelector('#bottomright');

  Window win1 = new Window(tl, tl, smallPnt, smallPnt, smallPnt, smallPnt,
      initDim, initDim, finalDim, finalDim, '%');
  Window win2 = new Window(tr, tr, largePnt, smallPnt, smallPnt, smallPnt,
      initDim, initDim, finalDim, finalDim, '%');
  Window win3 = new Window(bl, bl, smallPnt, largePnt, smallPnt, smallPnt,
      initDim, initDim, finalDim, finalDim, '%');
  Window win4 = new Window(br, br, largePnt, largePnt, smallPnt, smallPnt,
      initDim, initDim, finalDim, finalDim, '%');

  DivElement menuElem = querySelector('#menu');
  DivElement menuButton = querySelector('#menuButton');
  print(menuButton.style.width);
  int menuWidth = 81;
  int menuHeight = 50;
  Window menu =
      new Window(menuElem, menuButton, -100, 50, 0, 50, menuWidth, menuHeight, menuWidth, menuHeight, 'px');

  window.animationFrame.then(loop);
}

void reshape(DivElement container, double aspect) {
  /*if(window.innerWidth < window.innerHeight) {
    int width = (window.innerHeight * aspect).floor();
    container.style.width = '${width}px';
    container.style.height = '${window.innerHeight}px';
  }
  else {
    int height = (window.innerWidth / aspect).floor();
    container.style.width = '${window.innerWidth}px';
    container.style.height = '${height}px';
  }*/
  int dim = min(window.innerWidth, window.innerHeight);
  container.style.width = '${dim}px';
  container.style.height = '${dim}px';
}

/// Recursive loop for animation
void loop(num delta) {
  if (delta - lastFrame > interval) {
    animatables.forEach((animatable) {
      animatable.animate();
      if (animatable.finished()) toRemove.add(animatable);
    });
    toRemove.forEach((animatable) {
      animatables.remove(animatable);
      animatable.inMotion = false;
      if (!animatable.closed) animatable.win.style.zIndex = '0';
    });
    toRemove.clear();
  }
  window.animationFrame.then(loop);
}

/// Animatable interface for animation elements
class Animatable {
  DivElement win;

  int initX;
  int initY;
  int initWidth;
  int initHeight;

  int finalX;
  int finalY;
  int finalWidth;
  int finalHeight;

  bool inMotion;
  bool closed;

  List<double> animations;

  void animate() {}

  bool finished() {
    return true;
  }
}

/// Manage window animation concurrency
class WindowManager {
  List<Window> windows = [];

  WindowManager(List<Window> windows) {
    this.windows = windows;
  }
}

/// Main div for windows
class Window extends Animatable {
  DivElement win; // The main window element

  List<double> animationsX = [];
  List<double> animationsY = [];
  List<double> animationsWidth = [];
  List<double> animationsHeight = [];
  bool closed;
  String valueType;

  double dur = 0.6;

  Window(DivElement div, Element button, initX, initY, finalX, finalY,
      initWidth, initHeight, finalWidth, finalHeight, String valueType) {
    this.win = div;

    this.initX = initX;
    this.initY = initY;
    this.initWidth = initWidth;
    this.initHeight = initHeight;

    this.finalX = finalX;
    this.finalY = finalY;
    this.finalWidth = finalWidth;
    this.finalHeight = finalHeight;

    win.style.left = '${initX}${valueType}';
    win.style.top = '${initY}${valueType}';
    win.style.width = '${initWidth}${valueType}';
    win.style.height = '${initHeight}${valueType}';

    this.closed = false;
    this.inMotion = false;

    this.valueType = valueType;

    win.style.position = 'absolute';
    button.onClick.listen((MouseEvent event) {
      if (!inMotion) toggle();
    });
  }

  void toggle() {
    closed = !closed;
    inMotion = true;
    if (closed) {
      win.style.zIndex = '1';
      animationsX = Tween.sinusoidal(initX, finalX, fps, dur);
      animationsY = Tween.sinusoidal(initY, finalY, fps, dur);
      animationsWidth = Tween.sinusoidal(initWidth, finalWidth, fps, dur);
      animationsHeight = Tween.sinusoidal(initHeight, finalHeight, fps, dur);
    } else {
      animationsX = Tween.sinusoidal(finalX, initX, fps, dur);
      animationsY = Tween.sinusoidal(finalY, initY, fps, dur);
      animationsWidth = Tween.sinusoidal(finalWidth, initWidth, fps, dur);
      animationsHeight = Tween.sinusoidal(finalHeight, initHeight, fps, dur);
    }
    animatables.add(this);
  }

  void animate() {
    if (animationsX.isNotEmpty) {
      win.style.left = '${animationsX.removeAt(0)}${valueType}';
    }
    if (animationsY.isNotEmpty) {
      win.style.top = '${animationsY.removeAt(0)}${valueType}';
    }
    if (animationsWidth.isNotEmpty) {
      win.style.width = '${animationsWidth.removeAt(0)}${valueType}';
    }
    if (animationsHeight.isNotEmpty) {
      win.style.height = '${animationsHeight.removeAt(0)}${valueType}';
    }
  }

  bool finished() {
    return animationsX.isEmpty &&
        animationsY.isEmpty &&
        animationsWidth.isEmpty &&
        animationsHeight.isEmpty;
  }
}

class Tween {
  static List<double> linear(int initVal, int finalVal, int fps, double dur) {
    List<double> animation = [];
    int delta = finalVal - initVal;
    int frames = (fps * dur).round();
    double interval = delta.toDouble() / frames.toDouble();
    for (int i = 1; i < frames; i++) {
      animation.add(initVal + i * interval);
    }
    animation.add(finalVal.toDouble());
    return animation;
  }

  static List<double> sinusoidal(
      int initVal, int finalVal, int fps, double dur) {
    List<double> animation = [];
    int delta = finalVal - initVal;
    int frames = (fps * dur).round();
    double interval = delta.toDouble() / frames.toDouble();
    for (int i = 1; i < frames; i++) {
      double sindex = (i / frames) * (PI / 2);
      animation.add(initVal + delta * pow(sin(sindex), 4));
    }
    animation.add(finalVal.toDouble());
    return animation;
  }
}
