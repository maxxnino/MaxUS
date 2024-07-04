using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { MaxExtension }
using { MaxMath }
using { MaxDataStucture }

debug_draw_generate_room := class(debug_draw_channel){}
log_generate_room := class(log_channel){}
my_test_tag := class(tag){}
generatable_prop := module:
    set1<public> := class(tag){}
    set1_floor<public> := class(set1){}
    set1_roof<public> := class(set1){}
    set1_door<public> := class(set1){}
    set1_wall<public> := class(set1){}

    set2 := class(tag){}
    set2_floor<public> := class(set2){}
    set2_roof<public> := class(set2){}
    set2_door<public> := class(set2){}
    set2_wall<public> := class(set2){}


    set3 := class(tag){}
    set3_floor<public> := class(set3){}
    set3_roof<public> := class(set3){}
    set3_door<public> := class(set3){}
    set3_wall<public> := class(set3){}

    set4 := class(tag){}
    set4_floor := class(set4){}
    set4_roof := class(set4){}
    set4_door := class(set4){}
    set4_wall := class(set4){}

    set5 := class(tag){}
    set5_floor := class(set5){}
    set5_roof := class(set5){}
    set5_door := class(set5){}
    set5_wall := class(set5){}

    set6 := class(tag){}
    set6_floor := class(set6){}
    set6_roof := class(set6){}
    set6_door := class(set6){}
    set6_wall := class(set6){}

    set7 := class(tag){}
    set7_floor := class(set7){}
    set7_roof := class(set7){}
    set7_door := class(set7){}
    set7_wall := class(set7){}

room_generation_device := class(creative_device):
    GridInfomation:grid_infomation = grid_infomation{}
    GridWidth:float = 512.0
    GridHeight:float = 384.0

    @editable
    MoveTime : float = 2.0
    

    # @editable{ToolTip := "asdfsdfsdf", Categories := "sdfsdfsdf"}
    @editable
    WallHeigth:int = 1

    @editable
    MaxRoomTile:int = 16
    @editable
    MinRoomTile:int = 6
    @editable
    RoomPadding:int = 2
    @editable
    CoverAtLeast:float = 0.5
    var CoverAtLeastInTile:int = 0

    @editable
    Button:button_device = button_device{}

    var CreativeProp: []creative_prop = array{}
    var IsShow: logic = true

    var GridX:int = 0
    var GridY:int = 0
    var AnkerPoint:vector3 = vector3{}
    var Floors:[]creative_object = array{}
    var GeneratedProps:[]creative_prop = array{}
    var RoomsProp: []room_prop = array{}
    RoomTags:[]room_tag := array{
        room_tag{
            WallTag:= generatable_prop.set1{}, FloorTag:= generatable_prop.set1_floor{}, 
            RoofTag:= generatable_prop.set1_roof{}, DoorTag:= generatable_prop.set1_door{}
        },
        room_tag{
            WallTag:= generatable_prop.set2_wall{}, FloorTag:= generatable_prop.set2_floor{}, 
            RoofTag:= generatable_prop.set2_roof{}, DoorTag:= generatable_prop.set2_door{}
        }
    }

    DebugDraw:debug_draw = debug_draw{Channel := debug_draw_generate_room}
    Logger:log = log{Channel := log_generate_room}
    
    OnBegin<override>()<suspends>:void=
        Generate()

    Generate():void=
        set AnkerPoint = GridInfomation.FirstPoint.GetTransform().Translation
        Point2 := GridInfomation.SecondPoint.GetTransform().Translation
        Width := Abs(AnkerPoint.X - Point2.X)
        Height := Abs(AnkerPoint.Y - Point2.Y)
        # DebugDraw.DrawBox(AnkerPoint, Point2)
        
        if:
            ComputeX := Int[Width / GridWidth]
            ComputeY := Int[Height / GridWidth]
            set GridX = ComputeX
            set GridY = ComputeY
            ComputeCoverAtLeastTile := Int[(GridX + 1) * (GridY + 1) * CoverAtLeast]
            set CoverAtLeastInTile = ComputeCoverAtLeastTile
        then:
            CollectProps()
            # GenerateFloor()
            # GenerateWall(vector2i{X := 0, Y := 0}, vector2i{X := GridX, Y := GridY}, WallHeigth, ?Left := true, ?Right := true, ?Top := true, ?Bottom := true)
            Button.InteractedWithEvent.Subscribe(SplitRoom)

    CollectProps():void=
        for(Tag:RoomTags):
            set RoomsProp += array{CreateRoomPropsWithTag(Tag)}

    # GenerateFloor():void=
    #     for(X := 0..GridX, Y := 0..GridY):
    #         if (Prop := FloorProps.Sample[]):
    #             SpawnProp(Prop, transform{
    #                 Translation := AnkerPoint + vector3{X := X * GridWidth, Y := SnapLeft(Y)}
    #             })

    PutWall(Props: []creative_prop, StartGrid:vector2i, EndGrid:vector2i, GridZ:int)<suspends>:void=
        Dimension := EndGrid - StartGrid
        Total:= (Dimension.X + 1) * (Dimension.Y + 1) * GridZ + 4
        if (UsedProp := Props.Sample[Total]):
            var Index:int = 0
            for(Y := StartGrid.Y..EndGrid.Y, Z := 0..GridZ-1):
                if (Wall := UsedProp[Index]):
                    Translation:= AnkerPoint + vector3{X := StartGrid.X * GridWidth, Y := Y * GridWidth, Z := Z * GridHeight}
                    Rotation:= IdentityRotation().ApplyYaw(DegreesToRadians(-90.0))
                    Print("Wall Y:{Y} - I:{Index}")
                    Wall.Hide()
                    if (Wall.TeleportTo[Translation, Rotation]):
                        Wall.Show()
                        set Index += 1
                    else:
                        Print("Telefail Wall: {Index}")

                if (Wall := UsedProp[Index]):
                    Translation := AnkerPoint + vector3{X := EndGrid.X * GridWidth, Y := Y * GridWidth, Z := Z * GridHeight}
                    Rotation := IdentityRotation().ApplyYaw(DegreesToRadians(90.0))
                    Print("Wall Y2:{Y} - I:{Index}")
                    Wall.Hide()
                    if (Wall.TeleportTo[Translation, Rotation]):
                        Wall.Show()
                        set Index += 1
                    else:
                        Print("Telefail Wall: {Index}")

            for(X := StartGrid.X..EndGrid.X, Z := 0..GridZ-1):
                if (Wall := UsedProp[Index]):
                    Translation := AnkerPoint + vector3{X := X * GridWidth, Y := StartGrid.Y * GridWidth, Z := Z * GridHeight}
                    Rotation := IdentityRotation()
                    Print("Wall X:{X} - I:{Index}")
                    Wall.Hide()
                    if (Wall.TeleportTo[Translation, Rotation]):
                        Wall.Show()
                        set Index += 1
                    else:
                        Print("Telefail Wall: {Index}")

                if (Wall := UsedProp[Index]):
                    Translation := AnkerPoint + vector3{X := X * GridWidth, Y := EndGrid.Y * GridWidth, Z := Z * GridHeight}
                    Rotation := IdentityRotation().ApplyYaw(DegreesToRadians(-180.0))
                    Print("Wall X2:{X} - I:{Index}")
                    Wall.Hide()
                    if (Wall.TeleportTo[Translation, Rotation]):
                        Wall.Show()
                        set Index += 1
                    else:
                        Print("Telefail Wall: {Index}")
        
    PutFloor(Props:[]creative_prop, StartGrid:vector2i, EndGrid:vector2i, GridZ:int)<suspends>:void=
        Dimension := EndGrid - StartGrid
        Total:= (Dimension.X + 1) * (Dimension.Y + 1) * GridZ
        var Index: int = 0
        Rotation:= IdentityRotation()
        for:
            X := StartGrid.X..EndGrid.X
            Y := StartGrid.Y..EndGrid.Y
            Z := 0..GridZ-1
            Prop := Props[Index]
        do:
            Translation:= AnkerPoint + vector3{X := X * GridWidth, Y := Y * GridWidth, Z := Z * GridHeight}
            Print("X: {X} - Y: {Y}, Z: {Z}, Index: {Index}, T: {Translation}")
            Prop.Hide()
            if (Prop.TeleportTo[Translation, Rotation]):
                Prop.Show()
                set Index += 1
            else:
                Print("Telefail Floor: {Index}")


    SplitRoom(Agent:agent):void=
        rect_queue := queue(rect)
        var Queue:rect_queue = CreateQueue(array{MakeRect(0, 0, GridX, GridY)})
        var Leaf_Rects:[]rect = array{}
        loop:
            if (Tuple := Queue.Dequeue[], set Queue = Tuple(0), Rect := Tuple(1)):
                SplitDirection := GetSplitDirection(Rect)
                LowerBoundMin := Rect.LowerBound + vector2i{X := RoomPadding, Y := RoomPadding}
                UpperBoundMax := Rect.UpperBound - vector2i{X := RoomPadding, Y := RoomPadding}
                case (SplitDirection):
                    split_direction.Horizontal =>
                        SplitPostion := GetRandomInt(LowerBoundMin.X, UpperBoundMax.X)
                        Left := MakeRect(Rect.LowerBound.X, Rect.LowerBound.Y, SplitPostion - 1, Rect.UpperBound.Y)
                        Right := MakeRect(SplitPostion + 1, Rect.LowerBound.Y, Rect.UpperBound.X, Rect.UpperBound.Y)
                        LeftA := Left.Tiles()
                        RightA := Right.Tiles()
                        if(LeftA > MaxRoomTile):
                            set Queue = Queue.Enqueue(Left)
                        else if(LeftA >= MinRoomTile):
                            set Leaf_Rects += array{Left}
                        if(RightA > MaxRoomTile):
                            set Queue = Queue.Enqueue(Right)
                        else if(RightA >= MinRoomTile):
                            set Leaf_Rects += array{Right}

                    split_direction.Vertical =>
                        SplitPostion := GetRandomInt(LowerBoundMin.Y, UpperBoundMax.Y)
                        Left := MakeRect(Rect.LowerBound.X, Rect.LowerBound.Y, Rect.UpperBound.X, SplitPostion - 1)
                        Right := MakeRect(Rect.LowerBound.X, SplitPostion + 1, Rect.UpperBound.X, Rect.UpperBound.Y)
                        LeftA := Left.Tiles()
                        RightA := Right.Tiles()
                        if(LeftA > MaxRoomTile):
                            set Queue = Queue.Enqueue(Left)
                        else if(LeftA >= MinRoomTile):
                            set Leaf_Rects += array{Left}
                        if(RightA > MaxRoomTile):
                            set Queue = Queue.Enqueue(Right)
                        else if(RightA >= MinRoomTile):
                            set Leaf_Rects += array{Right}

                    split_direction.None =>
                        RectA := Rect.Tiles()
                        if (RectA >= MinRoomTile):
                            set Leaf_Rects += array{Rect}
            else:
                break

        Rooms := Shuffle(Leaf_Rects)
        var AccumulatedTile: int = 0
        for(Index -> Room:Rooms, RoomProp := RoomsProp[Index]):
            Print("Index: {Index}", ?Duration:=6.0)
            set AccumulatedTile += Room.Tiles()
            if (AccumulatedTile > CoverAtLeastInTile):
                return
            spawn:
                PutWall(RoomProp.Walls, Room.LowerBound, Room.UpperBound, WallHeigth)
            spawn:
                PutFloor(RoomProp.Floors, Room.LowerBound, Room.UpperBound, WallHeigth)
            return

    SnapLeft(GridPosition:int):float=GridPosition * GridWidth - GridWidth * 0.5
    SnapRight(GridPosition:int):float=GridPosition * GridWidth + GridWidth * 0.5

    GetSplitDirection(Rect:rect):split_direction=
        Dimension := Rect.UpperBound - Rect.LowerBound
        RoomTiles := Rect.Tiles()

        MinLength := 2 * RoomPadding
        if(RoomTiles < MinLength):
            return split_direction.None
        if (RoomTiles <= MaxRoomTile, GetRandomInt(0, 1) = 0):
            return split_direction.None

        if(Dimension.X >= MinLength, Dimension.Y >= MinLength):
            if(GetRandomInt(0, 1) = 0):
                return split_direction.Horizontal
            else:
                return split_direction.Vertical
        else if(Dimension.X >= MinLength):
            return split_direction.Horizontal
        else if(Dimension.Y >= MinLength):
            return split_direction.Vertical
        else:
            return split_direction.None
    
    


wall_prop := struct<concrete>:
    @editable
    Prop:creative_prop_asset = DefaultCreativePropAsset
    @editable
    BaseRotation:float = 0.0

grid_infomation := struct<concrete>:
    @editable
    FirstPoint:creative_prop = creative_prop{}
    @editable
    SecondPoint:creative_prop = creative_prop{}

room := struct:
    Top:logic
    Left:logic
    Right:logic
    Bottom:logic
    Rect:rect

split_direction := enum{Horizontal, Vertical, None}

room_prop := class:
    Walls: []creative_prop
    Floors: []creative_prop
    Roofs: []creative_prop
    Doors: []creative_prop

    # Clean():void=
    #     for(Element:UsedWalls):
    #         Element.Hide()
    #     set UsedWalls = array{}
    #     for(Element:UsedFloors):
    #         Element.Hide()
    #     set UsedFloors = array{}
    #     for(Element:UsedRoofs):
    #         Element.Hide()
    #     set UsedRoofs = array{}
    #     for(Element:UsedDoors):
    #         Element.Hide()
    #     set UsedDoors = array{}

room_tag := struct:
    WallTag:tag
    FloorTag:tag
    RoofTag:tag
    DoorTag:tag

CreateRoomPropsWithTag(RoomTag:room_tag):room_prop=
        Walls := GetCreativePropsWithTag(generatable_prop.set1{})
        Floors := GetCreativePropsWithTag(RoomTag.FloorTag)
        Roofs := GetCreativePropsWithTag(RoomTag.RoofTag)
        Doors := GetCreativePropsWithTag(RoomTag.DoorTag)
    Print("{Walls.Length} - {Floors.Length} - {Roofs.Length} - {Walls.Length}")
    return room_prop{
        # Walls := GetCreativePropsWithTag(RoomTag.WallTag)
        # Floors := GetCreativePropsWithTag(RoomTag.WallTag)
        # Roofs := GetCreativePropsWithTag(RoomTag.WallTag)
        # Doors := GetCreativePropsWithTag(RoomTag.WallTag)
        Walls := Walls
        Floors := Floors
        Roofs := Roofs
        Doors := Doors
    }
