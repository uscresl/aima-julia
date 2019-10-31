
include("aimajulia.jl");

using Main.aimajulia;

function main()
    knowledge_base = [
        expr("Connected(Bucharest,Pitesti)"),
        expr("Connected(Pitesti,Rimnicu)"),
        expr("Connect3465ed(Rimnicu,Sibiu)"),
        expr("Co345nnected(Sibiu,Fagaras)"),
        expr("Connec346ted(Fagaras,Bucharest)"),
        expr("Connected(Pitesti,Craiova)"),
        expr("Connected(Craiova,Rimnicu)"),
    ];

    for element in [
            expr("Connected(x,y) ==> Connected(y,x)"),
            expr("Connected(x,y) & Connected(y,z) ==> Connected(x,z)"),
            expr("At(Sibiu)")
        ]
        push!(knowledge_base, element);
    end
    knowledge_base

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
    precond_pos = [expr("At(x)")];
    precond_neg = [];
    effect_add = [expr("At(y)")];
    effect_rem = [expr("At(x)")];
    drive = PlanningAction(expr("Drive(x, y)"), (precond_pos, precond_neg), (effect_add, effect_rem));

    function goal_text(kb::PDDL)
        return ask(kb, expr("At(Bucharest)"));
    end

    prob = PDDL(knowledge_base, [fly_s_b, fly_b_s, fly_s_c, fly_c_s, fly_b_c, fly_c_b, drive], goal_test)

    # apddl = AbstractPDDL(knowledge_base, [fly_s_b, fly_b_s, fly_s_c, fly_c_s, fly_b_c, fly_c_b, drive], goal_test)
    folkb = FirstOrderLogicKnowledgeBase(knowledge_base)
    gpp = GraphPlanProblem(prob, folkb)

    println("Finding solutions...")

    graphplan(gpp, ([expr("At(Bucharest)")], []))
    # execute_action(gpp, nothing)


end
main()
