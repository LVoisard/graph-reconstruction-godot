using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	[GlobalClass]
	public partial class Node : GodotObject
	{
		private static int _nextId = 0;
		public int Id { get; init; }

		public NodeType Type { get; init; }

		public Node()
		{
			this.Id = _nextId++;
			this.Type = NodeType.Task;
		}

		public Node(NodeType type)
		{
			this.Id = _nextId++;
			this.Type = type;
		}

		public Node(int id, NodeType type)
		{
			this.Id = id;
			this.Type = type;
		}

		public Node(Node other)
		{
			this.Id = other.Id;
			this.Type = other.Type;
		}
	}
}
