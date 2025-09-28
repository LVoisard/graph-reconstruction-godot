using Godot;
using System;
namespace GraphRewritingTest.Scripts.GraphLib.Layout
{
    public partial class Map : GodotObject
    {

        private int width, height;
        private Cell[,] grid;
        private Random random;

        public Map(int w, int h, Random rng)
        {
            width = w; height = h;
            grid = new Cell[w, h];
            random = rng;
        }

        public Cell GetCell(int x, int y)
        {
            if (x < 0 || x >= width || y < 0 || y >= height) return null;
            return grid[x, y];
        }

        public bool IsFree(int x, int y)
        {
            return GetCell(x, y) == null;
        }

        public Cell PlaceCell(int x, int y, Vertex node)
        {
            if (!IsFree(x, y)) return null;
            var cell = new Cell(x, y, node);
            grid[x, y] = cell;
            return cell;
        }

        public Cell FindParentCell(int parentId)
        {
            foreach (var c in grid)
            {
                if (c != null && c.Vert.Id == parentId)
                    return c;
            }
            return null;
        }

        // Try to add a cell next to its parent
        public bool AddCell(Vertex node, int parentId)
        {
            var parent = FindParentCell(parentId);
            if (parent == null) return false;

            // candidate directions
            var dirs = new (int dx, int dy, string label)[] {
                (0, 1, "North"),
                (0,-1, "South"),
                (1, 0, "East"),
                (-1,0, "West")
            };

            // shuffle directions to add variation
            for (int i = 0; i < dirs.Length; i++)
            {
                int j = random.Next(i, dirs.Length);
                (dirs[i], dirs[j]) = (dirs[j], dirs[i]);
            }

            foreach (var (dx, dy, label) in dirs)
            {
                int nx = parent.X + dx;
                int ny = parent.Y + dy;
                if (IsFree(nx, ny))
                {
                    var cell = PlaceCell(nx, ny, node);
                    if (cell != null)
                    {
                        // connect neighbors
                        parent.Neighbors[label] = cell;
                        string opposite = label switch
                        {
                            "North" => "South",
                            "South" => "North",
                            "East" => "West",
                            "West" => "East",
                            _ => ""
                        };
                        cell.Neighbors[opposite] = parent;
                        return true;
                    }
                }
            }
            return false; // no room
        }

        public void PrintAscii()
        {
            for (int y = height - 1; y >= 0; y--)
            {
                for (int x = 0; x < width; x++)
                {
                    var c = grid[x, y];
                    if (c == null) Console.Write(" . ");
                    else Console.Write(" " + c.Vert.Type.ToString()[0] + " ");
                }
                Console.WriteLine();
            }
        }
    }
}