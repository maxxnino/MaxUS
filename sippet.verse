MoveAwayFrom(Source: fort_character, Target: fort_character, TA: agent)<suspends>:void=
    ST := Source.GetTransform().Translation
    TT := Target.GetTransform().Translation
    Direction := ST - TT
    if(DirUnit := Direction.MakeUnitVector[]):
        var Destination: vector3 = ST + DirUnit * vector3{X := 2000.0, Y := 2000.0, Z := 0.0}
        var BaseDir: vector3 := DirUnit
        OpNormal := GetSideNormal(Destination)
        if (NormalVector := OpNormal?, RefectedVector := ReflectVector[DirUnit, NormalVector]):
            set BaseDir = RefectedVector
            set Destination = ST + RefectedVector * vector3{X := 2000.0, Y := 2000.0, Z := 0.0}
            
        set Destination = ClampInsideWalkableArea(Destination)
        if(Navigatable := Source.GetNavigatable[], FI := Source.GetFocusInterface[]):
            # DebugDraw.DrawArrow(ST, Destination, ?DrawDurationPolicy:=debug_draw_duration_policy.FiniteDuration, ?Color := NamedColors.Red, ?Duration:= 5.0)
            # Navigatable.StopNavigation()
            FleeRadian := DegreesToRadians(GetRandomFloat(15.0, 30.0))
            Rotators := array:
                MakeRotation(vector3{X:= 0.0, Y:= 0.0, Z:=1.0}, FleeRadian)
                MakeRotation(vector3{X:= 0.0, Y:= 0.0, Z:=1.0}, -FleeRadian)
            var Index: int = GetRandomInt(0, Rotators.Length)
            for(Seg:array{700.0, 1400.0}):
                if(Rotator := Rotators[Index]):
                    set Index += 1
                    if (Index >= Rotators.Length):
                        set Index = 1
                    ZigZagDir := Rotator.RotateVector(BaseDir)
                    ZigZagTarget:= MakeNavigationTarget(ClampInsideWalkableArea(ST +  ZigZagDir * Seg))
                    race:
                        Navigatable.NavigateTo(ZigZagTarget, ?MovementType := movement_types.Running, ?ReachRadius := 128.0, ?AllowPartialPath := true)
                        FI.MaintainFocus(TA)
                
            NavTarget:= MakeNavigationTarget(Destination)
            race:
                Navigatable.NavigateTo(NavTarget, ?MovementType := movement_types.Running, ?ReachRadius := 256.0, ?AllowPartialPath := true)
                FI.MaintainFocus(TA)

GetSideNormal(Destination: vector3):?vector3=
    if(Destination.X < -6000.0):
        return option{vector3{X := 1.0, Y := 0.0, Z := 0.0}}
    if(Destination.X > 3800.0):
        return option{vector3{X := -1.0, Y := 0.0, Z := 0.0}}
    if(Destination.Y < -4000.0):
        return option{vector3{X := 0.0, Y := 1.0, Z := 0.0}}
    if(Destination.Y > 4400.0):
        return option{vector3{X := 0.0, Y := -1.0, Z := 0.0}}
    return false