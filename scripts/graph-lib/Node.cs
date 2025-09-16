using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
	public partial class Node : GodotObject
	{
		private static int _nextId = 0;
		public int Id { get; private set; }

		public NodeType Type { get; private set; }

		public void Init()
		{
			this.Id = _nextId++;
			this.Type = NodeType.Task;
		}

		public void Init(NodeType type)
		{
			this.Id = _nextId++;
			this.Type = type;
		}

		public void Init(int id, NodeType type)
		{
			this.Id = id;
			this.Type = type;
		}

		public void Init(Node other)
		{
			this.Id = other.Id;
			this.Type = other.Type;
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
