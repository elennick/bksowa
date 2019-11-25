pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
  //screen state
  screen = 1  // game title
  //10 = gameplay
  //99 = game over

  score = 0
 
  //levels
  l = {}
  l[1] = {}
  l[1].y = 0
  l[1].pstarty = 64
  l[1].psprites = {}
  l[1].psprites[1] = 64
  l[1].psprites[2] = 66
  l[1].psprites[3] = 68
  l[1].asprite = 102
  l[1].esprite = 96
  l[2] = {}
  l[2].y = 128
  l[2].pstarty = 192
  l[2].psprites = {}
  l[2].psprites[1] = 70
  l[2].psprites[2] = 72
  l[2].psprites[3] = 74
  l[2].asprite = 104
  l[2].esprite = 98
  l[3] = {}
  l[3].psprites = {}
  l[3].y = 256
  l[3].pstarty = 296
  l[3].psprites[1] = 76
  l[3].psprites[2] = 78
  l[3].psprites[3] = 110
  l[3].asprite = 106
  l[3].esprite = 100
    
  start(1)
end

function start(level) 
  cls()
  cl=level
 
		//player
  p = {}
  p.x = 16 //position x
  p.y = l[cl].pstarty //position y
  p.vx = 0 //velocity x
  p.vy = 0 //velocity y
  p.sprites = l[cl].psprites
  p.cframe = 1 //current frame
  p.tslfc = 0 //last frame change
  p.state = "running" //running, jump1, jump2
  
  bg = {}
  bg.sun = {}
  bg.sun.eyey = 4
  bg.sobjects = {} //scrolling background objects
  for i=1, 15 do
    bg.sobjects[i] = {}
    bg.sobjects[i].x = (i*100) + flr(rnd(100))
    bg.sobjects[i].y = flr(rnd(70))
    bg.sobjects[i].sprite = 43 //cloud sprite
  end
  
  placeenemies()
  
  //camera position
  cx=0
  
  //camera velocity
  cvx=2
  
  //draw time elapsed
  t=0
end

function _update()
  if screen == 1 then
    if btn() > 0 then
      screen = 10
    end  
  end

  if screen == 10 then
		  if btnp(2) then
		    if p.state == "running" then
		      p.state = "jump1"
		      p.vy = -6
		    elseif p.state == "jump1" then
		      p.state = "jump2"
		      p.vy = -6
		    end
		  elseif grounded(p) then
		    p.vy = 0
		    p.y = flr(flr(p.y)/8)*8
		    p.state = "running"
		  else
		    p.vy += 0.55
		  end
		  
		  p.x += min(p.vx, 2)
		  p.y += min(p.vy, 5)
		  
		  for i=1, rawlen(enemies) do
		  		local e = enemies[i]
		  		if enemies.lj > enemies.jumprate then
		  		  e.vy = -10
		  		elseif grounded(e) then
		  		  e.vy = 0
		      e.y = flr(flr(e.y)/8)*8
		  		else
        e.vy += enemies.gravity
      end
      
      e.y += min(e.vy, 5)
    end
    	
    if enemies.lj > enemies.jumprate then
      enemies.lj = 0
    end
    enemies.lj += 1

    if score > 200 and cl==1 then
      start(2)
    elseif score > 400 and cl==2 then
      start(3)
    end
  end
end

function _draw()
  cls()
  t+=1
  
  if screen == 1 then
    drawtitlescreen()
  end
  
  if screen == 10 then  
			  drawenv()
			  p.x += cvx
			  if p.state == "jump2" then
			    spr(l[cl].asprite, p.x, p.y, 2, 2)
			  else
			    ani(p, 2, 2, 3, 4)
	    end
	    
	    for i=1, rawlen(enemies) do
       enemies[i].vy += 0.55
       spr(l[cl].esprite, enemies[i].x, enemies[i].y, 2, 2)
     end
	  
	    cx += cvx
	    if cx > 900 then //loop the level
	      cx = 0 //reset camera
	    		p.x = 16 //reset player
		     for s in all(bg.sobjects) do //reset clouds
		       if s.x > 900 then s.x-=900 end
		     end
		     placeenemies()	    		
	  		end
	  		
	  		print("score: "..score, cx+70, l[cl].y+2, 7)
	  		score += 1
	  		camera(cx, l[cl].y)
  end
end

function placeenemies()
  enemies = {}
  enemies.lj = 0 //last jump
  enemies.jumprate = 40
  enemies.gravity = 0.25
  for i=1, 8 do
    enemies[i] = {}
    enemies[i].x = (100 * i) + flr(rnd(100))
    enemies[i].y = l[cl].y
    enemies[i].vy = 0
    enemies[i].vx = 0
    enemies[i].sprite = l[cl].esprite
  end
end

function drawenv() 
  rectfill(0,0,1050,392,1) //sky

  circfill(cx,l[cl].y,15,10) //sun
  circfill(cx+5,l[cl].y+3,2,6)
  circfill(cx+11,l[cl].y+3,2,6)
  circfill(cx+6,l[cl].y+4,1,1)
  circfill(cx+12,l[cl].y+4,1,1)
  line(cx+3,l[cl].y+7,cx+5,l[cl].y+9,1)
  line(cx+5,l[cl].y+9,cx+9,l[cl].y+10,1)
		
		for s in all(bg.sobjects) do
		  s.x += .25
		  spr(s.sprite, s.x, s.y, 2, 2)  
		  if s.x < 0 then s.x=1000 end
		end
		
		map(0, 0, 0, 0, 128, 48)
end

function ani(n,w,h,frames,speed)
  if n.tslfc > speed then
    n.cframe+=1
    if n.cframe > rawlen(n.sprites) then
      n.cframe=1
    end 
    n.tslfc=0
  end
  spr(n.sprites[n.cframe], n.x, n.y, w, h)
  n.tslfc+=1
end

function grounded(o)
  local v = mget(flr(o.x + 8) / 8, flr(o.y + 16) / 8)
  return fget(v, 0)
end

function drawtitlescreen()
		spr(129, 32, 16, 64, 64)
	 color(13)
	 print("press any button to start", 12, 64)
end
__gfx__
0000000000000000b3b3b3b3b3b3b3b3b3b3b3b04454444455555555000000000000000000000000000000000000000300000000000aaa000000000909000000
00000000000000003bbb3bbb3bbb3bbb3bbb3bb564444454555555550000000000000000000000000000000000000033b000000000aa9aa00000000090000000
007007000000000044444444444444444444443b4444444455aaaa55000000000000003333000000000000000000003333000080000aaa000000000939000000
000770000000000045446440454464404544643b45446440555555550000000000300333b33000000000000003000003333303300b00b0000000000333000000
00077000000000004444444444444444444444b3444444445555555500000000033339333333000000000000003303333833330000bb00000000003333800000
007007000000000044444544444445444444453b444445446666666600000000003333333839000000000000003333b3333b3300000bb0000000000833000000
0000000000000000b3bb33bb40444444b3bb33bb40444444666666660000000000333b333b333000000000000003333333b33000000b00000000003333300000
00000000000000005b3bb5b3445444465b3bb5b04454444666666666000000000003833b33333300000000000000833333330000000b00000000033333330000
000000000000000003b3b3b333b3b330444444b303b3b3b366666666000000000000333333008000000000000000333333330330000000000000003338300000
00000000000000003bbb3bbbb33b33b3444544333bbb3bbb66666666000000000000040444004000000000000033003383003830000eee000000033333330000
0000000000000000bb4444444443443b644443b4bb44444433333333000000000000040440004000000000000033b33333333b30000e8e000000333833333000
0000000000000000b34464404454433344444433b34464403333433b000000033000004440440000000000000033333333333300000eee000000003333300000
00000000000000003b444444044444b3444044b33b44444433333333000000383390000444000000000000000000338b333b3000000030000000033338330000
00000000000000003b44454444043433454444433b4445443b333333000000333333000440000003330000000000033333330000000030000000338333333000
0000000000000000b3bb33bb454444bb44444b33b345444433333b3300000033b834000440000033830000000000003333300000000030000003333333338300
00000000000000000b3bb5b3444644334464443b5b44443433433333000030033334400440000039330000000000004444400000000030000000000444000000
0000000000000000006777777767777703b3b3b0b344544400000000000033003330044440000044330000000000000000000000000000000000000000000000
000000000000000007777767777777673bbb3bb33b44443400000000000383330000000440000440000000000000000000000000000000000000000000000000
00000000000000007777777777777777bb44443bbb4444440000000000033b330000000440444000000000000000000000000000000000000000000000000000
00000000000000007777757777777577b34464bbb344644000000000000333390000000444400000000000000000000000760000000000000000000000000000
000000000000000077777777777777773b0444b33b44444400000000000333334000000444000000000000000000000007666000000000000000000000000000
000000000000000076777777767777773b44453b3b44454400000000003393304400000440000000030b00000007660000760000000000000000000000000000
00000000000000007777577777775777b3bb33bbb345444400000000000000000044000440000000333000000076666000000000000000000000000000000000
000000000000000007777777777777770b3bb5b05b44443400000000000000000004440440000000938300000076666000000000000000000000000000000000
00000000000000007767770000677700000000000000000000000000000000000000044440000000033300000076666607660000000000000000000000000000
00000000000000007777776007777760000000000000000000000000000000000000000440000004430000000766666666666000000000000000000000000000
00000000000000007777777777777777000000000000000000000000000000000000000440000044000000000766666666666600000000000000000000000000
00000000000000007777757777777577000000000000000000000000000000000000000440000444000000000766666666666660000000000000000000000000
00000000000000007777777777777777000000000000000000000000000000000000000444444004400000000076666666666600000000000000000000000000
00000000000000007677777776777777000000000000000000000000000000000000000440000000000000000007666666666000000000000000000000000000
000000fff00000007777577777775777000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000
000000ffc00000007777777007777770000000000000000000000000000000000000000440000000000000000000000000000000000000000000000000000000
0000000999900000000000099990000000000009999000000000000000000000000000008888000000000000000000000000000cccc000000000000cccc00000
0000000f3f0000000000000f3f0000000000000f3f000000000000008888000000000000f3f0000000000000888800000000000f3f0000000000000f3f000000
00000004ff00000000000004ff00000000000004ff00000000000000f3f00000000000004ff0000000000000f3f0000000000004ff0000f000000004ff000000
000000044400000000000004440000000000000444000000000000004ff000000f00000044400000000000004ff000000000000444000c000000000444000000
0000000ff00000000000000ff00000000000000ff00000000f0000004440000000880000f000000000000000444000000000000ff000c0000000000ff000cccf
00000999999000000000099999900000000009999990000000880000f0000000000088888888800000000000f00000000000ccc1cccc00000000ccc1cccc0000
000090999909000000009099999000000000099999090000000088888888800000000088888008000f88888888888800000c0cc1ccc00000fccc0cc1ccc00000
0000909999090000000090999990000000000999990099f000000088888008000000008888800800000000888880008f00c00ccc1cc0000000000ccc1cc00000
000900999909000000009099999000000000009f99000000000000888880080000000088888000f000000088888000000f000cccccc0000000000cccccc00000
000f0099990f00000000f09999f00000000000999900000000000088888000f00000008888800000000000888880000000000cccccc0000000000cccccc00000
00000055550000000000005555000000000000555500000000000088888000000000005555500000000000888880000000000eeeeee0000000000eeeeee00000
00000050050000000000005005000000000000500050000000000055555000000000050000050000000000555550000000000e0000e0000000000e0000e00000
00000050050000000000005005000000000000500005000000000500000500000000500000005c00000005000005000000000e0000e0000000000e0000e00000
00000050050000000004550005000000000000500005000000005000000050000000500000ccc00000c05000000050000000044ddd4400000000044d5d440000
00000040044000000004000004000000000000440004400000c05000000050c00000500ccc000000000ccccccc0050c000999995659999900099999d6d999990
000000400000000000000000040000000000000000000000000ccccccccccc00000cccc0000000000000000000cccc000000000ddd0000000000000d5d000000
00000a0000a0000000000000000000000000005555000000000000099990000000000000888800000000000cccc0000000000000000000000000000cccc00000
000000aaa9000000000000600600000000000034340000000000000f3f00000000000000f3f000000000000f3f00000000000000000000000000000f3f000000
0000008a890005000000006666000000040000444500000000000004ff000f00000000004ff0000000000004ff0000f0000000000000000000000004ff0000f0
000000aaa9000a000000006c0600000000e0005555000000000000044400090000000000444008f00000000444000c00000000000000000000000004440000c0
00000066a9000a000000006666000000000ee004400000000000000ff000900000000000f00080000000000ff000c00000000000000000000000000ff000cc00
0000000a9000a000005000688600050000000eee1eee0000000000999999000000000088888800f000000cc1cccc0000000000000000000000ccccc1cccc0000
005aaaaa9aaa0000000600066000600000000eee1ee0e0000000009999000000000000888880080000000cc1ccc00f0000000000000000000f000cc1ccc00000
0000000a90000000000066666666000000000ee1eee0e000000000999999f000000000888888800000000ccc1cccc000000000000000000000000ccc1cc00000
0000000a900000000000006666000000000000eeee00e0000000009999000000000000888880000000000cccccc00000000000000000000000000cccccc00000
000000aaa90000000000006666000000000000eeee0040000000009999000000000000888880000000000cccccc00000000000000000000000000cccccc00000
00000aaaaaa00000000000666600000000000055550066000000005555000000000000555550000000000eeeeee00000000000000000000000000eeeeee00000
00000aa00aa00000000000600600000000000050050600600000005000500000000005000005000000000e0000e00000000000000000000000000e0000e00000
00000a0000a000000000006006000000000000500506666000000050000500000000500000005c0000000e0000e00000000000000000000000000e0000e00000
00000a0000a000000000006006000000000000500506666000045500000500000000500000ccc0000000044ddd44099000000000000000000000044dd5440000
00000a0000a000000000006006000000000000500500000000400000000440000000500ccc000000000099956599900000000000000000000099999d6d999990
0005aaa00aaa5000000056605600000000000250250000000000000000000000000cccc0000000000099000ddd000000000000000000000000000005dd000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060
60606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060
61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161
61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161
__gff__
0000010101010100000000000000000000000101010001000000000000000000000001010100000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020000000000000000000002020202020200000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000708090a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000001718191a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000708090a00000000000000001b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000002728292a0000000000000000000000000000000000000000000000000000000000000000000708090a00000000001718191a0000000000000012020400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000001d38393a0000000000000000000000000000000d0000000000000b0c0000000000000000001718191a00000000002728292a00000000000000000000000000000000000708090a0000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000012020204000000000000000000000708090a12040000000000001b1c0000000000000000002728292a00000000003738393a00001d00000000000000000000000000001718191a0000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000001718191a00000000000000120202040000000000000d003738393a00000000120202020202020400000000000000000000000000002728292a0000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000002728292a000000000000000000000000000000001202020202040000000000000000000000000000000000000000000000000000003738393a000d000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000b0c0000000000000000000000000000003738393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012020202020204000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000001b1c0000000000000000000000000000120303030303040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000120313000708090a0000000000000000000000000000000000000708090a000000000000000000120400000000000000001d000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001205131718191a0000000d00000000000000000000000000001718191a00000000000000000000000000000000000012020204000700000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000002728292a00000024000000000000000b0c00000000002728292a0000000000000000000000000b0c000000000000000000000000000000000b0c0000000000000000000000000000000000000000000b0c000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000003738393a00000000000000001d00001b1c000000001d3738393a0000001d0d0000000000000d1b1c000000000000000000000000001d00001b1c0000000000000000001d00000000000000000000001b1c000000000000000000000000000000000000000000000000
03030303030303030303030303030303030303030303030303030304000000000000120303030303030303030303030303040000120400001203030303030303030303030303030400001203030303030303030303030303030303030303040000000d0012030303030303030303030303030303030303030303030303030303
0505050505050505050505050505050505050505050505050505050000000000000000050505050505050505050505050500000000000000000505050505050505050505050505000000000505050505050505050505050505050505050500002400240000050505050505050505050505050505050505050505050505050505
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000708090a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000708090a00000000000000000000000000001718191a0000000000000e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000001718191a00000000000000000000000000002728292a0000000000001e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000002728292a0000000000000000000000001d003738393a000000000022233200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000d003738393a000000000000000000000000330022232332003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000002223232323233200000033000000330000000000000000000000000000002223320000000000000000000708090a000000000000000000000000000000000708090a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001718191a000000000000000000000000000000001718191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000e0f0000000000000000000000000000000000000000000e0f00000000002728292a000000000000000000000000000000002728292a000e0f00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000001d000000000000000d1e1f00000000000000000000000000000d001d000000001e1f00000000003738393a00000000000d000000000000000000003738393a001e1f000000000000001d0000000000000000000000000000000000000000000000000000000000000000
2323232323232323232323232323232323232323232323232323232323232323232323232323233200000000222323232323233200002223320000222323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323
2323232323232323232323232323232323232323232323232323232323232323232323232323230000000000002323232323230000000023000000002323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323
