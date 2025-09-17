using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	public partial class Vertex : GodotObject
	{
		[Export] public int Id { get; private set; }
		[Export] public int X { get; private set; }
		[Export] public int Y { get; private set; }

		[Export] public NodeType Type { get; private set; }

		public Vertex(int id, NodeType type)
		{
			Id = id;
			Type = type;
			X = 0;
			Y = 0;
		}

		public void SetType(NodeType type)
		{
			this.Type = type;
		}

		public void SetPosition(int x, int y)
		{
			X = x;
			Y = y;
		}

		public enum NodeType
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
