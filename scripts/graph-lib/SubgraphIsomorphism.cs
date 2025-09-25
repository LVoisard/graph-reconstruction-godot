using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

namespace graph_rewriting_test.scripts.graph_lib
{
    [GlobalClass]
    public partial class SubgraphIsomorphism : GodotObject
    {
        public static Godot.Collections.Dictionary<Vertex, Vertex> FindFirst(GodotGraph pattern, GodotGraph target)
        {
            var mapping = new Dictionary<Vertex, Vertex>();
            var usedTargetVertices = new HashSet<Vertex>();
            Godot.Collections.Dictionary<Vertex, Vertex> result = null;

            bool Backtrack(int patternIndex)
            {
                if (patternIndex == pattern.GetVertices().Length)
                {
                    // Found a full mapping
                    result = new Godot.Collections.Dictionary<Vertex, Vertex>(mapping);
                    return true;
                }

                var patternVertex = pattern.GetVertices()[patternIndex];

                foreach (var candidate in target.GetVertices())
                {
                    if (usedTargetVertices.Contains(candidate))
                        continue;

                    if (IsFeasibleMapping(pattern, target, mapping, patternVertex, candidate))
                    {
                        mapping[patternVertex] = candidate;
                        usedTargetVertices.Add(candidate);

                        if (Backtrack(patternIndex + 1))
                            return true; // stop on first solution

                        mapping.Remove(patternVertex);
                        usedTargetVertices.Remove(candidate);
                    }
                }
                return false;
            }
            Backtrack(0);
            return result;
        }

        public static Godot.Collections.Array<Godot.Collections.Dictionary<Vertex, Vertex>> FindAll(GodotGraph pattern, GodotGraph target)
        {
            var results = new Godot.Collections.Array<Godot.Collections.Dictionary<Vertex, Vertex>>();
            var mapping = new Dictionary<Vertex, Vertex>();
            var usedTargetVertices = new HashSet<Vertex>();

            void Backtrack(int patternIndex)
            {
                if (patternIndex == pattern.GetVertices().Length)
                {

                    results.Add(new Godot.Collections.Dictionary<Vertex, Vertex>(mapping));
                    return;
                }

                var patternVertex = pattern.GetVertices()[patternIndex];

                foreach (var candidate in target.GetVertices())
                {
                    if (usedTargetVertices.Contains(candidate))
                        continue;

                    if (IsFeasibleMapping(pattern, target, mapping, patternVertex, candidate))
                    {
                        mapping[patternVertex] = candidate;
                        usedTargetVertices.Add(candidate);

                        Backtrack(patternIndex + 1);

                        mapping.Remove(patternVertex);
                        usedTargetVertices.Remove(candidate);
                    }
                }
            }

            Backtrack(0);
            return results;
        }

        private static bool IsFeasibleMapping(GodotGraph pattern, GodotGraph target, Dictionary<Vertex, Vertex> mapping, Vertex patternVertex, Vertex targetVertex)
        {
            if ((patternVertex.Type != Vertex.VertexType.Any && patternVertex.Type != targetVertex.Type) || // if the nodes are the same,
                patternVertex.Type == Vertex.VertexType.Any && targetVertex.Type == Vertex.VertexType.Empty)      // or if the target node is greater than Any (empty, unused)
            {
                return false;
            }

            // 2. Check edges consistency with already mapped neighbors
            foreach (var edge in pattern.GetEdges())
            {
                if (edge.Type == Edge.EdgeType.Undirected)
                {
                    if (edge.From == patternVertex && mapping.ContainsKey(edge.To))
                    {
                        var mappedFrom = targetVertex;
                        var mappedTo = mapping[edge.To];

                        var match = target.GetEdges().FirstOrDefault(e => e.Type == Edge.EdgeType.Undirected &&
                            ((e.From == mappedFrom && e.To == mappedTo) ||
                            (e.From == mappedTo && e.To == mappedFrom)));

                        if (match == null)
                            return false;


                    }

                    if (edge.To == patternVertex && mapping.ContainsKey(edge.From))
                    {
                        var mappedFrom = mapping[edge.From];
                        var mappedTo = targetVertex;

                        var match = target.GetEdges().FirstOrDefault(e => e.Type == Edge.EdgeType.Undirected &&
                            ((e.From == mappedFrom && e.To == mappedTo) ||
                            (e.From == mappedTo && e.To == mappedFrom)));

                        if (match == null)
                            return false;
                    }
                }
                else
                {
                    if (edge.From == patternVertex && mapping.ContainsKey(edge.To))
                    {
                        var mappedFrom = targetVertex;
                        var mappedTo = mapping[edge.To];

                        if (!target.GetEdges().Any(e =>
                            e.From == mappedFrom &&
                            e.To == mappedTo &&
                            e.Type == edge.Type)) // edge type must match
                        {
                            return false;
                        }
                    }

                    if (edge.To == patternVertex && mapping.ContainsKey(edge.From))
                    {
                        var mappedFrom = mapping[edge.From];
                        var mappedTo = targetVertex;

                        if (!target.GetEdges().Any(e =>
                            e.From == mappedFrom &&
                            e.To == mappedTo &&
                            e.Type == edge.Type)) // edge type must match
                        {
                            return false;
                        }
                    }
                }
            }

            return true;
        }


    }
}
