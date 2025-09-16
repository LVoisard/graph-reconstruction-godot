using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	[GlobalClass]
	public partial class Edge: GodotObject
	{
		public Node From { get; init; }
		public Node To { get; init; }

		public Edge(Node from, Node to)
		{
			this.From = from;
			this.To = to;
		}
	}
}
