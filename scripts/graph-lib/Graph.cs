using Godot;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Collections.ObjectModel;
using System.Linq;

namespace graph_rewriting_test.scripts.graph_lib
{
    public class Graph
    {
        public List<Vertex> Vertices { get; private set; } = new();
        public List<Edge> Edges { get; private set; } = new();

        public void AddVertex(Vertex vert)
        {
            Vertices.Add(vert);
        }

        public void AddEdge(Edge edge)
        {
            Edges.Add(edge);
        }

        public void Clear()
        {
            Vertices.Clear();
            Edges.Clear();
        }
    }
}

