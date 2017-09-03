package arm;
import armory.system.Cycles;

typedef TNodeList = {
	var categories: Array<TCat>;
}

typedef TCat = {
	var name: String;
	var nodes: Array<TCatNode>;
}

typedef TCatNode = {
	var name: String;
	var type: String;
	var inputs: Array<TCatSocket>;
	var outputs: Array<TCatSocket>;
}

typedef TCatSocket = {
	var name: String;
	var type: String;
}

@:access(arm.UINodes)
class NodeCreator {
	
	public static var list:TNodeList;

	// public static var numNodes = [6, 1, 5, 5, 9];
	
	public static function draw(uinodes:UINodes, cat:String) {
		var ui = uinodes.ui;
		var getNodeX = uinodes.getNodeX;
		var getNodeY = uinodes.getNodeY;
		var nodes = UINodes.nodes;
		var canvas = UINodes.canvas;
		
		var c:TCat = null;
		for (category in list.categories) {
			if (category.name == cat) {
				c = category;
				break;
			}
		}
		for (cnode in c.nodes) {
			if (ui.button(cnode.name)) {
				var node_id = nodes.getNodeId(canvas.nodes);
				var n:TNode = {
					id: node_id,
					name: cnode.name,
					type: cnode.type,
					x: getNodeX(),
					y: getNodeY(),
					color: 0xffb34f5a,
					inputs: [],
					outputs: [],
					buttons: []
				};
				for (cinp in cnode.inputs) {
					var soc:TNodeSocket = {
						id: nodes.getSocketId(canvas.nodes),
						node_id: node_id,
						name: cinp.name,
						type: cinp.type,
						color: 0xffc7c729,
						default_value: 0.0
					};
					n.inputs.push(soc);
				}
				for (cout in cnode.outputs) {
					var soc:TNodeSocket = {
						id: nodes.getSocketId(canvas.nodes),
						node_id: node_id,
						name: cout.name,
						type: cout.type,
						color: 0xffc7c729,
						default_value: 0.0
					};
					n.outputs.push(soc);
				}
				canvas.nodes.push(n);
				nodes.nodeDrag = n;
				nodes.nodeSelected = n;
			}
		}
	}
}
