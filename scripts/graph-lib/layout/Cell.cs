using Godot;
using Godot.Collections;
using System;

namespace GraphRewritingTest.Scripts.GraphLib.Layout
{
    public partial class Cell : GodotObject
    {
        public int X, Y;
        public Vertex Vert;
        public Dictionary<string, Cell> Neighbors = new();

        public Cell(int x, int y, Vertex vert)
        {
            X = x; Y = y; Vert = vert;
        }

        public override string ToString()
        {
            return $"Cell({X},{Y}) Node={Vert.Type}:{Vert.Id}";
        }
    }
}