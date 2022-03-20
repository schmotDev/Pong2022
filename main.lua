-- JEU: Pong 2022 
love.graphics.setDefaultFilter("nearest")

raquette = {}
raquette.image = love.graphics.newImage("images/pong.png")
raquette.frames = {}
raquette.frames[1] = love.graphics.newQuad(65,0,46,8,raquette.image:getWidth(),raquette.image:getHeight())
raquette.frame = 1
raquette.type = 0 -- raquette normale
raquette.largeur = 10
raquette.hauteur = 80

limiteDROITE = love.graphics.getWidth()
limiteGAUCHE= 0
limiteHAUT = 50
limiteBAS = love.graphics.getHeight()
screenWidth = limiteDROITE - limiteGAUCHE
screenHeight = limiteBAS - limiteHAUT

player1Posx = 0
player1Posy = screenHeight/2 - raquette.hauteur/2 + limiteHAUT
scorePlayer1 = 0

player2Posx = screenWidth
player2Posy = screenHeight/2 - raquette.hauteur/2 + limiteHAUT
scorePlayer2 = 0

pause = true
point = false

balle = {}
balle.LARGEUR = 14
balle.HAUTEUR = 14
balle.x = 0
balle.y = 0
balle.vitesseX = 2
balle.vitesseY = 2
balle.image = love.graphics.newImage("images/balls.png")
balle.frames = {}
balle.frames[1] = love.graphics.newQuad(68,0, 14, 14, balle.image:getWidth(),balle.image:getHeight())

trail = {}
impact = {}
explosion = {}

machin = 0

function BalleCentre()
  balle.x = (limiteDROITE-limiteGAUCHE) / 2 - balle.LARGEUR / 2
  balle.y = (limiteBAS-limiteHAUT) / 2 - balle.HAUTEUR / 2 + limiteHAUT
  
  balle.vitesseX = 2
  balle.vitesseY = 2
end

function ExploseBalle(dt)
  for n=#explosion, 1,-1 do
    local exp = explosion[n]
    exp.vie = exp.vie - dt
    exp.x = exp.x + exp.vx 
    exp.y = exp.y + exp.vy
    if exp.vie <= 0 then
      table.remove(explosion, n)
    end
  end
  
  myExplose = {}
  myExplose.x = impact.x
  myExplose.y = impact.y
  myExplose.vie = 1
  myExplose.vx = math.random(-3, 3)
  myExplose.vy = math.random(-3, 3)
  myExplose.colorR = math.random()
  myExplose.colorV = math.random()
  myExplose.colorB = math.random()
  table.insert(explosion, myExplose)
  
end

function DeplaceBalle(dt)
  
  for n=#trail,1,-1 do
    local t = trail[n]
    t.vie = t.vie - dt
    if t.vie <= 0 then
      table.remove(trail, n)
    end
  end
  myTrail = {}
  myTrail.x = balle.x
  myTrail.y = balle.y
  myTrail.vie = 0.5
  table.insert(trail, myTrail)
  
  balle.x = balle.x + balle.vitesseX
  
  Collision()
  
  if (balle.x + balle.LARGEUR) > limiteDROITE then
    Point("PLAYER 1")
    sndPerdu:play()
  end
  if (balle.x) <= limiteGAUCHE then
    Point("PLAYER 2")
    sndPerdu:play()
  end
  
  balle.y = balle.y + balle.vitesseY
  
  if (balle.y + balle.HAUTEUR) > limiteBAS then
    balle.vitesseY  = balle.vitesseY * -1
    sndMur:play()
  end
  if (balle.y) <= limiteHAUT then
    balle.vitesseY  = balle.vitesseY * -1
    sndMur:play()
  end
end


function Point(joueur)
  if joueur == "PLAYER 1" then
    scorePlayer1 = scorePlayer1 + 1
  elseif joueur == "PLAYER 2" then
    scorePlayer2 = scorePlayer2 + 1
  end
  
  for n=#trail,1,-1 do
    local t = trail[n]
    table.remove(trail, n)
  end
  
  affichage = joueur.." WON THIS ROUND!!!!! PRESS SPACE TO CONTINUE"
  impact.x = balle.x
  impact.y = balle.y
  BalleCentre()
  pause = true
  point = true
  
  musicIntro:play()
  --love.audio.play(musicIntro)
  
  if scorePlayer1 == 10 or scorePlayer2 == 10 then
    affichage = joueur.." IS THE WINNER !!!! PRESS SPACE TO RESTART"
    scorePlayer1 = 0
    scorePlayer2 = 0
  end
  
end

function Collision()
  
  if balle.x <= (player1Posx + raquette.largeur) then
    if (balle.y <= (player1Posy + raquette.hauteur)) and (balle.y >= (player1Posy - balle.HAUTEUR)) then
      balle.x = player1Posx + raquette.largeur
      balle.vitesseX  = balle.vitesseX * -1
      sndRaq:play()
    end
  end
  
  if (balle.x + balle.LARGEUR) >= (player2Posx - raquette.largeur) then
    if (balle.y <= (player2Posy + raquette.hauteur)) and (balle.y >= (player2Posy - balle.HAUTEUR)) then
      balle.x = player2Posx - raquette.largeur - balle.LARGEUR
      balle.vitesseX  = balle.vitesseX * -1
      sndRaq:play()
    end
  end
end

function DeplaceJoueur()
  
  if love.keyboard.isDown("a") and ((player1Posy+raquette.hauteur) <= limiteBAS) then
    player1Posy = player1Posy + 2
  end
  
  if love.keyboard.isDown("q") and player1Posy > limiteHAUT then
    player1Posy = player1Posy - 2
  end
  
  if love.keyboard.isDown("down") and ((player2Posy+raquette.hauteur) <= limiteBAS) then
    player2Posy = player2Posy + 2
  end
  if love.keyboard.isDown("up") and player2Posy > limiteHAUT then
    player2Posy = player2Posy - 2
  end
  
  if love.keyboard.isDown("space") and player2Posy > limiteHAUT then
    pause = false
    point = false
    
    love.audio.stop(musicIntro)
  end
  
end

function screenStart()
  affichage = "PUSH SPACE TO START THE GAME"
  pause = true
  
  musicIntro:play()
  --love.audio.play(musicIntro)
  
end

function love.load()
  love.window.setTitle("PONG 2022")
  
  sndMur = love.audio.newSource("sounds/mur2.wav", "static")
  sndPerdu = love.audio.newSource("sounds/perdu.wav", "static")
  sndRaq = love.audio.newSource("sounds/sonRaq.wav", "static")
  
  musicIntro = love.audio.newSource("music/intro.wav", "stream")
  musicIntro:setLooping(true)
  

  BalleCentre()
  screenStart()
end

function love.update(dt)
  
  DeplaceJoueur()
  
  if (pause == false) then
    DeplaceBalle(dt)
  elseif (point == true) then
    ExploseBalle(dt)
  end
  
  
  --if point then Point() end
end

function love.draw()
  
  love.graphics.rectangle("line", 0,0, limiteDROITE,limiteHAUT-1)
  love.graphics.print("PLAYER ONE", 10,10)
  love.graphics.print("SCORE: "..scorePlayer1, 10,25)
  love.graphics.print("PLAYER TWO", (limiteDROITE-100),10)
  love.graphics.print("SCORE: "..scorePlayer2, (limiteDROITE-100),25)

  --love.graphics.rectangle("fill", player1Posx+10,player1Posy, raquette.largeur,raquette.hauteur)
  --love.graphics.rectangle("fill", player2Posx-raquette.largeur,player2Posy, raquette.largeur,raquette.hauteur)
  love.graphics.draw(raquette.image, raquette.frames[1], player1Posx,player1Posy+80, math.rad(-90), 80/46, 10/8)
  love.graphics.draw(raquette.image, raquette.frames[1], player2Posx-raquette.largeur,player2Posy+80, math.rad(-90), 80/46, 10/8)

  for n=1, #trail do
    local t = trail[n]
    love.graphics.setColor(1,1,1, t.vie/2)
    --love.graphics.circle("fill", t.x,t.y, balle.LARGEUR/2)
    love.graphics.draw(balle.image, balle.frames[1], t.x, t.y, 0, 1,1, 0, 0)
  end  
  love.graphics.setColor(1,1,1, 1)
  --love.graphics.rectangle("fill", balle.x,balle.y, balle.LARGEUR,balle.HAUTEUR)
  love.graphics.draw(balle.image, balle.frames[1], balle.x, balle.y, 0, 1,1, 0, 0)
  
  if pause then
    local font = love.graphics.getFont()
    local largeur_afficharge = font:getWidth(affichage)
    love.graphics.print(affichage, (screenWidth-largeur_afficharge)/2, screenHeight/2)
    
    if point then
      for n=1, #explosion do
        local exp = explosion[n]
        love.graphics.setColor(exp.colorR,exp.colorV,exp.colorB, exp.vie/2)
        love.graphics.circle("line", exp.x + balle.LARGEUR/2,exp.y + balle.LARGEUR/2, balle.LARGEUR/3)
        love.graphics.setColor(1,1,1, 1)
      end  
    end
  end
  
 

end

