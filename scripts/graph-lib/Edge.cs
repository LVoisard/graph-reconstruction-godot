using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	public partial class Edge : GodotObject
	{
		public Vertex From { get; private set; }
		public Vertex To { get; private set; }
		public EdgeType Type { get; private set; }

		public Edge(Vertex from, Vertex to)
		{
			this.From = from;
			this.To = to;
		}

		public void SetType(EdgeType type)
		{
			this.Type = type;
		}

		public enum EdgeType
		{
			Directional,
			Relational
		}
	}
}
