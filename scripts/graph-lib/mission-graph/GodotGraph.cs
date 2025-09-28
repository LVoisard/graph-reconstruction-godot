using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Godot;

namespace GraphRewritingTest.Scripts.GraphLib.MissionGraph
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
                return id;
            }
            else
            {
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

        public Vertex[] GetVertexNeighbours(int id)
        {
            return graph.Edges.Where(x => x.From.Id == id || x.To.Id == id).Select(x => x.From.Id == id ? x.To : x.From).ToArray();
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

        public Vertex GetEntrance()
        {
            return graph.Vertices.First(x => x.Type == Vertex.VertexType.Entrance);
        }
        public Vertex GetGoal()
        {
            return graph.Vertices.First(x => x.Type == Vertex.VertexType.Goal);
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

        public void RemoveEdge(int from, int to)
        {
            var e = graph.Edges.Find(x => x.From.Id == from && x.To.Id == to);
            graph.Edges.Remove(e);
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
            Godot.Collections.Dictionary<Vertex, Vertex> inputToOutputMapping = new();
            foreach (var v in outputPattern.graph.Vertices)
            {
                foreach (var v2 in inputPattern.graph.Vertices)
                {
                    if (v.Id == v2.Id)
                    {
                        outputToInputMapping.Add(v, v2);
                        inputToOutputMapping.Add(v2, v);
                    }

                }
            }
            // make sure a vertex keeps its outer(inner) edge to other nodes. 
            // This happens when a rule specifies a node with no incoming edges.
            // The substitution removes the edges if it is from a node in the pattern.
            // We want to add it back after 


            // edge that exists in the target graph bewteen inputpattern vertices, but doesn't exist in the input graph, and that are not removed.

            // input that has an incoming from target but not in 
            List<Edge> edges = graph.Edges.Where(x =>
                inputToTargetMapping.Values.Contains(x.To) &&
                inputToTargetMapping.Values.Contains(x.From)).ToList();


            foreach (Edge e in edges)
            {
                // Find which pattern vertices this edge would correspond to
                var patternFrom = inputToTargetMapping.FirstOrDefault(kv => kv.Value == e.From).Key;
                var patternTo = inputToTargetMapping.FirstOrDefault(kv => kv.Value == e.To).Key;

                // Only proceed if both endpoints exist in the mapping
                if (patternFrom != null && patternTo != null)
                {
                    // Check if that edge exists in the input pattern
                    bool existsInPattern = inputPattern.GetEdges().Any(pe =>
                        pe.Type == e.Type && (
                            (pe.From == patternFrom && pe.To == patternTo) || // same direction
                            (pe.Type == Edge.EdgeType.Undirected && pe.From == patternTo && pe.To == patternFrom) // allow swap if undirected
                        ));

                    if (!existsInPattern)
                    {
                        GD.Print($"Extra edge in target (from {e.From.Id} to {e.To.Id}), not in input pattern → treat as external edge");
                        if (!externalEdges.Contains(e))
                            externalEdges.Add(e);
                    }
                }
            }

            //GD.Print(edges.Count);
            //externalEdges.AddRange(edges);


            // 1. Remove matched vertices & edges
            foreach (var v in inputToTargetMapping.Values)
            {
                //target.RemoveVertexEdges(v.Id);
                RemoveVertexEdges(v.Id);
            }

            // Create new vertices from the output
            Godot.Collections.Dictionary<Vertex, Vertex> outputToNewOutputMapping = new();
            Godot.Collections.Dictionary<Vertex, Vertex> targetToNewOutputMapping = new();
            foreach (var v in outputPattern.graph.Vertices)
            {
                Vertex newV;
                // if the output node is also in the input 
                if (outputToInputMapping.ContainsKey(v) && inputToTargetMapping.ContainsKey(outputToInputMapping[v]))
                {
                    newV = inputToTargetMapping[outputToInputMapping[v]];
                    // we can now reference the new vertices from the original vertices
                    targetToNewOutputMapping.Add(newV, newV);

                    if (v.Type != Vertex.VertexType.Any)
                    {
                        newV.SetType(v.Type);
                    }
                }
                else
                {
                    newV = new Vertex(GetNextId(), v.X, v.Y, v.Type);
                    graph.AddVertex(newV);
                }

                outputToNewOutputMapping.Add(v, newV);

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

        void SnapToGrid(int gridSize)
        {
            foreach (var v in graph.Vertices)
            {
                int newX = (int)Math.Round((double)v.X / gridSize) * gridSize;
                int newY = (int)Math.Round((double)v.Y / gridSize) * gridSize;

                v.SetPosition(newX, newY);
            }
        }

        void ResolveCollisions(int gridSize)
        {
            var occupied = new HashSet<(int, int)>();
            foreach (var v in graph.Vertices)
            {
                int gx = v.X / gridSize;
                int gy = v.Y / gridSize;
                var pos = (gx, gy);

                // If occupied, spiral out until we find a free cell
                int radius = 1;
                while (occupied.Contains(pos))
                {
                    gx += radius;
                    gy += radius;
                    pos = (gx, gy);
                    radius++;
                }

                occupied.Add(pos);
                v.SetPosition(gx * gridSize, gy * gridSize);
            }
        }

        public bool IsTraversable()
        {
            Vertex entrance, goal;
            if ((entrance = graph.Vertices.Find(x => x.Type == Vertex.VertexType.Entrance)) == null) return false;
            if ((goal = graph.Vertices.Find(x => x.Type == Vertex.VertexType.Goal)) == null) return false;

            Queue<Vertex> toExplore = new();
            HashSet<Vertex> visited = new();
            toExplore.Enqueue(entrance);
            visited.Add(entrance);
            while (toExplore.Count > 0)
            {
                Vertex current = toExplore.Dequeue();
                if (current.Type == Vertex.VertexType.Goal)
                {
                    GD.Print("Is traversable");
                    return true;
                }

                // add lock check

                var connected = graph.Edges.Where(x => x.From == current && x.Type == Edge.EdgeType.Directional).Select(x => x.To);
                foreach (var vert in connected)
                {
                    if (!visited.Contains(vert))
                    {
                        visited.Add(vert);
                        toExplore.Enqueue(vert);
                    }
                }
            }

            GD.Print("Not traversable");
            return false;
        }

        public bool HasOverlappingDirectionalEdges()
        {

            foreach (var vert in graph.Vertices)
            {
                foreach (var other in graph.Vertices)
                {
                    if (vert == other) continue;
                    if (vert.X == other.X && vert.Y == other.Y)
                    {
                        GD.Print($"vert {vert} and {other} are overlaping");
                        return true;
                    }
                }

            }

            // Compare only directional edges
            var directionalEdges = graph.Edges
                .Where(e => e.Type == Edge.EdgeType.Directional)
                .ToList();



            foreach (var edge in directionalEdges)
            {
                foreach (var other in directionalEdges)
                {
                    if (edge == other) continue;
                    Vector2 a, b, adir, c, d, cdir;
                    a = new Vector2(edge.From.X, edge.From.Y);
                    b = new Vector2(edge.To.X, edge.To.Y);
                    c = new Vector2(other.From.X, other.From.Y);
                    d = new Vector2(other.To.X, other.To.Y);
                    adir = b - a;
                    cdir = d - c;

                    Variant v = Geometry2D.SegmentIntersectsSegment(a + adir * 0.05f, b - adir * 0.05f, c + cdir * 0.05f, d - cdir * 0.05f);
                    if (v.VariantType != Variant.Type.Nil)
                    {
                        GD.Print($"Edge {edge} and {other} intersect");
                        return true;
                    }
                }

            }

            return false;
        }


        public void ArrangeGrid(int spacing, int offset)
        {
            Dictionary<Vertex, (int x, int y)> positions = new();
            HashSet<(int, int)> occupied = new();

            var start = GetEntrance();
            Queue<Vertex> q = new();
            positions[start] = (0, 0);
            occupied.Add((0, 0));
            q.Enqueue(start);

            while (q.Count > 0)
            {
                var current = q.Dequeue();
                var (cx, cy) = positions[current];

                var neighbors = graph.Edges
                    .Where(e => e.Type == Edge.EdgeType.Directional && (e.From == current || e.To == current))
                    .Select(e => e.From == current ? e.To : e.From);

                foreach (var n in neighbors)
                {
                    if (!positions.ContainsKey(n))
                    {
                        // choose an available grid direction
                        (int dx, int dy)[] dirs = { (1, 0), (-1, 0), (0, 1), (0, -1) };
                        foreach (var (dx, dy) in dirs)
                        {
                            var pos = (cx + dx, cy + dy);
                            if (!occupied.Contains(pos))
                            {
                                positions[n] = pos;
                                occupied.Add(pos);
                                q.Enqueue(n);
                                break;
                            }
                        }
                    }
                }
            }

            foreach (Vertex v in graph.Vertices)
            {
                v.SetPosition(positions[v].x * spacing + 400, positions[v].y * spacing + offset);
            }
        }

        public void ApplyLayeredLayout(bool topToBottom = true, int spacingX = 100, int spacingY = 100)
        {
            // Find the entrance
            Vertex entrance = graph.Vertices.FirstOrDefault(v => v.Type == Vertex.VertexType.Entrance);
            if (entrance == null) return;

            // Step 1: BFS to compute levels
            Dictionary<Vertex, int> levels = new();
            Queue<Vertex> queue = new();
            queue.Enqueue(entrance);
            levels[entrance] = 0;

            while (queue.Count > 0)
            {
                Vertex current = queue.Dequeue();
                int currentLevel = levels[current];

                // Traverse both directions (so we don’t miss parents/children)
                var neighbors = graph.Edges
                    .Where(e => (e.From == current || e.To == current) && e.Type == Edge.EdgeType.Directional)
                    .Select(e => e.From == current ? e.To : e.From);

                foreach (var n in neighbors)
                {
                    if (!levels.ContainsKey(n))
                    {
                        levels[n] = currentLevel + 1;
                        queue.Enqueue(n);
                    }
                }
            }

            // Step 2: Group nodes by level
            var grouped = levels.GroupBy(kvp => kvp.Value)
                                .OrderBy(g => g.Key)
                                .ToDictionary(g => g.Key, g => g.Select(x => x.Key).ToList());

            // Step 3: Assign positions
            foreach (var (level, nodes) in grouped)
            {
                for (int i = 0; i < nodes.Count; i++)
                {
                    if (topToBottom)
                    {
                        nodes[i].SetPosition(i * spacingX, level * spacingY);
                        //nodes[i].Y = level * spacingY;
                    }
                    else
                    {
                        nodes[i].SetPosition(level * spacingX, i * spacingY);
                    }
                }
            }
        }

        public void PlaceOnGrid(int width, int height)
        {
            var occupied = new bool[width, height];
            var queue = new Queue<(Vertex v, int x, int y)>();

            // Entrance at (0,0)
            var entrance = GetEntrance();
            entrance.SetPosition(0, 0);
            queue.Enqueue((entrance, 0, 0));
            occupied[0, 0] = true;

            while (queue.Count > 0)
            {
                var (current, cx, cy) = queue.Dequeue();

                var neighbors = graph.Edges
                    .Where(e => e.From == current)
                    .Select(e => e.To);

                int dirIndex = 0;
                foreach (var n in neighbors)
                {
                    // if (n.X != -1) continue; // already placed

                    // Try directions in order: right, down, left, up
                    var dirs = new (int dx, int dy)[] { (1, 0), (0, 1), (-1, 0), (0, -1) };
                    bool placed = false;

                    for (int i = 0; i < dirs.Length; i++)
                    {
                        int nx = cx + dirs[(dirIndex + i) % 4].dx;
                        int ny = cy + dirs[(dirIndex + i) % 4].dy;
                        if (nx >= 0 && nx < width && ny >= 0 && ny < height && !occupied[nx, ny])
                        {
                            n.SetPosition(nx * 100, ny * 100);
                            occupied[nx, ny] = true;
                            queue.Enqueue((n, nx, ny));
                            placed = true;
                            break;
                        }
                    }

                    if (!placed)
                    {
                        // fallback: expand search radius
                        for (int r = 2; !placed && r < Math.Max(width, height); r++)
                        {
                            for (int dx = -r; dx <= r; dx++)
                                for (int dy = -r; dy <= r; dy++)
                                {
                                    int nx = cx + dx, ny = cy + dy;
                                    if (nx >= 0 && nx < width && ny >= 0 && ny < height && !occupied[nx, ny])
                                    {
                                        n.SetPosition(nx * 100, ny * 100);
                                        occupied[nx, ny] = true;
                                        queue.Enqueue((n, nx, ny));
                                        placed = true;
                                        break;
                                    }
                                }
                        }
                    }
                }
            }
        }


        public void ArrangeBFS(bool horizontalLayout, int spacingPrimary, int spacingSecondary, int primaryOffset, int secondaryOffset)
        {
            Vertex entrance = graph.Vertices.Find(v => v.Type == Vertex.VertexType.Entrance);
            if (entrance == null) return;

            // BFS layering
            Queue<Vertex> queue = new();
            Dictionary<Vertex, int> levels = new();
            queue.Enqueue(entrance);
            levels[entrance] = 0;

            while (queue.Count > 0)
            {
                Vertex current = queue.Dequeue();
                int currentLevel = levels[current];

                var neighbors = graph.Edges
                    .Where(e => (e.From == current || e.To == current) && e.Type == Edge.EdgeType.Directional)
                    .Select(e => e.From == current ? e.To : e.From);

                foreach (var neighbor in neighbors)
                {
                    if (!levels.ContainsKey(neighbor))
                    {
                        levels[neighbor] = currentLevel + 1;
                        queue.Enqueue(neighbor);
                    }
                }
            }

            // Group vertices by level
            var grouped = levels.GroupBy(kvp => kvp.Value)
                                .OrderBy(g => g.Key);

            // Position nodes
            foreach (var group in grouped)
            {
                int level = group.Key;
                var vertsAtLevel = group.ToList();
                int count = vertsAtLevel.Count;
                int totalSpread = (count - 1) * spacingSecondary;

                for (int i = 0; i < count; i++)
                {
                    Vertex v = vertsAtLevel[i].Key;

                    if (!horizontalLayout)
                    {
                        // Primary axis = Y, Secondary axis = X
                        v.SetPosition(i * spacingSecondary - totalSpread / 2 + secondaryOffset, level * spacingPrimary + primaryOffset);
                    }
                    else
                    {
                        // Primary axis = X, Secondary axis = Y
                        v.SetPosition(level * spacingPrimary + primaryOffset, i * spacingSecondary - totalSpread / 2 + secondaryOffset);
                    }
                }
            }
        }

        public void ArrangeCustomBFS(bool horizontalLayout, int spacingPrimary, int spacingSecondary, int primaryOffset, int secondaryOffset)
        {
            Vertex entrance = graph.Vertices.Find(v => v.Type == Vertex.VertexType.Entrance);
            if (entrance == null) return;

            // BFS layering
            Queue<Vertex> queue = new();
            Dictionary<Vertex, int> levels = new();
            queue.Enqueue(entrance);
            levels[entrance] = 0;

            while (queue.Count > 0)
            {
                Vertex current = queue.Dequeue();
                int currentLevel = levels[current];

                var neighbors = graph.Edges
                    .Where(e => (e.From == current || e.To == current) && e.Type == Edge.EdgeType.Directional)
                    .Select(e => e.From == current ? e.To : e.From);

                foreach (var neighbor in neighbors)
                {
                    if (!levels.ContainsKey(neighbor))
                    {
                        levels[neighbor] = currentLevel + 1;
                        queue.Enqueue(neighbor);
                    }
                    else
                    {
                        levels[neighbor] = Math.Min(levels[neighbor], currentLevel + 1);
                    }
                }
            }

            int maxLevel = levels.Values.Max();
            int medianSweeps = 2;

            // 4) Build layers lists
            var layers = new Dictionary<int, List<Vertex>>();
            for (int i = 0; i <= maxLevel; i++) layers[i] = new List<Vertex>();
            foreach (var kv in levels) layers[kv.Value].Add(kv.Key);

            // 5) Sugiyama median heuristic - forward & backward sweeps
            Func<Vertex, List<Vertex>, double> parentMedian = (v, prevLayerList) =>
            {
                var indices = graph.Edges
                    .Where(e => e.To == v && levels[e.From] == levels[v] - 1)
                    .Select(e => prevLayerList.IndexOf(e.From))
                    .Where(idx => idx >= 0)
                    .OrderBy(i => i)
                    .ToList();
                if (indices.Count == 0) return double.PositiveInfinity;
                int mid = indices.Count / 2;
                if (indices.Count % 2 == 1) return indices[mid];
                return (indices[mid - 1] + indices[mid]) / 2.0;
            };

            Func<Vertex, List<Vertex>, double> childMedian = (v, nextLayerList) =>
            {
                var indices = graph.Edges
                    .Where(e => e.From == v && levels[e.To] == levels[v] + 1)
                    .Select(e => nextLayerList.IndexOf(e.To))
                    .Where(idx => idx >= 0)
                    .OrderBy(i => i)
                    .ToList();
                if (indices.Count == 0) return double.PositiveInfinity;
                int mid = indices.Count / 2;
                if (indices.Count % 2 == 1) return indices[mid];
                return (indices[mid - 1] + indices[mid]) / 2.0;
            };

            // Ensure some deterministic initial order (e.g., by Id)
            foreach (var layerIdx in layers.Keys)
                layers[layerIdx].Sort((a, b) => a.Id.CompareTo(b.Id));

            for (int sweep = 0; sweep < medianSweeps; sweep++)
            {
                // Forward sweep
                for (int l = 1; l <= maxLevel; l++)
                {
                    var prev = layers[l - 1];
                    var curList = layers[l];
                    // compute medians
                    var keyed = curList.Select(v => new { v, m = parentMedian(v, prev) }).ToList();
                    keyed.Sort((a, b) =>
                    {
                        int cmp = a.m.CompareTo(b.m);
                        if (cmp != 0) return cmp;
                        return a.v.Id.CompareTo(b.v.Id);
                    });
                    layers[l] = keyed.Select(x => x.v).ToList();
                }

                // Backward sweep
                for (int l = maxLevel - 1; l >= 0; l--)
                {
                    var next = layers[l + 1];
                    var curList = layers[l];
                    var keyed = curList.Select(v => new { v, m = childMedian(v, next) }).ToList();
                    keyed.Sort((a, b) =>
                    {
                        int cmp = a.m.CompareTo(b.m);
                        if (cmp != 0) return cmp;
                        return a.v.Id.CompareTo(b.v.Id);
                    });
                    layers[l] = keyed.Select(x => x.v).ToList();
                }
            }

            // 6) Assign coordinates
            foreach (var kv in layers)
            {
                int layerIdx = kv.Key;
                var verts = kv.Value;
                int count = verts.Count;
                if (count == 0) continue;
                int total = (count - 1) * spacingSecondary;

                for (int i = 0; i < count; i++)
                {
                    var v = verts[i];
                    if (!horizontalLayout)
                    {
                        int x = i * spacingSecondary - total / 2;
                        int y = layerIdx * spacingPrimary;
                        v.SetPosition(x + secondaryOffset, y + primaryOffset); // adapt to your setter
                    }
                    else // LeftToRight
                    {
                        int x = layerIdx * spacingPrimary;
                        int y = i * spacingSecondary - total / 2;
                        v.SetPosition(x + primaryOffset, y + secondaryOffset);
                    }
                }
            }

        }

        public void ArrangeForceDirected(int width = 800, int height = 600, int iterations = 10000, int k = 100, float temperature = 10)
        {
            Random rand = new();
            foreach (Vertex v in graph.Vertices)
            {
                //v.SetPosition(v.X + (rand.Next() % 50 - 25), v.Y + (rand.Next() % 50 - 25));
            }

            for (int iter = 0; iter < iterations; iter++)
            {
                // Temporary displacement arrays
                var dispX = new float[graph.Vertices.Count];
                var dispY = new float[graph.Vertices.Count];

                // Repulsive forces
                for (int i = 0; i < graph.Vertices.Count; i++)
                {
                    for (int j = i + 1; j < graph.Vertices.Count; j++)
                    {
                        Vertex nodeA = graph.Vertices[i];
                        Vertex nodeB = graph.Vertices[j];
                        if (nodeA == nodeB) continue;

                        var dx = nodeB.X - nodeA.X;
                        var dy = nodeB.Y - nodeA.Y;
                        var distSq = dx * dx + dy * dy;
                        var minDist = k + k;

                        if (distSq < minDist * minDist)
                        {
                            var dist = Math.Sqrt(distSq);
                            if (dist == 0) dist = 0.01; // avoid div by zero

                            float overlap = 0.5f * (float)(minDist - dist);
                            float nx = dx / (float)dist;
                            float ny = dy / (float)dist;

                            // push both nodes away from each other
                            dispX[i] -= nx * overlap;
                            dispY[i] -= ny * overlap;
                            dispX[j] += nx * overlap;
                            dispY[j] += ny * overlap;
                        }
                    }
                }

                // Attractive forces
                foreach (var e in graph.Edges)
                {
                    if (e.Type == Edge.EdgeType.Relational) continue;
                    int si = graph.Vertices.IndexOf(e.From);
                    int ti = graph.Vertices.IndexOf(e.To);

                    float dx = e.From.X - e.To.X;
                    float dy = e.From.Y - e.To.Y;
                    float distance = Math.Max(1e-4f, (float)Math.Sqrt(dx * dx + dy * dy));

                    float force = AttractiveForce(distance, k);

                    float fx = (dx / distance) * force;
                    float fy = (dy / distance) * force;

                    dispX[si] -= fx;
                    dispY[si] -= fy;
                    dispX[ti] += fx;
                    dispY[ti] += fy;
                }

                // Update positions
                for (int i = 0; i < graph.Vertices.Count; i++)
                {
                    float dx = dispX[i];
                    float dy = dispY[i];
                    float dispLength = Math.Max(1e-4f, (float)Math.Sqrt(dx * dx + dy * dy));

                    float step = Math.Min(dispLength, temperature);
                    int newX = (int)Math.Round(graph.Vertices[i].X + (dx / dispLength) * step);
                    int newY = (int)Math.Round(graph.Vertices[i].Y + (dy / dispLength) * step);

                    // Keep inside bounds
                    graph.Vertices[i].SetPosition(Math.Clamp(newX, 0, width), Math.Clamp(newY, 0, height));
                    //graph.Vertices[i].Y = ;
                }

                // Cool down
                temperature *= 0.95f;
            }
        }

        private float RepulsiveForce(float distance, float k) => (k * k) / distance;
        private float AttractiveForce(float distance, float k) => (distance * distance) / k;


        public string GetGraphString()
        {
            string s = "vertices\n";
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


            using (StringReader reader = new StringReader(rule))
            {
                bool outputMode = false;
                string line;
                while ((line = reader.ReadLine()) != null)
                {
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

            inputGraph.CreateFromString(inputString);
            outputGraph.CreateFromString(outputString);

            return [inputGraph, outputGraph];
        }
    }

}