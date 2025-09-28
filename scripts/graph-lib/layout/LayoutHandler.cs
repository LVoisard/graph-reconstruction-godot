using Godot;
using System;
using System.Collections.Generic;
using Queue = System.Collections.Generic.Queue<GraphRewritingTest.Scripts.GraphLib.Vertex>;
using Godot.Collections;

using GraphRewritingTest.Scripts.GraphLib.MissionGraph;
namespace GraphRewritingTest.Scripts.GraphLib.Layout
{
    [GlobalClass]
    public partial class LayoutHandler : GodotObject
    {
        private Map map;
        private Random random;

        public LayoutHandler()
        {
            var rng = new Random();
            map = new Map(mapWidth, mapHeight, rng);
            random = rng;
        }

        public Map BuildLayout(GodotGraph graph)
        {
            // 1. place start node in the middle
            int cx = mapWidth / 2;
            int cy = mapHeight / 2;
            map.PlaceCell(cx, cy, graph.GetEntrance());

            // 2. BFS expansion
            Queue open = new();
            Godot.Collections.Dictionary<Vertex, int> parentIDs = new();

            foreach (var child in graph.GetVertexNeighbours(graph.GetEntrance().Id))
            {
                open.Enqueue(child);
                parentIDs[child] = graph.GetEntrance().Id;
            }

            HashSet<Vertex> visited = new() { graph.GetEntrance() };

            while (open.Count > 0)
            {
                var current = open.Dequeue();
                if (visited.Contains(current)) continue;
                visited.Add(current);

                if (!map.AddCell(current, parentIDs[current]))
                    return null; // fail, no space

                foreach (var child in graph.GetVertexNeighbours(current.Id))
                {
                    if (!parentIDs.ContainsKey(child))
                    {
                        if (current.Type == Vertex.VertexType.Lock)
                            parentIDs[child] = current.Id;
                        else
                            parentIDs[child] = parentIDs[current];
                    }
                    open.Enqueue(child);
                }
            }

            // 3. Handle levers (optional)

            return map;
        }

        private int mapWidth => 20;
        private int mapHeight => 20;
    }
}

