class Animation
    constructor: (data, textures, initAnim, interactive=false) ->
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
        @pos =
            "x": 0
            "y": 0
        if interactive
            @sprite.setInteractive(true)

    loadAnimation: (anim, force=false) ->
        @nextAnim = anim
        if force
            @currentImg = @currentAnim.nb - 1
            @nextImg()

    move: (dx, dy, absolute=false) ->
        if absolute
            @pos.x = dx
            @pos.y = dy
        else
            @pos.x += dx
            @pos.y += dy

    addTo: (stage) ->
        stage.addChild(@sprite)

    removeFrom: (stage) ->
        stage.removeChild(@sprite)

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
        # update sprite position :
        @sprite.position.x = window.widthFactor * @pos.x
        @sprite.position.y = window.heightFactor * @pos.y

$ ->
    textures = {}
    interactive = true
    winDimensions = window.winDimensions =
        "width": 400
        "height": 250
    widthFactor = window.widthFactor = 1
    heightFactor = window.heightFactor = 1
    stage = new PIXI.Stage(0x000000, interactive)
    renderer = PIXI.autoDetectRenderer(winDimensions.width, winDimensions.height)
    mainc = document.getElementById("canvashere")
    mainc.appendChild(renderer.view)

    canala = PIXI.Texture.fromImage("img/canala.png")
    canalb = PIXI.Texture.fromImage("img/canalb.png")
    bunny = new PIXI.Sprite(PIXI.Texture.fromImage("img/bunny.png"))
    canala1 = new PIXI.Sprite(canala)
    canala2 = new PIXI.Sprite(canala)
    canalb1 = new PIXI.Sprite(canalb)
    canalb2 = new PIXI.Sprite(canalb)

    bunny.anchor.x = 0.5
    bunny.anchor.y = 0.5
    bunny.position.x = 320
    bunny.position.y = 80

    canala2.position.x = renderer.width
    canalb2.position.x = renderer.width

    stage.addChild(canalb1)
    stage.addChild(canalb2)
    stage.addChild(canala1)
    stage.addChild(canala2)

    stage.addChild(bunny)

    scroll = 3
    onTheFloor = 172
    themagnet = null
    metalman = null

    $.getJSON "anims/themagnet.json", (data) =>
        themagnet = new Animation(data, textures, "running", true)
        themagnet.pos =
            "x": 50
            "y": onTheFloor
        themagnet.sprite.click = themagnet.sprite.tap = (e) ->
            themagnet.loadAnimation("mortelec", true)
        themagnet.addTo(stage)
        $.getJSON "anims/metalman.json", (data) =>
            metalman = new Animation(data, textures, "running", true)
            metalman.pos =
                "x": 150
                "y": onTheFloor
            metalman.isJumping = false
            metalman.sprite.click = metalman.sprite.tap = (e) ->
                metalman.loadAnimation("startjumping", true)
                metalman.isJumping = 0
            metalman.addTo(stage)
            animate()

    getTime = -> new Date().valueOf() / 1000

    lastTime = getTime() - 0.016

    getElapsedTime = ->
        now = getTime()
        dt = now - lastTime
        lastTime = now
        return dt

    animate = ->
        requestAnimFrame(animate)

        dt = getElapsedTime()
        themagnet.updateAnimation(dt)
        metalman.updateAnimation(dt)

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

        if metalman.isJumping != false
            metalman.isJumping += 0.017
            if metalman.isJumping < 0.4
                metalman.pos.y -= 8 - 20*metalman.isJumping
            else if metalman.isJumping < 0.8
                metalman.pos.y += 20*(metalman.isJumping - 0.4)
                metalman.loadAnimation("landing", true)
            else
                metalman.isJumping = false
                metalman.pos.y = onTheFloor
                metalman.loadAnimation("running", true)

        renderer.render(stage)
