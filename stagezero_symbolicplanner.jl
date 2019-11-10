# Our own symbolic graph

using Debugger

include("aimajulia.jl");
using Main.aimajulia;

function define()
    @bp
    knowledge_base = [
        expr("Empty(S1)"),
        expr("Empty(S2)"),
        expr("not(Empty(C1))"),
        expr("not(Empty(C2))"),
        expr("Empty(arm)"),
        expr("Closed(D1)"),
        expr("Closed(D2)"),
        # expr("At(START)"), 
        # expr("Empty(S1) & Empty(S2) & not(Empty(C1)) & not(Empty(C2)) & Empty(arm) & Closed(D1) & Closed(D2) ==> At(START)"),
        # expr("Empty(S1) & Empty(S2) & not(Empty(C1)) & not(Empty(C2)) & Empty(arm) & not(Closed(D1)) & Closed(D2) ==> At(SS1)"),
        ];

    # Open D1
    precond_pos = [expr("Closed(D1)"), expr("Empty(arm)")];
    precond_neg = [];
    effect_add = [expr("not(Closed(D1))")];
    effect_rem = [expr("Closed(D1)")]; # arm is still empty after the action
    open_d1 = PlanningAction(expr("OpenD1"), (precond_pos, precond_neg), (effect_add, effect_rem));

    # Open D2
    precond_pos = [expr("Closed(D2)"), expr("Empty(arm)")];
    precond_neg = [];
    effect_add = [expr("not(Closed(D2))")];
    effect_rem = [expr("Closed(D2)")]; # arm is still empty after the action
    open_d2 = PlanningAction(expr("OpenD2"), (precond_pos, precond_neg), (effect_add, effect_rem));

    function goal_test(kb::PDDL)
        return ask(kb, expr("not(Closed(D1))"));
    end

    prob = PDDL(knowledge_base, [open_d1, open_d2], goal_test)

    fol_kb = FirstOrderLogicKnowledgeBase(knowledge_base)
    gpp = GraphPlanProblem(prob, fol_kb)

    graphplan(gpp, ([expr("not(Closed(D1))")], []))
end

@enter define()