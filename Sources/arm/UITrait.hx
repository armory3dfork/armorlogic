package arm;

import zui.*;
import zui.Zui.State;
import zui.Canvas;
import iron.data.SceneFormat;
import iron.data.MeshData;
import iron.object.MeshObject;

class UITrait extends armory.Trait {

	public static var uienabled = true;
	public static var isScrolling = false;

	public static var show = true;
	public static var dirty = true;

	var bundled:Map<String, kha.Image> = new Map();
	var ui:Zui;

	public static var ww = 200; // Panel width

	// function loadBundled(names:Array<String>, done:Void->Void) {
	// 	var loaded = 0;
	// 	for (s in names) {
	// 		kha.Assets.loadImage(s, function(image:kha.Image) {
	// 			bundled.set(s, image);
	// 			loaded++;
	// 			if (loaded == names.length) done();
	// 		});
	// 	}
	// }

	var font:kha.Font;
	public function new() {
		super();

		armory.system.Cycles.arm_export_tangents = false;

		iron.data.Data.getFont('droid_sans.ttf', function(f:kha.Font) {
			font = f;
			zui.Themes.dark.FILL_WINDOW_BG = true;
			ui = new Zui( { font: font } );

			done();
		});
	}

	public static var currentObject:MeshObject;

	function done() {

		iron.Scene.active.notifyOnInit(function() {

			currentObject = cast(iron.Scene.active.getChild("Cube"), MeshObject);

			iron.App.notifyOnUpdate(update);
			iron.App.notifyOnRender2D(render2D);
		});
	}

	function update() {
		isScrolling = ui.isScrolling;
		// updateUI();
	}

	function updateUI() {
		var mouse = iron.system.Input.getMouse();
		// if (mouse.started() && mouse.x < 50 && mouse.y < 50) show = !show;

		if (!show) return;
		if (!UITrait.uienabled) return;
	}

	var redraws = 0;
	var lastW = 0;
	var lastH = 0;
	function render2D(g:kha.graphics2.Graphics) {

		// renderUI(g);

		if (lastW > 0 && (lastW != arm.App.realw() || lastH != arm.App.realh())) {
			resize();
		}
		lastW = arm.App.realw();
		lastH = arm.App.realh();

		if(dirty) redraws = 2;

		// iron.Scene.active.camera.renderPath.ready = redraws > 0;
		redraws--;
		dirty = false;
	}

	function resize() {
		UINodes.calcLayout();
		UINodes.grid.unload();
		UINodes.grid = null;
		UITrait.dirty = true;
		iron.Scene.active.camera.buildProjection();
	}

	var hwnd = Id.handle();
	function renderUI(g:kha.graphics2.Graphics) {
		if (!show) return;

		if (!UITrait.uienabled && ui.inputRegistered) ui.unregisterInput();
		if (UITrait.uienabled && !ui.inputRegistered) ui.registerInput();

		g.color = 0xffffffff;

		g.end();
		ui.begin(g);
		// ui.begin(rt.g2); ////
		
		if (ui.window(hwnd, arm.App.realw() - ww, 0, ww, arm.App.realh())) {

			var htab = Id.handle({position: 0});

			if (ui.tab(htab, "Project")) {

				var hlayout = Id.handle({position: arm.App.layout});
				arm.App.layout = ui.combo(hlayout, ["Horizontal", "Vertical"], "Layout", true);
				if (hlayout.changed) resize();

				ui.button("Stop");
			}
		}
		ui.end();
		g.begin(false);
	}
}
