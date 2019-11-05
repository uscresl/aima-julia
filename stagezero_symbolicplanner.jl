# Our own symbolic graph

include("aimajulia.jl");
using Main.aimajulia;

knowledge_base = [
    expr("Connected(Bucharest,Pitesti)"),
    expr("Connected(Pitesti,Rimnicu)"),
    expr("Connected(Rimnicu,Sibiu)"),
    expr("Connected(Sibiu,Fagaras)"),
    expr("Connected(Fagaras,Bucharest)"),
    expr("Connected(Pitesti,Craiova)"),
    expr("Connected(Craiova,Rimnicu)"),
];

for element in [
        expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & Closed(D1) & Closed(D2) ==> At(START)"),
        expr("Empty(S1) & Empty(S2) & !Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS1)"),
        expr("Empty(S1) & Empty(S2) & Empty(C1) &!Empty(C2) & !Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS2)"),
        expr("!Empty(S1) & Empty(S2) & Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS3)"),
        expr("Empty(S1) & !Empty(S2) & Empty(C1) &!Empty(C2) & Empty(arm) & !Closed(D1) & Closed(D2) ==> At(SS4)"),
        expr("At(START)")
    ]
    push!(knowledge_base, element);
end

# Sibiu to Bucharest
precond_pos = [expr("At(Sibiu)")];
precond_neg = [];
effect_add = [expr("At(Bucharest)")];
effect_rem = [expr("At(Sibiu)")];
fly_s_b = PlanningAction(expr("Fly(Sibiu, Bucharest)"), (precond_pos, precond_neg), (effect_add, effect_rem));

# Bucharest to Sibiu
precond_pos = [expr("At(Bucharest)")];
precond_neg = [];
effect_add = [expr("At(Sibiu)")];
effect_rem = [expr("At(Bucharest)")];
fly_b_s = PlanningAction(expr("Fly(Bucharest, Sibiu)"), (precond_pos, precond_neg), (effect_add, effect_rem));

# Sibiu to Craiova
precond_pos = [expr("At(Sibiu)")];
precond_neg = [];
effect_add = [expr("At(Craiova)")];
effect_rem = [expr("At(Sibiu)")];
fly_s_c = PlanningAction(expr("Fly(Sibiu, Craiova)"), (precond_pos, precond_neg), (effect_add, effect_rem));

# Craiova to Sibiu
precond_pos = [expr("At(Craiova)")];
precond_neg = [];
effect_add = [expr("At(Sibiu)")];
effect_rem = [expr("At(Craiova)")];
fly_c_s = PlanningAction(expr("Fly(Craiova, Sibiu)"), (precond_pos, precond_neg), (effect_add, effect_rem));

# Bucharest to Craiova
precond_pos = [expr("At(Bucharest)")];
precond_neg = [];
effect_add = [expr("At(Craiova)")];
effect_rem = [expr("At(Bucharest)")];
fly_b_c = PlanningAction(expr("Fly(Bucharest, Craiova)"), (precond_pos, precond_neg), (effect_add, effect_rem));

# Craiova to Bucharest
precond_pos = [expr("At(Craiova)")];
precond_neg = [];
effect_add = [expr("At(Bucharest)")];
effect_rem = [expr("At(Craiova)")];
fly_c_b = PlanningAction(expr("Fly(Craiova, Bucharest)"), (precond_pos, precond_neg), (effect_add, effect_rem));

# Drive
precond_pos = [expr("At(x)"), expr("Connected(x,y)")];
precond_neg = [];
effect_add = [expr("At(y)")];
effect_rem = [expr("At(x)")];
drive = PlanningAction(expr("Drive(x, y)"), (precond_pos, precond_neg), (effect_add, effect_rem));

function goal_text(kb::PDDL)
    return ask(kb, expr("At(Bucharest)"));
end

prob = PDDL(knowledge_base, [fly_s_b, fly_b_s, fly_s_c, fly_c_s, fly_b_c, fly_c_b, drive], goal_test)

folkb = FirstOrderLogicKnowledgeBase(knowledge_base)
gpp = GraphPlanProblem(prob, folkb)

graphplan(gpp, ([expr("At(Bucharest)")], []))