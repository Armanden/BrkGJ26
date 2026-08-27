//List
// [] Assets and map
// [x] interaction mechanic
// [x] flashlight and battery mechanic
// [x] player health and poisoning
// [x] NPCs
// [] speech bubbles
// [] tracker of talking --> after you talk to someone, their speech bubble changes
// [x] Bars and textures
// [x] add collectable batteries
// [] decorations
// [x] walls
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
		rl.DrawTexture(texture, x,y, rl.WHITE)
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
	rl.DrawTexture(texture, x,y, rl.WHITE)
}

DrawDialouge :: proc(d: ^dialouge){
	if d.drawing {
		index := int(d.state - 1)
		if index >= 0 && index < MAX_DIALOUGE {
			rl.DrawText(d.lines[index], 10, 660, 20, rl.WHITE)
		}
	}
}




// main ------------------------------------------------------------------------------------------------

main :: proc () {
	rl.InitWindow(700, 800, "Late to the PARTY")
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


	texture1 :rl.Texture2D= rl.LoadTexture("assets/batteryempty.png")
	texture2 :rl.Texture2D= rl.LoadTexture("assets/batteryone.png")
	texture3 :rl.Texture2D= rl.LoadTexture("assets/batterytwo.png")
	texture4 :rl.Texture2D= rl.LoadTexture("assets/batterythree.png")
	texture5 :rl.Texture2D= rl.LoadTexture("assets/batteryfull.png")


	battery: i16 = 100
	batteryTimer: f32 = 0

	poisonous_cake: food
	poisonous_cake.x = 300
	poisonous_cake.y = 550
	poisonous_cake.picked_up = false
	poisonous_cake.poisonous = true
	poisonous_cake.texture = rl.LoadTexture("assets/cakepoisonous.png")
	poisonous_cake.hitbox = {f32(poisonous_cake.x) + 12, f32(poisonous_cake.y) + 11 , 4,4}

	normal_cake: food
	normal_cake.x = 600
	normal_cake.y = 200
	normal_cake.picked_up = false
	normal_cake.poisonous = false
	normal_cake.texture = rl.LoadTexture("assets/cakenormal.png")
	normal_cake.hitbox = {f32(normal_cake.x)+12, f32(normal_cake.y)+11, 4,4}

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



	defer rl.UnloadTexture(p.texture)

	defer rl.UnloadTexture(bc.texture)

	defer rl.UnloadTexture(texture1)
	defer rl.UnloadTexture(texture2)
	defer rl.UnloadTexture(texture3)
	defer rl.UnloadTexture(texture4)
	defer rl.UnloadTexture(texture5)

	defer rl.UnloadTexture(poisonous_cake.texture)
	defer rl.UnloadTexture(normal_cake.texture)

	defer rl.UnloadTexture(bob.texture)


	for !rl.WindowShouldClose() {
		p.hitbox = {f32(p.x) - 1, f32(p.y) - 3, 3.2, 11,} // have to put it in the game loop so it updates with the playr position

		if !bc.picked_up {
			if rl.CheckCollisionRecs(bc.hitbox, p.hitbox){
				bc.picked_up = true
				battery = battery + 20
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
		if p.y >= 650 {
			p.y = 650
		}




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
		DrawFlashlight(battery,p.x,p.y)
		DrawPlayer(p.x - 16, p.y - 16, p.texture, p.hitbox)
		DrawBattery(battery, texture1,texture2,texture3,texture4,texture5)
		DrawBatteryCollectable(bc.x, bc.y, bc.texture, bc.picked_up, bc.hitbox)
		DrawFood(poisonous_cake.x, poisonous_cake.y, poisonous_cake.texture,poisonous_cake.picked_up, poisonous_cake.hitbox)
		DrawFood(normal_cake.x, normal_cake.y, normal_cake.texture,normal_cake.picked_up, normal_cake.hitbox)

		//NPCs
		DrawNPC(bob.x,bob.y, bob.texture, bob.hitbox)

		//dialouges
		DrawDialouge(&bob.dialouge)

		//always draw


		//bars
		rl.DrawRectangle(100,40, p.health * 2, 20, rl.RED)
		rl.DrawText("Player Health" ,100,20,11, rl.WHITE)
		rl.EndDrawing()


	}

	rl.UnloadTexture(p.texture)
	rl.CloseWindow()

}
