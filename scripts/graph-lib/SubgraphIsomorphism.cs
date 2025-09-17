using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

namespace graph_rewriting_test.scripts.graph_lib
{
    public partial class SubgraphIsomorphism : GodotObject
    {
        public static bool IsIsomorphicSubgraph(Graph source, Graph pattern)
        {
            return false;
        }

        public static List<Graph> FindAllIsomorphicSubgraphs(Graph source, Graph pattern)
        {
            return null;
        }

        private static bool matchFirst(Graph target, Graph pattern, Dictionary<Vertex, Vertex> mapping,
            HashSet<Vertex> usedTargetNodes)
        {
            if (mapping.Count == pattern.Vertices.Count)
                return true; // <-- stop at first found

            Vertex nextPatternNode = SelectUnmappedNode(pattern, mapping);

            foreach (Vertex targetNode in target.Vertices)
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

        private static void matchAll(Graph target, Graph pattern, Dictionary<Vertex, Vertex> mapping,
            HashSet<Graph> usedTargetNodes)
        {

        }

        static bool Compatible(Vertex pNode, Vertex tNode,
            Dictionary<Vertex, Vertex> mapping,
            Graph pattern, Graph target)
        {
            // (1) Check labels if applicable
            if (pNode.Type != tNode.Type)
                return false;

            // (2) Check edge consistency
            foreach (Edge e in pattern.Edges)
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

        static bool EdgeExists(Graph g, Vertex from, Vertex to)
        {
            return g.Edges.Any(e => e.From == from && e.To == to);
        }

        private static Vertex SelectUnmappedNode(Graph pattern, Dictionary<Vertex, Vertex> mapping)
        {
            return pattern.Vertices
                .Where(n => !mapping.ContainsKey(n))
                .OrderByDescending(n => Degree(pattern, n))
                .First();
        }

        static int Degree(Graph g, Vertex n)
        {
            return g.Edges.Count(e => e.From == n || e.To == n);
        }


    }
}
