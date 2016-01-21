// Copyright (c) 2015, Alden Ozburn. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

num lastFrame = 0.0; // Time count for animation deltas
final int fps = 60; // Frames per second
final double interval = 1000 / fps; // Animation interval

List<Animatable> toRemove = [];
List<Animatable> animatables = [];

/// Main entry point
void main() {
  querySelector('#output').text = 'Memorandum';
  //print(linearTween(0, 60, fps, 1.0));

  Window win1 = new Window(querySelector('#test1'), 10, 10, 10, 10, 30, 30, 80, 80);
  Window win2 = new Window(querySelector('#test2'), 60, 10, 10, 10, 30, 30, 80, 80);
  Window win3 = new Window(querySelector('#test3'), 10, 60, 10, 10, 30, 30, 80, 80);
  Window win4 = new Window(querySelector('#test4'), 60, 60, 10, 10, 30, 30, 80, 80);

  window.animationFrame.then(loop);
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
      if(!animatable.closed)
        animatable.win.style.zIndex = '0';
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

  Window(DivElement div, initX, initY, finalX, finalY, initWidth, initHeight,
      finalWidth, finalHeight) {
    this.win = div;

    this.initX = initX;
    this.initY = initY;
    this.initWidth = initWidth;
    this.initHeight = initHeight;

    this.finalX = finalX;
    this.finalY = finalY;
    this.finalWidth = finalWidth;
    this.finalHeight = finalHeight;

    win.style.left = '${initX}%';
    win.style.top = '${initY}%';
    win.style.width = '${initWidth}%';
    win.style.height = '${initHeight}%';

    this.closed = false;
    this.inMotion = false;

    win.onClick.listen((MouseEvent event) {
      if (!inMotion) toggle();
    });
  }

  void toggle() {
    closed = !closed;
    inMotion = true;
    if (closed) {
      win.style.zIndex = '1';
      animationsX = linearTween(initX, finalX, fps, 1.0);
      animationsY = linearTween(initY, finalY, fps, 1.0);
      animationsWidth = linearTween(initWidth, finalWidth, fps, 1.0);
      animationsHeight = linearTween(initHeight, finalHeight, fps, 1.0);
    } else {

      animationsX = linearTween(finalX, initX, fps, 1.0);
      animationsY = linearTween(finalY, initY, fps, 1.0);
      animationsWidth = linearTween(finalWidth, initWidth, fps, 1.0);
      animationsHeight = linearTween(finalHeight, initHeight, fps, 1.0);
    }
    animatables.add(this);
  }

  void animate() {
    if (animationsX.isNotEmpty) {
      win.style.left = '${animationsX.removeAt(0)}%';
    }
    if (animationsY.isNotEmpty) {
      win.style.top = '${animationsY.removeAt(0)}%';
    }
    if (animationsWidth.isNotEmpty) {
      win.style.width = '${animationsWidth.removeAt(0)}%';
    }
    if (animationsHeight.isNotEmpty) {
      win.style.height = '${animationsHeight.removeAt(0)}%';
    }
  }

  bool finished() {
    return animationsX.isEmpty &&
        animationsY.isEmpty &&
        animationsWidth.isEmpty &&
        animationsHeight.isEmpty;
  }
}

List<double> linearTween(int initVal, int finalVal, int fps, double dur) {
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

List<double> sinTween(int initVal, int finalVal, int fps, double dur) {
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
