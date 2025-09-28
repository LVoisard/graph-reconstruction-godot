using Godot;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Collections.ObjectModel;
using System.Linq;

namespace GraphRewritingTest.Scripts.GraphLib.MissionGraph
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

