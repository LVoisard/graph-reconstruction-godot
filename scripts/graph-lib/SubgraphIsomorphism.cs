using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

namespace graph_rewriting_test.scripts.graph_lib
{
    [GlobalClass]
    public partial class SubgraphIsomorphism : GodotObject
    {
        public bool IsIsomorphicSubgraph(GodotGraph source, GodotGraph pattern)
        {
            Dictionary<Vertex, Vertex> mapping = new();
            HashSet<Vertex> used = new();
            return matchFirst(source, pattern, mapping, used);
        }

        public GodotGraph[] FindAllIsomorphicSubgraphs(GodotGraph source, GodotGraph pattern)
        {
            return null;
        }

        private bool matchFirst(GodotGraph target, GodotGraph pattern, Dictionary<Vertex, Vertex> mapping,
            HashSet<Vertex> usedTargetNodes)
        {
            if (mapping.Count == pattern.graph.Vertices.Count)
                return true; // <-- stop at first found

            Vertex nextPatternNode = SelectUnmappedNode(pattern, mapping);

            foreach (Vertex targetNode in target.graph.Vertices)
            {
                if (usedTargetNodes.Contains(targetNode))
                    continue;

                if (Compatible(nextPatternNode, targetNode, mapping, pattern, target))
                {
                    mapping[nextPatternNode] = targetNode;
                    usedTargetNodes.Add(targetNode);

                    if (matchFirst(pattern, target, mapping, usedTargetNodes))
                        return true; // <-- propagate success immediately

                    mapping.Remove(nextPatternNode);
                    usedTargetNodes.Remove(targetNode);
                }
            }

            return false;
        }

        private void matchAll(GodotGraph target, GodotGraph pattern, Dictionary<Vertex, Vertex> mapping,
            HashSet<Vertex> usedTargetNodes)
        {

        }

        private bool Compatible(Vertex pNode, Vertex tNode,
            Dictionary<Vertex, Vertex> mapping,
            GodotGraph pattern, GodotGraph target)
        {
            // (1) Check labels if applicable
            if (pNode.Type != tNode.Type)
                return false;

            // (2) Check edge consistency
            foreach (Edge e in pattern.graph.Edges)
            {
                if (e.From == pNode && mapping.ContainsKey(e.To))
                {
                    Vertex mappedTo = mapping[e.To];
                    if (!EdgeExists(target, tNode, mappedTo))
                        return false;
                }

                if (e.To == pNode && mapping.ContainsKey(e.From))
                {
                    Vertex mappedFrom = mapping[e.From];
                    if (!EdgeExists(target, mappedFrom, tNode))
                        return false;
                }
            }

            return true;
        }

        private bool EdgeExists(GodotGraph g, Vertex from, Vertex to)
        {
            return g.graph.Edges.Any(e => e.From == from && e.To == to);
        }

        private Vertex SelectUnmappedNode(GodotGraph pattern, Dictionary<Vertex, Vertex> mapping)
        {
            return pattern.graph.Vertices
                .Where(n => !mapping.ContainsKey(n))
                .OrderByDescending(n => Degree(pattern, n))
                .First();
        }

        private int Degree(GodotGraph g, Vertex n)
        {
            return g.graph.Edges.Count(e => e.From == n || e.To == n);
        }


    }
}
