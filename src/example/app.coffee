class Perso
    constructor: (data, textures, initAnim) ->
        @anims = {}
        for animName,anim of data
            @anims[animName] =
                "name": animName
                "leadTo": anim.leadTo
                "imgs": []
                "nb": anim.imgs.length
            for img in anim.imgs
                toturl = anim.dir + img.file
                if not textures[toturl]
                    textures[toturl] = PIXI.Texture.fromImage(toturl)
                img.texture = textures[toturl]
                @anims[animName].imgs.push(img)
        @currentAnim = @anims[initAnim]
        @nextAnim = null
        @currentImg = 0
        @sprite = new PIXI.Sprite(@currentAnim.imgs[@currentImg].texture)
        @lastTime = 0 # seconds

    loadAnimation: (anim, force=false) ->
        @nextAnim = anim
        if force
            @currentImg = @currentAnim.nb - 1
            @nextImg()

    move: (dx, dy, absolute=false) ->
        if absolute
            @sprite.position.x = dx
            @sprite.position.y = dy
        else
            @sprite.position.x += dx
            @sprite.position.y += dy

    nextImg: ->
        @currentImg++
        if @currentImg >= @currentAnim.nb
            @currentImg = 0
            if @nextAnim != null
                @currentAnim = @anims[@nextAnim]
                @nextAnim = null
            else if @currentAnim.leadTo != @currentAnim.name
                @currentAnim = @anims[@currentAnim.leadTo]
        @sprite.setTexture(@currentAnim.imgs[@currentImg].texture)

    updateAnimation: (dt) ->
        @lastTime += dt
        if @lastTime >= @currentAnim.imgs[@currentImg].duration
            @nextImg()
            @lastTime -= @currentAnim.imgs[@currentImg].duration

textures = {}

$ ->
    range = (begin, end) ->
      (begin++ while begin < end)

    interactive = true
    stage = new PIXI.Stage(0x000000, interactive)
    renderer = PIXI.autoDetectRenderer(400, 250)
    mainc = document.getElementById("canvashere")
    mainc.appendChild(renderer.view)
    console.log(renderer)
    renderer.view.style.border_radius = 20

    texture = PIXI.Texture.fromImage("bunny.png")
    canala = PIXI.Texture.fromImage("canal1new.png")
    canalb = PIXI.Texture.fromImage("canal2.png")
    files = ("metalman/running/#{n}.png" for n in range(1, 10))
    imgs_metalman = (PIXI.Texture.fromImage(i) for i in files)
    files = ("themagnet/running/#{n}.png" for n in range(1, 10))
    imgs_themagnet = (PIXI.Texture.fromImage(i) for i in files)

    bunny = new PIXI.Sprite(texture)
    canala1 = new PIXI.Sprite(canala)
    canala2 = new PIXI.Sprite(canala)
    canalb1 = new PIXI.Sprite(canalb)
    canalb2 = new PIXI.Sprite(canalb)
    currentRun = 0
    currentRun2 = 5
    runner = new PIXI.Sprite(imgs_metalman[currentRun])
    runner2 = new PIXI.Sprite(imgs_themagnet[currentRun])
    runner.setInteractive(true);
    runner2.setInteractive(true);

    bunny.anchor.x = 0.5
    bunny.anchor.y = 0.5

    bunny.position.x = 320
    bunny.position.y = 80

    runner.position.x = 150
    runner2.position.x = 10
    onTheFloor = 172
    runner.position.y = onTheFloor
    runner2.position.y = onTheFloor

    canala2.position.x = renderer.width
    canalb2.position.x = renderer.width

    stage.addChild(canalb1)
    stage.addChild(canalb2)
    stage.addChild(canala1)
    stage.addChild(canala2)

    stage.addChild(bunny)
    stage.addChild(runner)
    stage.addChild(runner2)

    p = null

    $.getJSON "anims/themagnet.json", (data) =>
        p = new Perso(data, textures, "running")
        stage.addChild(p.sprite)

    scroll = 3
    isJumping = false
    isJumping2 = false
    runrunInterval = 100

    window.onkeypress = (e) ->
        jump(e, "key", "both")
        p.loadAnimation("mortelec")

    runner.tap = (e) ->
        jump(e, "tap", "metalman")

    runner.click = (e) ->
        jump(e, "click", "metalman")

    runner2.tap = (e) ->
        jump(e, "tap", "themagnet")

    runner2.click = (e) ->
        jump(e, "click", "themagnet")

    jump = (e, type, who) ->
        if who == "both" or who == "metalman"
            if runner.position.y == onTheFloor
                scroll += 1
                isJumping = 0
                runrunInterval -= 2
        if who == "both" or who == "themagnet"
            if runner2.position.y == onTheFloor
                scroll += 1
                isJumping2 = 0
                runrunInterval -= 2

    runrun = ->
        currentRun++
        currentRun2++
        if currentRun == 9
            currentRun = 0
        if currentRun2 == 9
            currentRun2 = 0
        runner.setTexture(imgs_metalman[currentRun])
        runner2.setTexture(imgs_themagnet[currentRun2])
        setTimeout(runrun, runrunInterval)

    getTime = -> new Date().valueOf() / 1000

    lastTime = getTime() - 0.016

    getElapsedTime = ->
        now = getTime()
        dt = now - lastTime
        lastTime = now
        return dt

    animate = ->
        dt = getElapsedTime()
        if p?
            console.log p
            p.updateAnimation(dt)

        requestAnimFrame(animate)

        bunny.rotation += scroll / 100

        canala1.position.x -= scroll
        canala2.position.x -= scroll
        if canala2.position.x <= 0
            canala1.position.x = canala2.position.x
            canala2.position.x = renderer.width + canala2.position.x

        canalb1.position.x -= scroll / 2
        canalb2.position.x -= scroll / 2
        if canalb2.position.x <= 0
            canalb1.position.x = canalb2.position.x
            canalb2.position.x = renderer.width + canalb2.position.x

        if isJumping != false
            isJumping += 0.017
            if isJumping < 0.4
                runner.position.y -= 8 - 20*isJumping
            else if isJumping < 0.8
                runner.position.y += 20*(isJumping - 0.4)
            else
                isJumping = false
                runner.position.y = onTheFloor

        if isJumping2 != false
            isJumping2 += 0.017
            if isJumping2 < 0.4
                runner2.position.y -= 8 - 20*isJumping2
            else if isJumping2 < 0.8
                runner2.position.y += 20*(isJumping2 - 0.4)
            else
                isJumping2 = false
                runner2.position.y = onTheFloor
        
        renderer.render(stage)

    requestAnimFrame(animate)
    setTimeout(runrun, runrunInterval)
       