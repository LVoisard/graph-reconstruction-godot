using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Godot;

namespace graph_rewriting_test.scripts.graph_lib
{
    [GlobalClass]
    public partial class GodotGraph : GodotObject
    {
        private List<int> idPool = new() { };

        private Graph graph = new();

        private int GetNextId()
        {
            if (idPool.Count > 0)
            {
                var id = idPool.First();
                idPool.RemoveAt(0);
                GD.Print($"Assigning Available id: {id}");
                return id;
            }
            else
            {
                GD.Print($"No Ids Available, assigning id: {graph.Vertices.Count}");
                return graph.Vertices.Count;
            }
        }

        public Vertex CreateVertex()
        {
            Vertex node = new Vertex(GetNextId(), Vertex.VertexType.Any);
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

        public Vertex[] GetVertices()
        {
            return graph.Vertices.ToArray();
        }

        public Edge GetEdge(int fromId, int toId)
        {
            return graph.Edges.Find(x => x.From.Id == fromId && x.To.Id == toId);
        }

        public Edge[] GetEdges()
        {
            return graph.Edges.ToArray();
        }

        public void RemoveVertexEdges(int id)
        {
            graph.Edges.RemoveAll(x => x.From.Id == id || x.To.Id == id);
        }

        public void RemoveVertex(int id)
        {
            RemoveVertexEdges(id);
            graph.Vertices.Remove(graph.Vertices.Find(x => x.Id == id));
            idPool.Add(id);
            idPool.Sort();
        }

        public void Clear()
        {
            idPool.Clear();
            graph.Clear();
        }

        /// <summary>
        /// Substitute inputgraph with outputgraph
        /// </summary>
        /// <param name="inputToTargetMapping"> input pattern vertices mapping to the target vertices </param>
        /// <param name="inputPattern"></param>
        /// <param name="outputPattern"></param>
        public void ApplyRewrite(Godot.Collections.Dictionary<Vertex, Vertex> inputToTargetMapping, GodotGraph inputPattern, GodotGraph outputPattern)
        {

            var externalEdges = graph.Edges.Where(e =>
                    (inputToTargetMapping.Values.Contains(e.From) && !inputToTargetMapping.Values.Contains(e.To)) ||
                    (inputToTargetMapping.Values.Contains(e.To) && !inputToTargetMapping.Values.Contains(e.From))).ToList();


            //create an input to output mapping
            Godot.Collections.Dictionary<Vertex, Vertex> outputToInputMapping = new();
            foreach (var v in outputPattern.graph.Vertices)
            {
                foreach (var v2 in inputPattern.graph.Vertices)
                {
                    if (v.Id == v2.Id)
                    {
                        outputToInputMapping.Add(v, v2);
                    }
                }
            }

            // 1. Remove matched vertices & edges
            foreach (var v in inputToTargetMapping.Values)
            {
                //target.RemoveVertexEdges(v.Id);
                RemoveVertex(v.Id);
            }

            // Create new vertices from the output
            Godot.Collections.Dictionary<Vertex, Vertex> outputToNewOutputMapping = new();
            Godot.Collections.Dictionary<Vertex, Vertex> targetToNewOutputMapping = new();
            foreach (var v in outputPattern.graph.Vertices)
            {
                Vertex newV = new Vertex(GetNextId(), v.X, v.Y, v.Type);
                // the type is not Any, then we need to change it.
                if (outputToInputMapping.ContainsKey(v))
                {
                    var original = inputToTargetMapping[outputToInputMapping[v]];
                    // we can now reference the new vertices from the original vertices
                    targetToNewOutputMapping.Add(original, newV);
                    if (v.Type == Vertex.VertexType.Any)
                    {
                        newV.SetType(original.Type);
                    }
                    newV.SetPosition(original.X, original.Y);
                }

                outputToNewOutputMapping.Add(v, newV);
                graph.AddVertex(newV);
            }

            // Create the output edges
            foreach (Edge edge in outputPattern.graph.Edges)
            {
                var e = CreateEdge(outputToNewOutputMapping[edge.From], outputToNewOutputMapping[edge.To]);
                e.SetType(edge.Type);
            }

            //Stitch back outside edges
            foreach (Edge edge in externalEdges)
            {
                var from = graph.Vertices.Contains(edge.From) ? edge.From : targetToNewOutputMapping[edge.From];
                var to = graph.Vertices.Contains(edge.To) ? edge.To : targetToNewOutputMapping[edge.To];
                var e = CreateEdge(from, to);
                e.SetType(edge.Type);
            }

        }

        public void ArrangeGrid(int spacing = 100)
        {
            int cols = (int)Math.Ceiling(Math.Sqrt(graph.Vertices.Count));
            int i = 0;
            foreach (var v in graph.Vertices)
            {
                int row = i / cols;
                int col = i % cols;
                v.SetPosition(col * spacing, row * spacing);
                i++;
            }
        }

        public void ArrangeForceDirected(int width = 800, int height = 600, int iterations = 10000)
        {
            double area = width * height;
            double k = Math.Sqrt(area / graph.Vertices.Count);
            Random rand = new Random();

            // Temporary floating point positions
            var pos = new Dictionary<Vertex, (double x, double y)>();

            // Initialize random positions
            foreach (var v in graph.Vertices)
                pos[v] = (rand.Next(width), rand.Next(height));

            for (int iter = 0; iter < iterations; iter++)
            {
                var disp = new Dictionary<Vertex, (double dx, double dy)>();

                foreach (var v in graph.Vertices)
                    disp[v] = (0, 0);

                // Repulsion
                foreach (var v in graph.Vertices)
                {
                    foreach (var u in graph.Vertices)
                    {
                        if (u == v) continue;
                        double dx = pos[v].x - pos[u].x;
                        double dy = pos[v].y - pos[u].y;
                        double dist = Math.Sqrt(dx * dx + dy * dy) + 0.01;
                        double force = (k * k) / dist;

                        disp[v] = (disp[v].dx + (dx / dist) * force,
                                   disp[v].dy + (dy / dist) * force);
                    }
                }

                // Attraction
                foreach (var e in graph.Edges)
                {
                    if (e.Type == Edge.EdgeType.Relational) continue; // allow relational overlap

                    double dx = pos[e.From].x - pos[e.To].x;
                    double dy = pos[e.From].y - pos[e.To].y;
                    double dist = Math.Sqrt(dx * dx + dy * dy) + 0.01;
                    double force = (dist * dist) / k;

                    disp[e.From] = (disp[e.From].dx - (dx / dist) * force,
                                    disp[e.From].dy - (dy / dist) * force);
                    disp[e.To] = (disp[e.To].dx + (dx / dist) * force,
                                    disp[e.To].dy + (dy / dist) * force);
                }

                // Update positions
                foreach (var v in graph.Vertices)
                {
                    double x = pos[v].x + disp[v].dx * 0.1;
                    double y = pos[v].y + disp[v].dy * 0.1;

                    pos[v] = (Math.Clamp(x, 0, width), Math.Clamp(y, 0, height));
                }
            }

            // Write back as integers
            foreach (var v in graph.Vertices)
            {
                v.SetPosition((int)Math.Round(pos[v].x), (int)Math.Round(pos[v].y));
            }
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

                    if (line.Contains("edges") || line.Contains("vertices")) continue;

                    string[] values = line.Split(",");
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

        public static GodotGraph[] ParseRuleFromString(string rule)
        {
            GodotGraph inputGraph = new();
            GodotGraph outputGraph = new();

            string inputString = "";
            string outputString = "";

            GD.Print(rule);

            using (StringReader reader = new StringReader(rule))
            {
                bool outputMode = false;
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    GD.Print(line);
                    if (string.IsNullOrEmpty(line)) continue;
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
                        outputString += line + "\n";
                    else
                        inputString += line + "\n";
                }
            }

            GD.Print("INPUT:" + inputString);
            GD.Print("OUTPUT:" + outputString);

            inputGraph.CreateFromString(inputString);
            outputGraph.CreateFromString(outputString);

            return [inputGraph, outputGraph];
        }
    }

}