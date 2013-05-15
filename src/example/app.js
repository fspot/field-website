// Generated by CoffeeScript 1.4.0
(function() {
  var Perso, textures;

  Perso = (function() {

    function Perso(data, textures, initAnim) {
      var anim, animName, img, toturl, _i, _len, _ref;
      this.anims = {};
      for (animName in data) {
        anim = data[animName];
        this.anims[animName] = {
          "name": animName,
          "leadTo": anim.leadTo,
          "imgs": [],
          "nb": anim.imgs.length
        };
        _ref = anim.imgs;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          img = _ref[_i];
          toturl = anim.dir + img.file;
          if (!textures[toturl]) {
            textures[toturl] = PIXI.Texture.fromImage(toturl);
          }
          img.texture = textures[toturl];
          this.anims[animName].imgs.push(img);
        }
      }
      this.currentAnim = this.anims[initAnim];
      this.nextAnim = null;
      this.currentImg = 0;
      this.sprite = new PIXI.Sprite(this.currentAnim.imgs[this.currentImg].texture);
      this.lastTime = 0;
    }

    Perso.prototype.loadAnimation = function(anim, force) {
      if (force == null) {
        force = false;
      }
      this.nextAnim = anim;
      if (force) {
        this.currentImg = this.currentAnim.nb - 1;
        return this.nextImg();
      }
    };

    Perso.prototype.move = function(dx, dy, absolute) {
      if (absolute == null) {
        absolute = false;
      }
      if (absolute) {
        this.sprite.position.x = dx;
        return this.sprite.position.y = dy;
      } else {
        this.sprite.position.x += dx;
        return this.sprite.position.y += dy;
      }
    };

    Perso.prototype.nextImg = function() {
      this.currentImg++;
      if (this.currentImg >= this.currentAnim.nb) {
        this.currentImg = 0;
        if (this.nextAnim !== null) {
          this.currentAnim = this.anims[this.nextAnim];
          this.nextAnim = null;
        } else if (this.currentAnim.leadTo !== this.currentAnim.name) {
          this.currentAnim = this.anims[this.currentAnim.leadTo];
        }
      }
      return this.sprite.setTexture(this.currentAnim.imgs[this.currentImg].texture);
    };

    Perso.prototype.updateAnimation = function(dt) {
      this.lastTime += dt;
      if (this.lastTime >= this.currentAnim.imgs[this.currentImg].duration) {
        this.nextImg();
        return this.lastTime -= this.currentAnim.imgs[this.currentImg].duration;
      }
    };

    return Perso;

  })();

  textures = {};

  $(function() {
    var animate, bunny, canala, canala1, canala2, canalb, canalb1, canalb2, currentRun, currentRun2, files, getElapsedTime, getTime, i, imgs_metalman, imgs_themagnet, interactive, isJumping, isJumping2, jump, lastTime, mainc, n, onTheFloor, p, range, renderer, runner, runner2, runrun, runrunInterval, scroll, stage, texture,
      _this = this;
    range = function(begin, end) {
      var _results;
      _results = [];
      while (begin < end) {
        _results.push(begin++);
      }
      return _results;
    };
    interactive = true;
    stage = new PIXI.Stage(0x000000, interactive);
    renderer = PIXI.autoDetectRenderer(400, 250);
    mainc = document.getElementById("canvashere");
    mainc.appendChild(renderer.view);
    console.log(renderer);
    renderer.view.style.border_radius = 20;
    texture = PIXI.Texture.fromImage("bunny.png");
    canala = PIXI.Texture.fromImage("canal1new.png");
    canalb = PIXI.Texture.fromImage("canal2.png");
    files = (function() {
      var _i, _len, _ref, _results;
      _ref = range(1, 10);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push("metalman/running/" + n + ".png");
      }
      return _results;
    })();
    imgs_metalman = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        i = files[_i];
        _results.push(PIXI.Texture.fromImage(i));
      }
      return _results;
    })();
    files = (function() {
      var _i, _len, _ref, _results;
      _ref = range(1, 10);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        _results.push("themagnet/running/" + n + ".png");
      }
      return _results;
    })();
    imgs_themagnet = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        i = files[_i];
        _results.push(PIXI.Texture.fromImage(i));
      }
      return _results;
    })();
    bunny = new PIXI.Sprite(texture);
    canala1 = new PIXI.Sprite(canala);
    canala2 = new PIXI.Sprite(canala);
    canalb1 = new PIXI.Sprite(canalb);
    canalb2 = new PIXI.Sprite(canalb);
    currentRun = 0;
    currentRun2 = 5;
    runner = new PIXI.Sprite(imgs_metalman[currentRun]);
    runner2 = new PIXI.Sprite(imgs_themagnet[currentRun]);
    runner.setInteractive(true);
    runner2.setInteractive(true);
    bunny.anchor.x = 0.5;
    bunny.anchor.y = 0.5;
    bunny.position.x = 320;
    bunny.position.y = 80;
    runner.position.x = 150;
    runner2.position.x = 10;
    onTheFloor = 172;
    runner.position.y = onTheFloor;
    runner2.position.y = onTheFloor;
    canala2.position.x = renderer.width;
    canalb2.position.x = renderer.width;
    stage.addChild(canalb1);
    stage.addChild(canalb2);
    stage.addChild(canala1);
    stage.addChild(canala2);
    stage.addChild(bunny);
    stage.addChild(runner);
    stage.addChild(runner2);
    p = null;
    $.getJSON("anims/themagnet.json", function(data) {
      p = new Perso(data, textures, "running");
      return stage.addChild(p.sprite);
    });
    scroll = 3;
    isJumping = false;
    isJumping2 = false;
    runrunInterval = 100;
    window.onkeypress = function(e) {
      jump(e, "key", "both");
      return p.loadAnimation("mortelec");
    };
    runner.tap = function(e) {
      return jump(e, "tap", "metalman");
    };
    runner.click = function(e) {
      return jump(e, "click", "metalman");
    };
    runner2.tap = function(e) {
      return jump(e, "tap", "themagnet");
    };
    runner2.click = function(e) {
      return jump(e, "click", "themagnet");
    };
    jump = function(e, type, who) {
      if (who === "both" || who === "metalman") {
        if (runner.position.y === onTheFloor) {
          scroll += 1;
          isJumping = 0;
          runrunInterval -= 2;
        }
      }
      if (who === "both" || who === "themagnet") {
        if (runner2.position.y === onTheFloor) {
          scroll += 1;
          isJumping2 = 0;
          return runrunInterval -= 2;
        }
      }
    };
    runrun = function() {
      currentRun++;
      currentRun2++;
      if (currentRun === 9) {
        currentRun = 0;
      }
      if (currentRun2 === 9) {
        currentRun2 = 0;
      }
      runner.setTexture(imgs_metalman[currentRun]);
      runner2.setTexture(imgs_themagnet[currentRun2]);
      return setTimeout(runrun, runrunInterval);
    };
    getTime = function() {
      return new Date().valueOf() / 1000;
    };
    lastTime = getTime() - 0.016;
    getElapsedTime = function() {
      var dt, now;
      now = getTime();
      dt = now - lastTime;
      lastTime = now;
      return dt;
    };
    animate = function() {
      var dt;
      dt = getElapsedTime();
      if (p != null) {
        console.log(p);
        p.updateAnimation(dt);
      }
      requestAnimFrame(animate);
      bunny.rotation += scroll / 100;
      canala1.position.x -= scroll;
      canala2.position.x -= scroll;
      if (canala2.position.x <= 0) {
        canala1.position.x = canala2.position.x;
        canala2.position.x = renderer.width + canala2.position.x;
      }
      canalb1.position.x -= scroll / 2;
      canalb2.position.x -= scroll / 2;
      if (canalb2.position.x <= 0) {
        canalb1.position.x = canalb2.position.x;
        canalb2.position.x = renderer.width + canalb2.position.x;
      }
      if (isJumping !== false) {
        isJumping += 0.017;
        if (isJumping < 0.4) {
          runner.position.y -= 8 - 20 * isJumping;
        } else if (isJumping < 0.8) {
          runner.position.y += 20 * (isJumping - 0.4);
        } else {
          isJumping = false;
          runner.position.y = onTheFloor;
        }
      }
      if (isJumping2 !== false) {
        isJumping2 += 0.017;
        if (isJumping2 < 0.4) {
          runner2.position.y -= 8 - 20 * isJumping2;
        } else if (isJumping2 < 0.8) {
          runner2.position.y += 20 * (isJumping2 - 0.4);
        } else {
          isJumping2 = false;
          runner2.position.y = onTheFloor;
        }
      }
      return renderer.render(stage);
    };
    requestAnimFrame(animate);
    return setTimeout(runrun, runrunInterval);
  });

}).call(this);