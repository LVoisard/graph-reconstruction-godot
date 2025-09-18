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
            // Check edges consistency with already mapped neighbors
            foreach (var edge in pattern.GetEdges())
            {
                if (edge.From == patternVertex && mapping.ContainsKey(edge.To))
                {
                    var mappedFrom = targetVertex;
                    var mappedTo = mapping[edge.To];
                    if (!target.GetEdges().Any(e => e.From == mappedFrom && e.To == mappedTo))
                        return false;
                }

                if (edge.To == patternVertex && mapping.ContainsKey(edge.From))
                {
                    var mappedFrom = mapping[edge.From];
                    var mappedTo = targetVertex;
                    if (!target.GetEdges().Any(e => e.From == mappedFrom && e.To == mappedTo))
                        return false;
                }
            }

            return true;
        }

        private static bool compatible(Vertex v1, Vertex v2, Vertex v3, Dictionary<Vertex, Vertex> mapping)
        {
            return v1 == v3 && mapping.ContainsKey(v2) && (v3.Type == v1.Type || v3.Type == Vertex.VertexType.Any);
        }


    }
}
