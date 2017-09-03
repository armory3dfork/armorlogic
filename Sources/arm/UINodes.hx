package arm;

import armory.object.Object;
import armory.system.Cycles;
import zui.*;
import zui.Nodes;
import iron.data.SceneFormat;
import iron.data.MaterialData;

class UINodes extends armory.Trait {

	public static var inst:UINodes;
	public static var show = true;

	public static var ww = 0;
	public static var wh = 0;
	public static var wx = 0;
	public static var wy = 0;

	var ui:Zui;
	var drawMenu = false;
	var showMenu = false;
	var hideMenu = false;
	var menuCategory = "";
	var addNodeButton = false;
	var popupX = 0.0;
	var popupY = 0.0;

	static var font:kha.Font;

	static var lastLayout = -1;
	public static function calcLayout() {		
		
		if (arm.App.layout == 0) {
			UINodes.wx = 0;
			UINodes.wh = 300;
			UINodes.wy = arm.App.realh() - UINodes.wh;
			UINodes.ww = arm.App.realw() /*- UITrait.ww*/;
			if (lastLayout != arm.App.layout) { nodes.panX += 300; nodes.panY -= 200; }
		}
		else {
			UINodes.wx = Std.int((arm.App.realw() /*- UITrait.ww*/) / 2);
			UINodes.wh = arm.App.realh();
			UINodes.wy = 0;
			UINodes.ww = Std.int((arm.App.realw() /*- UITrait.ww*/) / 2);
			if (lastLayout != arm.App.layout) { nodes.panX -= 300; nodes.panY += 200; }
		}

		lastLayout = arm.App.layout;
	}

	public function new() {
		super();
		inst = this;
		calcLayout();

		// Load font for UI labels
		iron.data.Data.getFont('droid_sans.ttf', function(f:kha.Font) {
		iron.data.Data.getBlob('default_material.json', function(b:kha.Blob) {
		iron.data.Data.getBlob('nodes.json', function(bnodes:kha.Blob) {
		kha.Assets.loadImage('color_wheel', function(image:kha.Image) {

			canvas = haxe.Json.parse(b.toString());
			NodeCreator.list = haxe.Json.parse(bnodes.toString());

			font = f;
			var t = Reflect.copy(zui.Themes.dark);
			t.FILL_WINDOW_BG = true;
			t._ELEMENT_H = 18;
			t._BUTTON_H = 16;
			// ui = new Zui({font: f, theme: t, scaleFactor: 2.5}); ////
			ui = new Zui({font: f, theme: t, color_wheel: image});
			ui.scrollEnabled = false;
			armory.Scene.active.notifyOnInit(sceneInit);
		});
		});
		});
		});
	}

	function sceneInit() {
		// Store references to cube and plane objects
		notifyOnRender2D(render2D);
		notifyOnUpdate(update);
	}

	var mx = 0.0;
	var my = 0.0;
	static var frame = 0;
	var mdown = false;
	var mreleased = false;
	var mchanged = false;
	var changed = false;
	function update() {
		if (frame == 8) parseMaterial(); // Temp cpp fix
		frame++;

		//
		var mouse = iron.system.Input.getMouse();
		mreleased = mouse.released();
		mdown = mouse.down();

		if (ui.changed) {
			mchanged = true;
			if (!mdown) changed = true;
		}
		if ((mreleased && mchanged) || changed) {
			mchanged = changed = false;
			parseMaterial();
		}
		//

		if (!show) return;
		if (!UITrait.uienabled) return;
		var keyboard = iron.system.Input.getKeyboard();

		if (mouse.x < wx || mouse.x > wx + ww || mouse.y < wy) return;

		if (ui.isTyping) return;

		if (mouse.started("right")) {
			mx = mouse.x;
			my = mouse.y;
		}
		else if (addNodeButton) {
			showMenu = true;
			addNodeButton = false;
		}
		else if (mouse.released()) {
			hideMenu = true;
		}

		if (keyboard.started("x")) {
			nodes.removeNode(nodes.nodeSelected, canvas);
			changed = true;
		}

		if (keyboard.started("p")) {
			trace(haxe.Json.stringify(canvas));
		}
	}

	static var nodes = new Nodes();
	static var canvas:TNodeCanvas = null;
	public static var grid:kha.Image = null;

	function getNodeX():Int {
		var mouse = iron.system.Input.getMouse();
		return Std.int((mouse.x - wx - nodes.PAN_X()) / nodes.SCALE);
	}

	function getNodeY():Int {
		var mouse = iron.system.Input.getMouse();
		return Std.int((mouse.y - wy - nodes.PAN_Y()) / nodes.SCALE);
	}

	public function drawGrid() {
		var w = ww + 40 * 2;
		var h = wh + 40 * 2;
		grid = kha.Image.createRenderTarget(w, h);
		grid.g2.begin(true, 0xff141414);
		for (i in 0...Std.int(h / 40) + 1) {
			grid.g2.color = 0xff303030;
			grid.g2.drawLine(0, i * 40, w, i * 40);
			grid.g2.color = 0xff202020;
			grid.g2.drawLine(0, i * 40 + 20, w, i * 40 + 20);
		}
		for (i in 0...Std.int(w / 40) + 1) {
			grid.g2.color = 0xff303030;
			grid.g2.drawLine(i * 40, 0, i * 40, h);
			grid.g2.color = 0xff202020;
			grid.g2.drawLine(i * 40 + 20, 0, i * 40 + 20, h);
		}
		grid.g2.end();
	}

	@:access(zui.Zui)
	function render2D(g:kha.graphics2.Graphics) {
		if (!show) return;
		
		if (!UITrait.uienabled && ui.inputRegistered) ui.unregisterInput();
		if (UITrait.uienabled && !ui.inputRegistered) ui.registerInput();

		g.end();

		if (grid == null) drawGrid();

		// Start with UI
		ui.begin(g);
		// ui.begin(rt.g2); ////
		
		// Make window
		var hwin = Id.handle();
		if (ui.window(hwin, wx, wy, ww, wh)) {
		// if (ui.window(hwin, 0, 0, rt.width, rt.height)) { ////

			ui.g.color = 0xffffffff;
			ui.g.drawImage(grid, (nodes.panX * nodes.SCALE) % 40 - 40, (nodes.panY * nodes.SCALE) % 40 - 40);

			ui.g.font = font;
			ui.g.fontSize = 42;
			var title = "Tree";
			var titlew = ui.g.font.width(42, title);
			var titleh = ui.g.font.height(42);
			ui.g.drawString(title, ww - titlew - 20, wh - titleh - 10);

			// Recompile material on change
			ui.changed = false;
			nodes.nodeCanvas(ui, canvas);

			ui.g.color = 0xff111111;
			ui.g.fillRect(0, 0, ww, 24);
			ui.g.color = 0xffffffff;

			ui._x = 3;
			ui._y = 3;
			ui._w = 105;
			if (ui.button("Logic")) { addNodeButton = true; menuCategory = "Logic"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Event")) { addNodeButton = true; menuCategory = "Event"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Action")) { addNodeButton = true; menuCategory = "Action"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Value")) { addNodeButton = true; menuCategory = "Value"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Variable")) { addNodeButton = true; menuCategory = "Variable"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Input")) { addNodeButton = true; menuCategory = "Input"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Animation")) { addNodeButton = true; menuCategory = "Animation"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Physics")) { addNodeButton = true; menuCategory = "Physics"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Navmesh")) { addNodeButton = true; menuCategory = "Navmesh"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Sound")) { addNodeButton = true; menuCategory = "Sound"; popupX = wx + ui._x; popupY = wy + ui._y; }
			ui._x += 105 + 3;
			ui._y = 3;
			if (ui.button("Native")) { addNodeButton = true; menuCategory = "Native"; popupX = wx + ui._x; popupY = wy + ui._y; }
		}

		ui.endWindow();

		if (drawMenu) {
			
			var ph = 100;//NodeCreator.numNodes[menuCategory] * 20;
			var py = popupY;
			g.color = 0xff222222;
			g.fillRect(popupX, py, 105, ph);

			ui.beginLayout(g, Std.int(popupX), Std.int(py), 105);
			
			NodeCreator.draw(this, menuCategory);

			ui.endLayout();
		}

		if (showMenu) {
			showMenu = false;
			drawMenu = true;
		}
		if (hideMenu) {
			hideMenu = false;
			drawMenu = false;
		}

		ui.end();

		g.begin(false);
	}

	var lastT:iron.Trait = null;

	function parseMaterial() {
		UITrait.dirty = true;

		if (lastT != null) UITrait.currentObject.removeTrait(lastT);
		var t = armory.system.Logic.parse(canvas);
		lastT = t;
		UITrait.currentObject.addTrait(t);
	}
}
