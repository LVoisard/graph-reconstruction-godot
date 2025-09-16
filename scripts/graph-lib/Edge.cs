using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	public partial class Edge : GodotObject
	{
		public Node From { get; private set; }
		public Node To { get; private set; }

		public void Init(Node from, Node to)
		{
			this.From = from;
			this.To = to;
		}
	}
}
