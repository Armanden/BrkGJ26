//List
// [x] Assets and map
// [x] interaction mechanic
// [x] flashlight and battery mechanic
// [x] player health and poisoning
// [x] NPCs
// [x] speech bubbles
// [x] tracker of talking --> after you talk to someone, their speech bubble changes
// [x] Bars and textures
// [x] add collectable batteries
// [not needed] include a locker wher the playr can hide
// [x] walls
// [x] angry man mechanic
// [not needed] map movement mechanic, along with moving the npcs
// [] dialouge and lore whateever
// [x] lighting
// [x] police donut mechanic, where he gives you batteries
// [] map walls
// [] add a few baloons
//
// Bug:
// [x] if the player eats the cake and spams the E key it doesnt stop the interaction from stopping till the player stops colliding


package main

import rl "vendor:raylib"
import "core:time"

//sturctures --------------------------------------------------------------------------------


Player :: struct {
	x : i32,
	y : i32,
	speed : i32,
	texture : rl.Texture2D,
	hitbox: rl.Rectangle,
	health: i32,
	alive: bool,
}

battery_collectable :: struct {
	x: i32,
	y: i32,
	texture: rl.Texture2D,
	value: i16,
	picked_up: bool,
	hitbox: rl.Rectangle,
}

food :: struct {
	x: i32,
	y: i32,
	texture: rl.Texture2D,
	poisonous: bool,
	picked_up: bool,
	hitbox: rl.Rectangle,

}

npc :: struct {
	x: i32,
	y: i32,
	texture: rl.Texture2D,
	dialouge: dialouge,
	hitbox: rl.Rectangle,

}

dialouge :: struct {
	state: i8,
	drawing: bool,
	lines: [MAX_DIALOUGE]cstring,
}

MAX_DIALOUGE :: 7



// functions --------------------------------------------------------------------------

DrawPlayer :: proc (x, y: i32, texture: rl.Texture2D, hitbox: rl.Rectangle) {
	rl.DrawRectangleRec(hitbox, rl.BLACK)
	rl.DrawTexture(texture, x, y, rl.WHITE)
}

DrawFlashlight :: proc(battery: i16, x,y: i32){

	if battery >=10 {
		rl.DrawCircle(x,y,26, rl.GRAY)
	}else {
		rl.DrawCircle(x,y,26,rl.BLACK)
	}

}

DrawBattery :: proc(battery: i16, texture1: rl.Texture2D, texture2: rl.Texture2D,texture3: rl.Texture2D,texture4: rl.Texture2D,texture5: rl.Texture2D,){

	if battery > 80 {
		rl.DrawTextureEx(texture5, rl.Vector2{0,0}, 0, 3, rl.WHITE)
	}
	if battery > 60 && battery < 80{
		rl.DrawTextureEx(texture4,rl.Vector2{0,0},0,3,rl.WHITE)
	}
	if battery >= 40 && battery < 60{
		rl.DrawTextureEx(texture3,rl.Vector2{0,0},0,3,rl.WHITE)
	}
	if battery >= 20 && battery < 40{
		rl.DrawTextureEx(texture2,rl.Vector2{0,0},0,3,rl.WHITE)
	}
	if battery >= 0 && battery < 20{
		rl.DrawTextureEx(texture1,rl.Vector2{0,0},0,3,rl.WHITE)
	}


}

DrawBatteryCollectable :: proc(x,y : i32, texture: rl.Texture2D, status: bool, hitbox: rl.Rectangle ){

	if !status{
		rl.DrawRectangleRec(hitbox, rl.BLACK)
		rl.DrawTextureEx(texture, rl.Vector2{f32(x),f32(y)},0,1.6, rl.WHITE)
	}
}

DrawFood :: proc(x,y : i32, texture: rl.Texture2D, status: bool, hitbox: rl.Rectangle){

	if !status{
		rl.DrawRectangleRec(hitbox, rl.BLACK)
		rl.DrawTexture(texture, x,y, rl.WHITE)
	}

}

DrawNPC :: proc(x,y: i32, texture: rl.Texture2D, hitbox: rl.Rectangle ){
	rl.DrawRectangleRec(hitbox, rl.BLACK)
	rl.DrawTextureEx(texture, rl.Vector2{f32(x),f32(y)},0,1.5, rl.WHITE)
}

DrawDialouge :: proc(d: ^dialouge){
	if d.drawing {
		index := int(d.state - 1)
		if index >= 0 && index < MAX_DIALOUGE {
			rl.DrawText(d.lines[index], 10, 660, 20, rl.WHITE)
		}
	}
}

SpawnBats :: proc(mission: bool,x, y: i32, texture: rl.Texture2D, picked_up:bool, hitbox: rl.Rectangle, x2, y2: i32, texture2: rl.Texture2D, picked_up2: bool, hitbox2: rl.Rectangle ){
	if mission{
		DrawBatteryCollectable(x, y, texture, picked_up, hitbox)
		DrawBatteryCollectable(x2, y2, texture2, picked_up2, hitbox2)
	}
}




// main ------------------------------------------------------------------------------------------------

main :: proc () {
	rl.InitWindow(700, 900, "Late to the PARTY")
	rl.SetTargetFPS(60)

	p: Player
	p.x = 345
	p.y = 390
	p.speed = 3

	p.texture = rl.LoadTexture("assets/player.png")

	//p.hitbox = {f32(p.x), f32(p.y), 4, 8,}
	//
	p.health = 50
	p.alive = true

	bc: battery_collectable
	bc.x = 300
	bc.y = 300
	bc.value = 20
	bc.texture = rl.LoadTexture("assets/batterycollectable.png")
	bc.picked_up = false
	bc.hitbox = {f32(bc.x) + 14, f32(bc.y) + 13, 3.5, 6,}

	bc2: battery_collectable
	bc2.x = 580
	bc2.y = 600
	bc2.value = 30
	bc2.texture = rl.LoadTexture("assets/batterycollectable.png")
	bc2.picked_up = false
	bc2.hitbox = {f32(bc2.x) + 14, f32(bc2.y) + 13, 3.5, 6,}




	texture1 :rl.Texture2D= rl.LoadTexture("assets/batteryempty.png")
	texture2 :rl.Texture2D= rl.LoadTexture("assets/batteryone.png")
	texture3 :rl.Texture2D= rl.LoadTexture("assets/batterytwo.png")
	texture4 :rl.Texture2D= rl.LoadTexture("assets/batterythree.png")
	texture5 :rl.Texture2D= rl.LoadTexture("assets/batteryfull.png")


	battery: i16 = 100
	batteryTimer: f32 = 0

	poisonous_cake: food
	poisonous_cake.x = 130
	poisonous_cake.y = 530
	poisonous_cake.picked_up = false
	poisonous_cake.poisonous = true
	poisonous_cake.texture = rl.LoadTexture("assets/cakepoisonous.png")
	poisonous_cake.hitbox = {f32(poisonous_cake.x) + 12, f32(poisonous_cake.y) + 11 , 4,4}

	normal_cake: food
	normal_cake.x = 590
	normal_cake.y = 620
	normal_cake.picked_up = false
	normal_cake.poisonous = false
	normal_cake.texture = rl.LoadTexture("assets/cakenormal.png")
	normal_cake.hitbox = {f32(normal_cake.x)+12, f32(normal_cake.y)+11, 4,4}

	donut: food
	donut.x = 45
	donut.y = 290
	donut.picked_up = false
	donut.poisonous = false
	donut.texture = rl.LoadTexture("assets/donut.png")
	donut.hitbox = {f32(donut.x)+32, f32(donut.y)+32, 4,4}

	//npcs

	bob: npc
	bob.x = 400
	bob.y = 400
	bob.dialouge.state = 1
	bob.dialouge.drawing = false
	bob.dialouge.lines = {
		"Line 1: Some dialouge...",
		"Line 2: Other dialouge",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	bob.hitbox = {f32(bob.x) +14.2, f32(bob.y) +12.4 , 3.2, 11}
	bob.texture = rl.LoadTexture("assets/bob.png")

	cat: npc
	cat.x = 602
	cat.y = 675
	cat.dialouge.state = 1
	cat.dialouge.drawing = false
	cat.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	cat.hitbox = {f32(cat.x) +14.2, f32(cat.y) +12.4 , 3.2, 4}
	cat.texture = rl.LoadTexture("assets/cat.png")

	hungry: npc
	hungry.x = 200
	hungry.y = 500
	hungry.dialouge.state = 1
	hungry.dialouge.drawing = false
	hungry.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	hungry.hitbox = {f32(hungry.x) +14.2, f32(hungry.y) +12.4 , 3.2, 4}
	hungry.texture = rl.LoadTexture("assets/hungry.png")

	// idiotsam will have a different mechanic, one of attack
	//and i dont know why i didnt just make a universal function but o'well

	idiotsam: npc
	idiotsam.x = 300
	idiotsam.y = 200
	idiotsam.dialouge.state = 1
	idiotsam.dialouge.drawing = false
	idiotsam.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	//idiotsam.hitbox = {f32(idiotsam.x) +14.2, f32(idiotsam.y) +12.4 , 3.2, 4}
	idiotsam.texture = rl.LoadTexture("assets/idiotsam.png")
// will have extra mechanics


	jake: npc
	jake.x = 200
	jake.y = 400
	jake.dialouge.state = 1
	jake.dialouge.drawing = false
	jake.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	jake.hitbox = {f32(jake.x) +14.2, f32(jake.y) +12.4 , 3.2, 4}
	jake.texture = rl.LoadTexture("assets/jake.png")

	meg: npc
	meg.x = 400
	meg.y = 100
	meg.dialouge.state = 1
	meg.dialouge.drawing = false
	meg.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	meg.hitbox = {f32(meg.x) +14.2, f32(meg.y) +12.4 , 3.2, 4}
	meg.texture = rl.LoadTexture("assets/meg.png")

	police: npc
	police.x = 30
	police.y = 680
	police.dialouge.state = 1
	police.dialouge.drawing = false
	police.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	police.hitbox = {f32(police.x) +14.2, f32(police.y) +12.4 , 3.2, 4}
	police.texture = rl.LoadTexture("assets/police.png")

	stan: npc
	stan.x = 300
	stan.y = 500
	stan.dialouge.state = 1
	stan.dialouge.drawing = false
	stan.dialouge.lines = {
		"Line 1: I is Cat",
		"Line 2: I can has cheesburger",
		"Line 3",
		"Line 4",
		"Line 5",
		"Line 6",
		"Line 7",
	}
	stan.hitbox = {f32(stan.x) +14.2, f32(stan.y) +12.4 , 3.2, 4}
	stan.texture = rl.LoadTexture("assets/stan.png")


	IsSamAngry:bool= false
	sam_direction: f32 = 1.0
	sam_speed: f32 = 10.0

	//map
	game_map: rl.Texture2D = rl.LoadTexture("assets/map.png")

	time_since_light:f32

	donut_mission_complete :bool=false

	baloon: rl.Texture2D = rl.LoadTexture("assets/baloon.png")

	defer rl.UnloadTexture(p.texture)

	defer rl.UnloadTexture(bc.texture)
	defer rl.UnloadTexture(bc2.texture)

	defer rl.UnloadTexture(texture1)
	defer rl.UnloadTexture(texture2)
	defer rl.UnloadTexture(texture3)
	defer rl.UnloadTexture(texture4)
	defer rl.UnloadTexture(texture5)

	defer rl.UnloadTexture(poisonous_cake.texture)
	defer rl.UnloadTexture(normal_cake.texture)
	defer rl.UnloadTexture(donut.texture)

	defer rl.UnloadTexture(bob.texture)
	defer rl.UnloadTexture(cat.texture)
	defer rl.UnloadTexture(hungry.texture)
	defer rl.UnloadTexture(idiotsam.texture)
	defer rl.UnloadTexture(jake.texture)
	defer rl.UnloadTexture(meg.texture)
	defer rl.UnloadTexture(police.texture)
	defer rl.UnloadTexture(stan.texture)

	defer rl.UnloadTexture(game_map)

	defer rl.UnloadTexture(baloon)



	for !rl.WindowShouldClose() {
		p.hitbox = {f32(p.x) - 1, f32(p.y) - 3, 3.2, 11,} // have to put it in the game loop so it updates with the playr position
		idiotsam.hitbox = {f32(idiotsam.x) +14.2, f32(idiotsam.y) +12.4 , 3.2, 4}

		if !bc.picked_up {
			if rl.CheckCollisionRecs(bc.hitbox, p.hitbox){
				bc.picked_up = true
				battery = battery + 20
			}
		}

		if !bc2.picked_up {
					if rl.CheckCollisionRecs(bc2.hitbox, p.hitbox){
						bc2.picked_up = true
						battery = battery + 30
					}
				}

		if p.alive {
			//movement
			if rl.IsKeyDown(.D) {
				p.x += p.speed
			}
			if rl.IsKeyDown(.A) {
				p.x -= p.speed
			}
			if rl.IsKeyDown(.W) {
				p.y -= p.speed
			}
			if rl.IsKeyDown(.S) {
				p.y += p.speed
			}
		}

		if p.health <= 0 {
			p.alive = false
		}

		if !poisonous_cake.picked_up {
				if rl.CheckCollisionRecs(p.hitbox, poisonous_cake.hitbox){
					if rl.IsKeyPressed(.E){
						p.health = p.health - 20
						poisonous_cake.picked_up = true
				}
			}
		}

		if !normal_cake.picked_up{
			if rl.CheckCollisionRecs(p.hitbox, normal_cake.hitbox){
					if rl.IsKeyPressed(.E){
						p.health = p.health + 20
						normal_cake.picked_up = true
					}
			}
		}

		if !donut.picked_up{
			if rl.CheckCollisionRecs(p.hitbox, donut.hitbox){
				if rl.IsKeyPressed(.E){
					donut.picked_up = true
				}
			}
		}

		if donut.picked_up && police.dialouge.state == 5 {
			donut_mission_complete = true
		}




		if rl.CheckCollisionRecs(p.hitbox, bob.hitbox){
			if rl.IsKeyPressed(.E) {
				bob.dialouge.drawing = true
			}
		} else {
			bob.dialouge.drawing = false
		}

		if bob.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			bob.dialouge.state += 1
			if bob.dialouge.state > MAX_DIALOUGE {
				bob.dialouge.state = 1
				bob.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, cat.hitbox){
			if rl.IsKeyPressed(.E) {
				cat.dialouge.drawing = true
			}
		} else {
			cat.dialouge.drawing = false
		}

		if cat.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			cat.dialouge.state += 1
			if cat.dialouge.state > MAX_DIALOUGE {
				cat.dialouge.state = 1
				cat.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, hungry.hitbox){
			if rl.IsKeyPressed(.E) {
				hungry.dialouge.drawing = true
			}
		} else {
			hungry.dialouge.drawing = false
		}

		if hungry.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			hungry.dialouge.state += 1
			if hungry.dialouge.state > MAX_DIALOUGE {
				hungry.dialouge.state = 1
				hungry.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, idiotsam.hitbox){
			if rl.IsKeyPressed(.E) {
				idiotsam.dialouge.drawing = true
			}
		} else {
			idiotsam.dialouge.drawing = false
		}

		if idiotsam.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			idiotsam.dialouge.state += 1
			if idiotsam.dialouge.state > MAX_DIALOUGE {
				idiotsam.dialouge.state = 1
				idiotsam.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, jake.hitbox){
			if rl.IsKeyPressed(.E) {
				jake.dialouge.drawing = true
			}
		} else {
			jake.dialouge.drawing = false
		}

		if jake.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			jake.dialouge.state += 1
			if jake.dialouge.state > MAX_DIALOUGE {
				jake.dialouge.state = 1
				jake.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, hungry.hitbox){
			if rl.IsKeyPressed(.E) {
				meg.dialouge.drawing = true
			}
		} else {
			meg.dialouge.drawing = false
		}

		if meg.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			meg.dialouge.state += 1
			if meg.dialouge.state > MAX_DIALOUGE {
				meg.dialouge.state = 1
				meg.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, police.hitbox){
			if rl.IsKeyPressed(.E) {
				police.dialouge.drawing = true
			}
		} else {
			police.dialouge.drawing = false
		}

		if police.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			police.dialouge.state += 1
			if police.dialouge.state > MAX_DIALOUGE {
				police.dialouge.state = 1
				police.dialouge.drawing = false
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, stan.hitbox){
			if rl.IsKeyPressed(.E) {
				stan.dialouge.drawing = true
			}
		} else {
			stan.dialouge.drawing = false
		}

		if stan.dialouge.drawing && rl.IsKeyPressed(.ENTER){
			stan.dialouge.state += 1
			if stan.dialouge.state > MAX_DIALOUGE {
				stan.dialouge.state = 1
				stan.dialouge.drawing = false
			}
		}

		//angry idiot sam mechanic
		if normal_cake.picked_up && idiotsam.dialouge.state >=6 {
			IsSamAngry = true
		}

		if IsSamAngry {
			idiotsam.x += i32(sam_direction * sam_speed)

			if idiotsam.x > 690 {
				idiotsam.x = 690
				sam_direction = -1.0
			}

         	if idiotsam.x <= 0 {
				idiotsam.x = 0
				sam_direction = 1.0
			}
		}

		if rl.CheckCollisionRecs(p.hitbox, idiotsam.hitbox) && IsSamAngry{
			p.health = p.health - 40
			bc.value = bc.value - 80
		}


		// after 20 seconds of no light the player dies
		// p.alive = false

		if battery <= 0 {
			time_since_light += rl.GetFrameTime()
		}

		if time_since_light >= 20 {
			p.alive = false
		}


		//walls
		if p.y <=100 {
			p.y = 100
		}
		if p.x >=700{
			p.x = 700
		}
		if p.x <=0{
			p.x = 0
		}
		if p.y >= 750 {
			p.y = 750
		}
		//map walls






		rl.BeginDrawing()

		batteryTimer += rl.GetFrameTime()
		if batteryTimer >= 5 {
			battery -= 3
			batteryTimer = 0
		}
		rl.ClearBackground(rl.BLACK)

		//hitboxes first // can be added to their own functions
		//rl.DrawRectangleRec(p.hitbox, rl.GREEN)
		//rl.DrawRectangleRec(bc.hitbox, rl.GREEN)

		//main
		if battery > 0 {
			rl.DrawTextureEx(game_map, rl.Vector2{0,90}, 0, 22, rl.WHITE)
		}

		if !p.alive{
			rl.DrawText("YOU DIED", 250, 340, 50, rl.RED)
		}

		//DrawFlashlight(battery,p.x,p.y)
		DrawPlayer(p.x - 16, p.y - 16, p.texture, p.hitbox)
		DrawBattery(battery, texture1,texture2,texture3,texture4,texture5)
		//DrawBatteryCollectable(bc.x, bc.y, bc.texture, bc.picked_up, bc.hitbox)

		if battery > 0 {
			DrawFood(poisonous_cake.x, poisonous_cake.y, poisonous_cake.texture,poisonous_cake.picked_up, poisonous_cake.hitbox)
			DrawFood(normal_cake.x, normal_cake.y, normal_cake.texture,normal_cake.picked_up, normal_cake.hitbox)

			if !donut.picked_up {
				rl.DrawRectangleRec(donut.hitbox, rl.BLACK)
				rl.DrawTextureEx(donut.texture, rl.Vector2{f32(donut.x),f32(donut.y)},0,2, rl.WHITE)
			}

			if donut.picked_up && police.dialouge.state < 6 {
				rl.DrawRectangleRec(donut.hitbox, rl.BLACK)
				rl.DrawTextureEx(donut.texture,rl.Vector2{680, 800}, 0, 2, rl.WHITE)
			}



			//NPCs
			DrawNPC(bob.x,bob.y, bob.texture, bob.hitbox)
			DrawNPC(cat.x,cat.y,cat.texture,cat.hitbox)
			DrawNPC(hungry.x,hungry.y,hungry.texture,hungry.hitbox)
			DrawNPC(idiotsam.x,idiotsam.y,idiotsam.texture,idiotsam.hitbox)
			DrawNPC(jake.x,jake.y,jake.texture,jake.hitbox)
			DrawNPC(meg.x,meg.y,meg.texture,meg.hitbox)
			DrawNPC(police.x,police.y,police.texture,police.hitbox)
			DrawNPC(stan.x,stan.y,stan.texture,stan.hitbox)


			//dialouges
			DrawDialouge(&bob.dialouge)
			DrawDialouge(&cat.dialouge)
			DrawDialouge(&hungry.dialouge)
			DrawDialouge(&idiotsam.dialouge)
			DrawDialouge(&jake.dialouge)
			DrawDialouge(&meg.dialouge)
			DrawDialouge(&police.dialouge)
			DrawDialouge(&stan.dialouge)

			SpawnBats(donut_mission_complete,
				bc.x, bc.y, bc.texture, bc.picked_up, bc.hitbox,
				bc2.x, bc2.y, bc2.texture, bc2.picked_up, bc2.hitbox
			)


			rl.DrawTexture(baloon, 370, 390, rl.WHITE)
			rl.DrawTexture(baloon, 160, 390, rl.WHITE)
			rl.DrawTexture(baloon, 240, 390, rl.WHITE)
			rl.DrawTexture(baloon, 300, 390, rl.WHITE)
			rl.DrawTexture(baloon, 160, 260, rl.WHITE)
			rl.DrawTexture(baloon, 240, 260, rl.WHITE)
			rl.DrawTexture(baloon, 300, 260, rl.WHITE)


		}
		//always draw


		//bars
		rl.DrawRectangle(100,40, p.health * 2, 20, rl.RED)
		rl.DrawText("Player Health" ,100,20,11, rl.WHITE)
		rl.EndDrawing()


	}

	rl.UnloadTexture(p.texture)
	rl.CloseWindow()

}
