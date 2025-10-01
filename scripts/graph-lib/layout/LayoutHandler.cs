using System;
using System.Collections.Generic;
using Godot;

namespace GraphRewritingTest.Scripts.GraphLib.Layout
{
    [GlobalClass]
    /// <summary>
    /// The generator that tries to generate a map layout
    /// </summary>
    public partial class LayoutHandler : GodotObject
    {
        /// <summary>
        /// random variable for random selection
        /// </summary>
        private Random random;

        /// <summary>
        /// Constructor of the generator class for the map layout
        /// </summary>
        public LayoutHandler()
        {
            this.random = new Random();
        }

        /// <summary>
        /// Generate a map layout that correspond to the input mission graph
        /// </summary>
        /// <param name="graph">the mission graph that need to be mapped to a 2D layout</param>
        /// <returns>a 2D layout of the mission graph</returns>
        public Map GenerateDungeon(MissionGraph.GodotGraph graph)
        {
            Map result = new Map(this.random);
            result.initializeCell(graph.GetEntrance());
            #region  make initial dungeon
            List<Vertex> open = new List<Vertex>();
            Dictionary<Vertex, int> parentIDs = new Dictionary<Vertex, int>();
            foreach (Vertex child in graph.GetVertexNeighbours(graph.GetEntrance().Id))
            {
                open.Add(child);
                parentIDs.Add(child, 0);
            }
            HashSet<Vertex> nodes = new HashSet<Vertex>();
            nodes.Add(graph.GetEntrance());
            while (open.Count > 0)
            {
                Vertex current = open[0];
                open.RemoveAt(0);
                if (nodes.Contains(current))
                {
                    continue;
                }
                nodes.Add(current);
                if (!result.addCell(graph, current, parentIDs[current]))
                {
                    return null;
                }
                foreach (Vertex child in graph.GetVertexNeighbours(current.Id))
                {
                    if (!parentIDs.ContainsKey(child))
                    {
                        if (current.Type == Vertex.VertexType.Lock)
                        {
                            parentIDs.Add(child, current.Id);
                        }
                        else
                        {
                            parentIDs.Add(child, parentIDs[current]);
                        }
                    }
                    open.Add(child);
                }
            }
            #endregion

            #region make lever connections
            open.Clear();
            nodes.Clear();
            open.Add(graph.GetEntrance());
            while (open.Count > 0)
            {
                Vertex current = open[0];
                open.RemoveAt(0);
                if (nodes.Contains(current))
                {
                    continue;
                }
                nodes.Add(current);
                foreach (Vertex child in graph.GetVertexNeighbours(current.Id))
                {
                    Cell from = result.getCell(current.Id);
                    Cell to = result.getCell(child.Id);
                    // if (current.Type == Vertex.VertexType.Lever)
                    // {
                    //     if (!result.makeConnection(from, to, nodes.Count * nodes.Count))
                    //     {
                    //         return null;
                    //     }
                    // }
                    open.Add(child);
                }
            }
            #endregion
            return result;
        }
    }
}