using Godot;
using GraphRewritingTest.Scripts.GraphLib.MissionGraph;

namespace GraphRewritingTest.Scripts.GraphLib.Layout
{
    [GlobalClass]
    /// <summary>
    /// The basic cell that construct the full map
    /// </summary>
    public partial class Cell : GodotObject
    {
        /// <summary>
        /// The mission graph corresponding node, only works if the cell type is normal
        /// </summary>
        public Vertex node
        {
            set;
            get;
        }
        /// <summary>
        /// The type of the cell that define if there is a corresponding mission graph node for the current cell or not
        /// </summary>
        public CellType Type
        {
            set;
            get;
        }
        /// <summary>
        /// The current x location of the cell
        /// </summary>
        public int x
        {
            set;
            get;
        }
        /// <summary>
        /// The current y location of the cell
        /// </summary>
        public int y
        {
            set;
            get;
        }
        /// <summary>
        /// The current parent cell that this cell was spawned from
        /// </summary>
        public Cell parent
        {
            set;
            get;
        }

        /// <summary>
        /// The four doors that spawns from that node
        /// </summary>
        private DoorType[] doorTypes;

        /// <summary>
        /// Constructor for the layout cell
        /// </summary>
        /// <param name="x">the current x</param>
        /// <param name="y">the current y</param>
        /// <param name="type">the cell type</param>
        /// <param name="node">the corresponding mission graph node</param>
        public Cell(int x, int y, CellType type, Vertex node)
        {
            this.x = x;
            this.y = y;
            this.Type = type;
            this.node = node;
            this.doorTypes = new DoorType[4];
            this.parent = null;
        }

        /// <summary>
        /// Create a copy of the current cell
        /// </summary>
        /// <returns>an exact copy of that cell</returns>
        public Cell clone()
        {
            Cell result = new Cell(this.x, this.y, this.Type, this.node);
            result.parent = this.parent;
            for (int i = 0; i < this.doorTypes.Length; i++)
            {
                result.doorTypes[i] = this.doorTypes[i];
            }
            return result;
        }

        /// <summary>
        /// transform direction vector to the correct index in the door array
        /// </summary>
        /// <param name="dirX">the x direction where -1 west and 1 east</param>
        /// <param name="dirY">the y direction where -1 north and 1 south</param>
        /// <returns>the index in the door array for the corresponding direction</returns>
        private int getDoorIndex(int dirX, int dirY)
        {
            if (dirX <= -1)
            {
                return 0;
            }
            if (dirX >= 1)
            {
                return 1;
            }
            if (dirY <= -1)
            {
                return 2;
            }
            if (dirY >= 1)
            {
                return 3;
            }
            return -1;
        }

        /// <summary>
        /// get the door type based on the input direction (east, west, north, south)
        /// </summary>
        /// <param name="dirX">the x direction where -1 west and 1 east</param>
        /// <param name="dirY">the y direction where -1 north and 1 south</param>
        /// <returns>the door type based on the direction</returns>
        public DoorType getDoor(int dirX, int dirY)
        {
            return this.doorTypes[this.getDoorIndex(dirX, dirY)];
            //return DoorType.Closed;
        }

        /// <summary>
        /// connect two cells together with a certain door type
        /// </summary>
        /// <param name="other">the other cell to be connect with</param>
        /// <param name="type">the type of door connection</param>
        /// <param name="bothWays">connect both cells</param>
        public void connectCells(Cell other, DoorType type, bool bothWays = true)
        {
            int dirX = this.x - other.x;
            int dirY = this.y - other.y;
            this.doorTypes[this.getDoorIndex(dirX, dirY)] = type;
            if (bothWays)
            {
                other.connectCells(this, type, false);
            }
        }

        /// <summary>
        /// Get a unique identifer based on the current location
        /// </summary>
        /// <returns>a string of the current location as "x,y"</returns>
        public string getLocationString()
        {
            return this.x + "," + this.y;
        }

        /// <summary>
        /// Draw the cell in a string correctly including the doors
        /// </summary>
        /// <returns>a string of how the room should look like in string rendering</returns>
        public override string ToString()
        {
            string result = "";
            char northDoor = '-';
            switch (this.doorTypes[3])
            {
                case DoorType.Open:
                    northDoor = ' ';
                    break;
                case DoorType.Locked:
                    northDoor = 'x';
                    break;
            }
            char southDoor = '-';
            switch (this.doorTypes[2])
            {
                case DoorType.Open:
                    southDoor = ' ';
                    break;
                case DoorType.Locked:
                    southDoor = 'x';
                    break;
            }
            char eastDoor = '|';
            switch (this.doorTypes[0])
            {
                case DoorType.Open:
                    eastDoor = ' ';
                    break;
                case DoorType.Locked:
                    eastDoor = 'x';
                    break;
            }
            char westDoor = '|';
            switch (this.doorTypes[1])
            {
                case DoorType.Open:
                    westDoor = ' ';
                    break;
                case DoorType.Locked:
                    westDoor = 'x';
                    break;
            }
            char roomType = 'C';
            if (this.Type == CellType.Normal)
            {
                roomType = (char)this.node.Type;
            }

            result += "+-" + northDoor + "-+" + "\n";
            result += "|   |" + "\n";
            result += westDoor + " " + roomType + " " + eastDoor + "\n";
            result += "|   |" + "\n";
            result += "+-" + southDoor + "-+";
            return result;
        }
    }
}