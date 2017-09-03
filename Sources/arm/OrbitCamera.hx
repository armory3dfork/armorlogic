package arm;

import iron.math.Vec4;

class OrbitCamera extends armory.Trait {

	public static var enabled = false;

	public function new() {
		super();
		
		notifyOnUpdate(function() {
			if (iron.system.Input.occupied) return;
			if (!UITrait.uienabled) return;
			if (UITrait.isScrolling) return;

			var mouse = armory.system.Input.getMouse();

			if (mouse.x > arm.App.realw() - UITrait.ww) return;
			if (UINodes.show && mouse.x > UINodes.wx && mouse.x < UINodes.wx + UINodes.ww && mouse.y > UINodes.wy && mouse.y < UINodes.wy + UINodes.wh) return;

			var keyboard = armory.system.Input.getKeyboard();
			var camera = cast(object, iron.object.CameraObject);

			if (mouse.wheelDelta != 0) {
				UITrait.dirty = true;

				var p = camera.transform.loc;
				var d = Vec4.distance3df(p.x, p.y, p.z, 0, 0, 0);
				if ((mouse.wheelDelta > 0 && d < 10) ||
					(mouse.wheelDelta < 0 && d > 1)) {
					camera.move(camera.look(), mouse.wheelDelta * (-0.1));
				}
			}

			// if (mouse.down("middle") || (mouse.down("right") && keyboard.down("space"))) {
			// 	UITrait.dirty = true;

			// 	camera.transform.loc.addf(-mouse.movementX / 150, 0.0, mouse.movementY / 150);
			// 	camera.buildMatrix();
			// }
		});
	}
}
