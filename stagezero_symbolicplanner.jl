# Our own symbolic graph

using Debugger

# include("utils.jl")
# using Main.utils
include("aimajulia.jl");
# include("planning.jl");
using Main.aimajulia;
# using Main.planning;

function define()
    knowledge_base = [
        expr("Door(D1)"),
        expr("Door(D2)"),
        expr("Spot(S1)"),
        expr("Spot(S2)"),
        expr("Cabinet(C1)"),
        expr("Cabinet(C2)"),
        expr("CabinetDoor(D1, C1)"),
        expr("CabinetDoor(D2, C2)"),
        expr("Arm(A1)"),

        expr("State(S1, Empty)"),
        expr("State(S2, Empty)"),
        expr("State(C1, Occupied)"),
        expr("State(C2, Occupied)"),
        expr("State(A1, Empty)"),
        expr("State(D1, Closed)"),
        expr("State(D2, Closed)"),
    ]

    # Open door action
    precond_pos = [
        expr("State(d, Closed)"),
        expr("State(a, Empty)"),
        expr("Arm(a)"),
        expr("Door(d)"),
    ]
    precond_neg = []
    effect_add = [expr("State(d, Open)")]
    effect_rem = [expr("State(d, Closed)")] # arm is still empty after the action
    open_door = PlanningAction(
        expr("OpenDoor(d, a)"),
        (precond_pos, precond_neg),
        (effect_add, effect_rem),
    )

    # Pick from cabinet action (Pick from cabinet c that's occupied, it's door d is open, arm a should be empty)
    precond_pos = [
        expr("Cabinet(c)"),
        expr("Door(d)"),
        expr("CabinetDoor(d,c)"),
        expr("State(d, Open)"),
        expr("State(c, Occupied)"),
        expr("Arm(a)"),
        expr("State(a, Empty)"),
    ]
    precond_neg = []
    effect_add = [expr("State(c, Empty)"), expr("State(a, Occupied)")]
    effect_rem = [expr("State(c, Occupied)"), expr("State(a, Empty)")] # arm is still empty after the action
    pick_from_cabinet = PlanningAction(
        expr("PickFromCabinet(c, d, a)"),
        (precond_pos, precond_neg),
        (effect_add, effect_rem),
    )

    # Place into spot s (Arm a should be occupied, spot s should be empty)
    precond_pos = [
        expr("Spot(s)"),
        expr("State(s, Empty)"),
        expr("Arm(a)"),
        expr("State(a, Occupied)"),
    ]
    precond_neg = []
    effect_add = [expr("State(s, Occupied)"), expr("State(a, Empty)")]
    effect_rem = [expr("State(s, Empty)"), expr("State(a, Occupied)")]
    place_on_spot = PlanningAction(
        expr("PlaceOnSpot(s,a)"),
        (precond_pos, precond_neg),
        (effect_add, effect_rem),
    )

    # function goal_test(kb::PDDL)
    #     return ask(kb, expr("State(D1, Open)"));
    # end

    # prob = PDDL(knowledge_base, [open_door, pick_from_cabinet, place_on_spot], goal_test)
    prob = PDDL(
        knowledge_base,
        [open_door, pick_from_cabinet, place_on_spot],
        goal_test,
    )

    fol_kb = FirstOrderLogicKnowledgeBase(knowledge_base)
    gpp = GraphPlanProblem(prob, fol_kb)

    # @bp
    graphplan(gpp, ([expr("State(D1, Open)"), expr("State(C1, Empty)")], []))
    println(fol_kb)
    println("STARTING STATE")

    execute_action(open_door, fol_kb, (expr("D1"),expr("A1")))
    println(fol_kb)
    println("EXECUTED DOOR OPEN")

    execute_action(pick_from_cabinet, fol_kb, (expr("C1"),expr("D1"),expr("A1")))
    println(fol_kb)
    println("EXECUTED PICK")

    execute_action(open_door, fol_kb, (expr("D2"),expr("A1")))
    println(fol_kb)
    println("EXECUTED DOOR OPEN")



    for soln in gpp.solution
        println(soln)
    end
    println("Finito!!")
end

# @enter define()
