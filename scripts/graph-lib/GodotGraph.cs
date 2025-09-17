using System;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
    [GlobalClass]
    public partial class GodotGraph : GodotObject
    {
        private static int _nextId = 0;

        private Graph graph = new();


        public Vertex CreateVertex()
        {
            Vertex node = new Vertex(_nextId++, Vertex.NodeType.Any);
            graph.AddVertex(node);
            return node;
        }

        public Edge CreateEdge(Vertex from, Vertex to)
        {
            Edge edge = new Edge(from, to);
            graph.AddEdge(edge);
            return edge;
        }

        public string GetGraphString()
        {
            string s = "nodes\n";
            graph.Vertices.Add(new(0, 0));
            foreach (Vertex node in graph.Vertices)
            {
                s += $"{node.Id},{node.X},{node.Y},{Enum.GetValues(typeof(Vertex.NodeType)).GetValue((int)node.Type)}\n";
            }
            s += "edges\n";
            foreach (Edge edge in graph.Edges)
            {
                s += $"{edge.From.Id},{edge.To.Id},{Enum.GetValues(typeof(Edge.EdgeType)).GetValue((int)edge.Type)}\n";
            }
            return s;
        }

        public void Clear()
        {
            graph.Clear();
        }
    }
}