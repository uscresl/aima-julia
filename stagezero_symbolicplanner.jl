# Our own symbolic graph

using Debugger

include("aimajulia.jl");
using Main.aimajulia;

function define()
    @bp
    knowledge_base = [
        expr("At(START)"), 
        expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & Closed(D1) & Closed(D2) ==> At(START)"),
        expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS1)"),
        ];

    # DOESN'T WORK
    # for element in [
    #         expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & Closed(D1) & Closed(D2) ==> At(START)"),
    #         expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS1)"),
    #         # expr("Empty(S1) & Empty(S2) & Empty(C1) &!Empty(C2) & !Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS2)"),
    #         # expr("!Empty(S1) & Empty(S2) & Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS3)"),
    #         # expr("Empty(S1) & !Empty(S2) & Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS4)"),
            
    #         # expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & Closed(D1) & !Closed(D2) ==> At(SS5)"),
    #         # expr("Empty(S1) & Empty(S2) & !Empty(C1) &Empty(C2) & !Empty(arm) & Closed(D1) & !Closed(D2) ==> At(SS6)"),
    #         # expr("!Empty(S1) & Empty(S2) & !Empty(C1) &Empty(C2) & Empty(arm) & Closed(D1) & !Closed(D2) ==> At(SS7)"),
    #         # expr("Empty(S1) & !Empty(S2) & !Empty(C1) &Empty(C2) & Empty(arm) & Closed(D1) & !Closed(D2) ==> At(SS8)"),
            
    #         # expr("At(START)")
    #     ]
    #     push!(knowledge_base, element);
    # end

    # Open D1
    precond_pos = [expr("Closed(D1)")];
    precond_neg = [];
    effect_add = [expr("!Closed(D1)")];
    effect_rem = [expr("Closed(D1)")];
    open_d1 = PlanningAction(expr("OpenD1"), (precond_pos, precond_neg), (effect_add, effect_rem));

    # Open D2
    precond_pos = [expr("Closed(D2)"), expr("Empty(arm)")];
    precond_neg = [];
    effect_add = [expr("!Closed(D2)")];
    effect_rem = [expr("Closed(D2)")]; # arm is still empty after the action
    open_d2 = PlanningAction(expr("OpenD2"), (precond_pos, precond_neg), (effect_add, effect_rem));

    # pick C1
    precond_pos = [expr("!Empty(C1)"), expr("Empty(arm)")];
    precond_neg = [];
    effect_add = [expr("Empty(C1)"), expr("!Empty(arm)")];
    effect_rem = [expr("!Empty(C1)"), expr("Empty(arm)")];
    pick_c1 = PlanningAction(expr("PickC1"), (precond_pos, precond_neg), (effect_add, effect_rem));

    function goal_test(kb::PDDL)
        return ask(kb, expr("At(SS1)"));
    end

    prob = PDDL(knowledge_base, [open_d1, open_d2, pick_c1], goal_test)

    fol_kb = FirstOrderLogicKnowledgeBase(knowledge_base)
    gpp = GraphPlanProblem(prob, fol_kb)

    graphplan(gpp, ([expr("At(START)")], []))
end

@enter define()