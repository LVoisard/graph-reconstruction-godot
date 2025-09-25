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
			this.Type = EdgeType.Directional;
		}

		public Edge(Vertex from, Vertex to, EdgeType type)
		{
			this.From = from;
			this.To = to;
			this.Type = type;
		}

		public void SetType(EdgeType type)
		{
			this.Type = type;
		}
		public override string ToString()
		{
			return $"{From.Id},{To.Id},{Enum.GetValues(typeof(EdgeType)).GetValue((int)Type)}";
		}

		public enum EdgeType
		{
			Directional,
			Relational,
			Undirected
		}
	}
}
