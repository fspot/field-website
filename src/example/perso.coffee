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
$.getJSON "anims/themagnet.json", (data) =>
	p = new Perso(data, textures, "standing")