using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	public partial class Vertex : GodotObject
	{
		[Export] public int Id { get; private set; }
		[Export] public int X { get; private set; }
		[Export] public int Y { get; private set; }

		[Export] public VertexType Type { get; private set; }

		public Vertex(int id, VertexType type)
		{
			Id = id;
			Type = type;
			X = 0;
			Y = 0;
		}

		public Vertex(int id, int x, int y, VertexType type)
		{
			Id = id;
			Type = type;
			X = x;
			Y = y;
		}

		public void SetType(VertexType type)
		{
			this.Type = type;
		}

		public void SetPosition(int x, int y)
		{
			X = x;
			Y = y;
		}

		public void SetId(int id)
		{
			Id = id;
		}

		public override string ToString()
		{
			return $"{Id},{X},{Y},{Enum.GetValues(typeof(Vertex.VertexType)).GetValue((int)Type)}";
		}

		public enum VertexType
		{
			Entrance,
			Goal,
			Task,
			Key,
			Lock,
			Any,
		}
	}
}
