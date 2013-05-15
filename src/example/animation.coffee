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
