using System;
using System.Collections.Generic;
using System.IO;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
    [GlobalClass]
    public partial class GodotGraph : GodotObject
    {
        private static int _nextId = 0;

        public Graph graph = new();

        public Vertex CreateVertex()
        {
            Vertex node = new Vertex(_nextId++, Vertex.VertexType.Any);
            graph.AddVertex(node);
            return node;
        }

        public Edge CreateEdge(Vertex from, Vertex to)
        {
            Edge edge = new Edge(from, to);
            graph.AddEdge(edge);
            return edge;
        }

        public Vertex GetVertex(int id)
        {
            return graph.Vertices.Find(x => x.Id == id);
        }

        public Edge GetEdge(int fromId, int toId)
        {
            return graph.Edges.Find(x => x.From.Id == fromId && x.To.Id == toId);
        }

        public void RemoveVertexEdges(int id)
        {
            graph.Edges.RemoveAll(x => x.From.Id == id || x.To.Id == id);
        }

        public void RemoveVertex(int id)
        {
            RemoveVertexEdges(id);
            graph.Vertices.Remove(graph.Vertices.Find(x => x.Id == id));
        }

        public string GetGraphString()
        {
            string s = "nodes\n";
            foreach (Vertex node in graph.Vertices)
            {
                s += node.ToString() + "\n";
            }
            s += "edges\n";
            foreach (Edge edge in graph.Edges)
            {
                s += edge.ToString() + "\n";
            }
            return s;
        }

        public void CreateFromString(string graph_string)
        {
            using (StringReader reader = new StringReader(graph_string))
            {
                string line;
                bool edges = false;
                while ((line = reader.ReadLine()) != null)
                {
                    if (line == "") continue;
                    if (line.Contains("edges")) edges = true;

                    string[] values = line.Split();
                    // vertices
                    if (!edges)
                    {
                        int id = int.Parse(values[0]);
                        int x = int.Parse(values[1]);
                        int y = int.Parse(values[2]);
                        Vertex.VertexType type = (Vertex.VertexType)Enum.Parse(typeof(Vertex.VertexType), values[3]);
                        graph.Vertices.Add(new Vertex(id, x, y, type));
                    }
                    // edges
                    else
                    {
                        int fromId = int.Parse(values[0]);
                        int toId = int.Parse(values[1]);
                        Edge.EdgeType type = (Edge.EdgeType)Enum.Parse(typeof(Edge.EdgeType), values[2]);
                        graph.Edges.Add(new Edge(GetVertex(fromId), GetVertex(toId), type));
                    }
                }
            }
        }

        public void Clear()
        {
            graph.Clear();
        }

        public static List<GodotGraph> ParseRuleFromString()
        {
            GodotGraph inputGraph = new();
            GodotGraph outputGraph = new();

            string inputString = "";
            string outputString = "";

            using (StringReader reader = new StringReader(""))
            {
                bool outputMode = false;
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    if (line.Contains("")) continue;
                    if (line.Contains("output"))
                    {
                        outputMode = true;
                        continue;
                    }
                    if (line.Contains("input"))
                    {
                        outputMode = false;
                        continue;
                    }

                    if (outputMode)
                        outputString += line;
                    else
                        inputString += line;
                }
            }

            inputGraph.CreateFromString(inputString);
            outputGraph.CreateFromString(outputString);

            return new() { inputGraph, outputGraph };
        }
    }

}