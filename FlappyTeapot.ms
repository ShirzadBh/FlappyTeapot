tool FlappyTeapot
(
	local ftm
	local bestScore

	local num = 0
	local frame = 0
	
	local bird
	local velocityY
	
	local gameSpeed 
	
	local obs 
	local obsH 
	
	local scoreText 
	local lastScoreText

	fn setUpTheScene = 
	(
		delete objects 
		max create mode

		backgroundColor =  color 10 107 253 
		renderWidth=720
		renderHeight=1080
		
		em = Edit_Mesh()
		scoreText = Text text:"0" size:10 wirecolor:white pos:[18,28,8] wirecolor:red
		addModifier scoreText em 
		
		lastScoreText = Text text:"Best Score: 0" size:3 wirecolor:white pos:[18,24,8] wirecolor:white
		
		addModifier lastScoreText em 
				
		if (getAppData rootNode 1000) == undefined then 
		(
			setAppData rootNode 1000 "0"
			bestScore = 0
		)
		else 
		(
			bestScore = (getAppData rootNode 1000) as integer 
			lastScoreText.text = "Best Score: " + bestScore as string 
		)
			
		cam = Physical pos:[18.7354,-2,70] film_width_mm:35
		select cam 
		max vpt camera
		
		redrawViews()
		clearSelection()	
			
		obs = Array()
		obsH = Array()
		
		bird = Teapot segs:2 rotation:(quat -0.707107 0 0 0.707107) height:0.5 radius:4 pos:[0, 13, -1] wirecolor:yellow
		velocityY = 0

	)
	
	fn createObs = 
	(
		offset = random -30 30
		gap = 20
					
		c = Cylinder sides:10 dir:[0, 1, 0] radius:6 height:45 pos:[10+(50), (-45 - gap) + (offset/2), 0] wirecolor:green 
		c2 = Cylinder sides:10 dir:[0, 1, 0] radius:6 height:45 pos:[10+(50), (gap) + (offset/2), 0] wirecolor:green 

		cc = Cylinder sides:10 dir:[0, 1, 0] radius:6.5 height:4 pos:[10+(50), (-4- gap) + (offset/2)+0.1, 0] wirecolor:green 
		cc2 = Cylinder sides:10 dir:[0, 1, 0] radius:6.5 height:4 pos:[10+(50), (gap) + (offset/2)-0.1, 0] wirecolor:green 

		append obs c 
		append obs c2

		append obsH cc
		append obsH cc2 
	)
	
	fn updateBird = 
	(		
		velocityY += -0.08
		bird.pos.y += velocityY
		
		bird.rotation.z_rotation = velocityY*15
	)
	
	fn updateObs = 
	(
		obs.pos.x -= gameSpeed / 2
		obsH.pos.x -= gameSpeed / 2

		try(
		for o in obs do (
			if (intersects bird o) then 
			(
				stopTool FlappyTeapot
				startTool FlappyTeapot
			)
		)
		)catch()
		
	)
	
	fn stopTheGame =
	(
		delete objects 
		free obs 
		obs = Array()
		birds = undefined 
		
		stopTool FlappyTeapot
		ftm.Stop()
		ftm.Dispose()
		dotnet.removeAllEventHandlers ftm
		
		startTool FlappyTeapot
	)

	
	fn onTick s e =
	(
		frame += 1
		gameSpeed = frame / 4000.0 + 1
		
		-- create obs 
		if (mod frame 100 == 0) then (
			scoreText.text = ((frame / 100)-1) as string
			
			if ((frame / 100)-1) > bestScore then (
				lastScoreText.text = "Best Score: " + (((frame / 100)-1) as string)
				setAppData rootNode 1000 (((frame / 100)-1) as string)
			)
			createObs()
		)
		
		
		if (mod frame 20 == 0) then (
			if bird.pos.y < -100 or bird.pos.y > 100  then (stopTheGame())
			
			a = (for o in obs where o.pos.x > -60 collect o)
			b = (for o in obs where o.pos.x < -60 collect o)
			delete b 
			obs = a 
			
			aa = (for o in obsH where o.pos.x > -60 collect o)
			bb = (for o in obsH where o.pos.x < -60 collect o)
			delete bb 
			obsH = aa 
		)
		
		updateBird()
		updateObs()
	
	)
	

	on start do (
		gameSpeed = 1
		ftm = dotnetobject "System.Windows.Forms.Timer"
		setUpTheScene()
		ftm.Interval = 15
		dotnet.addEventHandler ftm "Tick" onTick
		ftm.Start()
	)

	on mousePoint clickno do
	(
		if clickno > 1 then 
		(
			num += 1
			velocityY = 1.5
		)
	)	

	on mouseAbort clickno do 
	(
		ftm.Stop()
		ftm.Dispose()
		dotnet.removeAllEventHandlers ftm
	)

)
startTool FlappyTeapot
   
   
   
   
