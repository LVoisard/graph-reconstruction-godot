using Godot;
using System.Collections.Generic;

namespace graph_rewriting_test.scripts.graph_lib
{
    [GlobalClass]
    public partial class Graph : Godot.Node
    {

        public List<Node> Nodes { get; init; } = new();
        public List<Edge> Edges { get; init; } = new();


        public void AddNode(Node node)
        {
            Nodes.Add(node);

        }

        public void AddEdge(Node from, Node to, bool isDirected = false)
        {
            Edges.Add(new Edge(from, to));
        }
    }
}

