from optimizer import *

def showteams(li):
    li = [float(i) for i in li]
    def CreateRandomTeam():
        team = {
            'pg': random.sample(pgs, 1),
            'sg': random.sample(sgs, 1),
            'sf': random.sample(sfs, 1),
            'pf': random.sample(pfs, 1),
            'c': random.sample(cs, 1),
            'g': random.sample(gs, 1),
            'f': random.sample(fs, 1),
            'util': random.sample(utils, 1)
        }

        while True:
            g = team['g'][0]
            if g in team['pg'] or g in team['sg'] or g in team['sf'] or g in team['pf'] or g in team['c'] \
                    or g in team['f'] or g in team['util']:
                team['g'] = random.sample(gs, 1)
            else:
                break

        while True:
            f = team['f'][0]
            if f in team['pg'] or f in team['sg'] or f in team['sf'] or f in team['pf'] or f in team['c'] \
                    or f in team['g'] or f in team['util']:
                team['f'] = random.sample(fs, 1)
            else:
                break

        while True:
            pg = team['pg'][0]
            if pg in team['sg'] or pg in team['sf'] or pg in team['pf'] or pg in team['c'] or pg in team['g'] \
                    or pg in team['f'] or pg in team['util']:
                team['pg'] = random.sample(pgs, 1)
            else:
                break

        while True:
            sg = team['sg'][0]
            if sg in team['pg'] or sg in team['sf'] or sg in team['pf'] or sg in team['c'] or sg in team['g'] \
                    or sg in team['f'] or sg in team['util']:
                team['sg'] = random.sample(sgs, 1)
            else:
                break

        while True:
            sf = team['sf'][0]
            if sf in team['pg'] or sf in team['sg'] or sf in team['pf'] or sf in team['c'] or sf in team['g'] \
                    or sf in team['f'] or sf in team['util']:
                team['sf'] = random.sample(sfs, 1)
            else:
                break

        while True:
            pf = team['pf'][0]
            if pf in team['pg'] or pf in team['sg'] or pf in team['sf'] or pf in team['c'] or pf in team['g'] \
                    or pf in team['f'] or pf in team['util']:
                team['pf'] = random.sample(pfs, 1)
            else:
                break

        while True:
            c = team['c'][0]
            if c in team['pg'] or c in team['sg'] or c in team['sf'] or c in team['pf'] or c in team['g'] \
                    or c in team['f'] or c in team['util']:
                team['c'] = random.sample(cs, 1)
            else:
                break

        while True:
            util = team['util'][0]
            if util in team['pg'] or util in team['sg'] or util in team['sf'] or util in team['pf'] or util in team['c'] \
                    or util in team['g'] or util in team['f']:
                team['util'] = random.sample(utils, 1)
            else:
                break
        return team

    def GetTeamPointTotal(team):
        total_points = 0
        for pos, players in team.iteritems():
            for player in players:
                total_points += player.points
        return total_points

    def GetTeamSalary(team):
        total_salary = 0
        for pos, players in team.iteritems():
            for player in players:
                total_salary += player.salary
        return total_salary

    def CreatePopulation(count):
        return [CreateRandomTeam() for i in range(0, count)]

    def fitness(team):
        points = GetTeamPointTotal(team)
        salary = GetTeamSalary(team)
        values = team.values()
        if salary > 50000:
            return 0
        return points

    def grade(pop):
        'Find average fitness for a population.'
        summed = reduce(add, (fitness(team) for team in pop))
        return summed / (len(pop) * 1.0)

    def listToTeam(players):
        return {
            'pg': [players[0]],
            'sg': [players[1]],
            'sf': [players[2]],
            'pf': [players[3]],
            'c': [players[4]],
            'g': [players[5]],
            'f': [players[6]],
            'util': [players[7]]
        }

    def breed(mother, father):
        positions = ['pg', 'sg', 'sf', 'pf', 'c', 'g', 'f', 'util']

        mother_lists = [
            mother['pg'] + mother['sg'] + mother['sf'] + mother['pf'] + mother['c'] + mother['g'] + mother['f'] +
            mother[
                'util']]
        mother_list = [item for sublist in mother_lists for item in sublist]
        father_lists = [
            father['pg'] + father['sg'] + father['sf'] + father['pf'] + father['c'] + father['g'] + father['f'] +
            father[
                'util']]
        father_list = [item for sublist in father_lists for item in sublist]

        index = random.choice([1, 2, 3, 4, 5, 6, 7])
        child1 = listToTeam(mother_list[0:index] + father_list[index:])
        child2 = listToTeam(father_list[0:index] + mother_list[index:])

        while True:
            g = child1['g'][0]
            if g in child1['pg'] or g in child1['sg'] or g in child1['sf'] or g in child1['pf'] or g in child1['c'] \
                    or g in child1['f'] or g in child1['util']:
                child1['g'] = random.sample(gs, 1)
            else:
                break

        while True:
            f = child1['f'][0]
            if f in child1['pg'] or f in child1['sg'] or f in child1['sf'] or f in child1['pf'] or f in child1['c'] \
                    or f in child1['g'] or f in child1['util']:
                child1['f'] = random.sample(fs, 1)
            else:
                break

        while True:
            pg = child1['pg'][0]
            if pg in child1['sg'] or pg in child1['sf'] or pg in child1['pf'] or pg in child1['c'] or pg in child1['g'] \
                    or pg in child1['f'] or pg in child1['util']:
                child1['pg'] = random.sample(pgs, 1)
            else:
                break

        while True:
            sg = child1['sg'][0]
            if sg in child1['pg'] or sg in child1['sf'] or sg in child1['pf'] or sg in child1['c'] or sg in child1['g'] \
                    or sg in child1['f'] or sg in child1['util']:
                child1['sg'] = random.sample(sgs, 1)
            else:
                break

        while True:
            sf = child1['sf'][0]
            if sf in child1['pg'] or sf in child1['sg'] or sf in child1['pf'] or sf in child1['c'] or sf in child1['g'] \
                    or sf in child1['f'] or sf in child1['util']:
                child1['sf'] = random.sample(sfs, 1)
            else:
                break

        while True:
            pf = child1['pf'][0]
            if pf in child1['pg'] or pf in child1['sg'] or pf in child1['sf'] or pf in child1['c'] or pf in child1['g'] \
                    or pf in child1['f'] or pf in child1['util']:
                child1['pf'] = random.sample(pfs, 1)
            else:
                break

        while True:
            c = child1['c'][0]
            if c in child1['pg'] or c in child1['sg'] or c in child1['sf'] or c in child1['pf'] or c in child1['g'] \
                    or c in child1['f'] or c in child1['util']:
                child1['c'] = random.sample(cs, 1)
            else:
                break

        while True:
            util = child1['util'][0]
            if util in child1['pg'] or util in child1['sg'] or util in child1['sf'] or util in child1['pf'] or util in \
                    child1['c'] \
                    or util in child1['g'] or util in child1['f']:
                child1['util'] = random.sample(utils, 1)
            else:
                break

        while True:
            g = child2['g'][0]
            if g in child2['pg'] or g in child2['sg'] or g in child2['sf'] or g in child2['pf'] or g in child2['c'] \
                    or g in child2['f'] or g in child2['util']:
                child2['g'] = random.sample(gs, 1)
            else:
                break

        while True:
            f = child2['f'][0]
            if f in child2['pg'] or f in child2['sg'] or f in child2['sf'] or f in child2['pf'] or f in child2['c'] \
                    or f in child2['g'] or f in child2['util']:
                child2['f'] = random.sample(fs, 1)
            else:
                break

        while True:
            pg = child2['pg'][0]
            if pg in child2['sg'] or pg in child2['sf'] or pg in child2['pf'] or pg in child2['c'] or pg in child2['g'] \
                    or pg in child2['f'] or pg in child2['util']:
                child2['pg'] = random.sample(pgs, 1)
            else:
                break

        while True:
            sg = child2['sg'][0]
            if sg in child2['pg'] or sg in child2['sf'] or sg in child2['pf'] or sg in child2['c'] or sg in child2['g'] \
                    or sg in child2['f'] or sg in child2['util']:
                child2['sg'] = random.sample(sgs, 1)
            else:
                break

        while True:
            sf = child2['sf'][0]
            if sf in child2['pg'] or sf in child2['sg'] or sf in child2['pf'] or sf in child2['c'] or sf in child2['g'] \
                    or sf in child2['f'] or sf in child2['util']:
                child2['sf'] = random.sample(sfs, 1)
            else:
                break

        while True:
            pf = child2['pf'][0]
            if pf in child2['pg'] or pf in child2['sg'] or pf in child2['sf'] or pf in child2['c'] or pf in child2['g'] \
                    or pf in child2['f'] or pf in child2['util']:
                child2['pf'] = random.sample(pfs, 1)
            else:
                break

        while True:
            c = child2['c'][0]
            if c in child2['pg'] or c in child2['sg'] or c in child2['sf'] or c in child2['pf'] or c in child2['g'] \
                    or c in child2['f'] or c in child2['util']:
                child2['c'] = random.sample(cs, 1)
            else:
                break

        while True:
            util = child2['util'][0]
            if util in child2['pg'] or util in child2['sg'] or util in child2['sf'] or util in child2['pf'] or util in \
                    child2['c'] \
                    or util in child2['g'] or util in child2['f']:
                child2['util'] = random.sample(utils, 1)
            else:
                break
        return [child1, child2]

    def mutate(team):
        positions = ['pg', 'sg', 'sf', 'pf', 'c', 'g', 'f', 'util']

        random_pos = random.choice(positions)
        if random_pos == 'pg':
            team['pg'][0] = random.choice(pgs)
        if random_pos == 'sg':
            team['sg'][0] = random.choice(sgs)
        if random_pos == 'sf':
            team['sf'][0] = random.choice(sfs)
        if random_pos == 'pf':
            team['pf'][0] = random.choice(pfs)
        if random_pos == 'c':
            team['c'][0] = random.choice(cs)
        if random_pos == 'g':
            team['g'][0] = random.choice(gs)
        if random_pos == 'f':
            team['f'][0] = random.choice(fs)
        if random_pos == 'util':
            team['util'][0] = random.choice(utils)

        while True:
            g = team['g'][0]
            if g in team['pg'] or g in team['sg'] or g in team['sf'] or g in team['pf'] or g in team['c'] \
                    or g in team['f'] or g in team['util']:
                team['g'] = random.sample(gs, 1)
            else:
                break

        while True:
            f = team['f'][0]
            if f in team['pg'] or f in team['sg'] or f in team['sf'] or f in team['pf'] or f in team['c'] \
                    or f in team['g'] or f in team['util']:
                team['f'] = random.sample(fs, 1)
            else:
                break

        while True:
            pg = team['pg'][0]
            if pg in team['sg'] or pg in team['sf'] or pg in team['pf'] or pg in team['c'] or pg in team['g'] \
                    or pg in team['f'] or pg in team['util']:
                team['pg'] = random.sample(pgs, 1)
            else:
                break

        while True:
            sg = team['sg'][0]
            if sg in team['pg'] or sg in team['sf'] or sg in team['pf'] or sg in team['c'] or sg in team['g'] \
                    or sg in team['f'] or sg in team['util']:
                team['sg'] = random.sample(sgs, 1)
            else:
                break

        while True:
            sf = team['sf'][0]
            if sf in team['pg'] or sf in team['sg'] or sf in team['pf'] or sf in team['c'] or sf in team['g'] \
                    or sf in team['f'] or sf in team['util']:
                team['sf'] = random.sample(sfs, 1)
            else:
                break

        while True:
            pf = team['pf'][0]
            if pf in team['pg'] or pf in team['sg'] or pf in team['sf'] or pf in team['c'] or pf in team['g'] \
                    or pf in team['f'] or pf in team['util']:
                team['pf'] = random.sample(pfs, 1)
            else:
                break

        while True:
            c = team['c'][0]
            if c in team['pg'] or c in team['sg'] or c in team['sf'] or c in team['pf'] or c in team['g'] \
                    or c in team['f'] or c in team['util']:
                team['c'] = random.sample(cs, 1)
            else:
                break

        while True:
            util = team['util'][0]
            if util in team['pg'] or util in team['sg'] or util in team['sf'] or util in team['pf'] or util in team['c'] \
                    or util in team['g'] or util in team['f']:
                team['util'] = random.sample(utils, 1)
            else:
                break
        return team

    def evolve(pop, retain=0.55, random_select=0.1, mutate_chance=0.01):
        graded = [(fitness(team), team) for team in pop]
        graded = [x[1] for x in sorted(graded, reverse=True)]
        retain_length = int(len(graded) * retain)
        parents = graded[:retain_length]

        # randomly add other individuals to promote genetic diversity
        for individual in graded[retain_length:]:
            if random_select > random.random():
                parents.append(individual)

        # mutate some individuals
        for individual in parents:
            if mutate_chance > random.random():
                individual = mutate(individual)

        # crossover parents to create children
        parents_length = len(parents)
        desired_length = len(pop) - parents_length
        children = []
        while len(children) < desired_length:
            male = random.randint(0, parents_length - 1)
            female = random.randint(0, parents_length - 1)
            if male != female:
                male = parents[male]
                female = parents[female]
                babies = breed(male, female)
                for baby in babies:
                    children.append(baby)
        parents.extend(children)
        return parents

    import roto1
    # toy = pd.read_csv(str(pd.to_datetime('today'))[:10]+'preds.csv')
    # injury = pd.read_csv(str(pd.to_datetime('today'))[:10]+'injuries.csv')


    gametime = sorted(roto1.today['GTime(ET)'].unique())
    # print 'fromopt', gametime





    toy = pd.read_csv('2017-03-29preds.csv')

    ignoreplayers = [''] + list(
        roto1.today[~roto1.today['GTime(ET)'].isin(li)]['First  Last'])  # +list(injury.PLAYER)  \
    toy = toy[~toy.PLAYER.isin(ignoreplayers)]

    players = []
    for row in range(len(toy)):
        name = toy.iloc[row]['PLAYER']
        pg = toy.iloc[row]['POSITION:1']
        sg = toy.iloc[row]['POSITION:2']
        sf = toy.iloc[row]['POSITION:3']
        pf = toy.iloc[row]['POSITION:4']
        c = toy.iloc[row]['POSITION:5']
        salary = int(toy.iloc[row]['DK Sal'])
        points = float(toy.iloc[row]['PREDS'])
        player = Player(pg, sg, sf, pf, c, name, salary, points)
        players.append(player)

    pgs = [player for player in players if player.pg == 1]
    sgs = [player for player in players if player.sg == 1]
    sfs = [player for player in players if player.sf == 1]
    pfs = [player for player in players if player.pf == 1]
    cs = [player for player in players if player.c == 1]
    gs = [player for player in players if player.pg == 1 or player.sg == 1]
    fs = [player for player in players if player.sf == 1 or player.pf == 1]
    utils = [player for player in players]







    best_teams = []
    history = []
    p = CreatePopulation(500)
    fitness_history = [grade(p)]
    for i in xrange(40):
        p = evolve(p)
        fitness_history.append(grade(p))
        valid_teams = [team for team in p if GetTeamSalary(team) <= 50000]
        valid_teams = sorted(valid_teams, key=GetTeamPointTotal, reverse=True)
        if len(valid_teams) > 0:
            best_teams.append(valid_teams[0])

    best_teams_ = sorted(best_teams, key=GetTeamPointTotal, reverse=True)
    best_teams_ = [team for team in best_teams_ if GetTeamSalary(team) <= 50000]

    best_teams_unique = []
    best_teams_unique.append(best_teams_[0])
    for i in range(1, len(best_teams_)):
        if best_teams_[i] != best_teams_unique[-1]:
            best_teams_unique.append(best_teams_[i])
    teamdict = {}
    for j in xrange(len(best_teams_unique)):
        teamlist = []
        choice_ = best_teams_unique[j]
        for i in ['pg', 'sg', 'sf', 'pf', 'c', 'g', 'f', 'util']:
            teamlist.append({'player': choice_[i][0].name, 'Sal': choice_[i][0].salary,
                             'Pts': round(choice_[i][0].points, 2),
                             'Value': round(choice_[i][0].points / (choice_[i][0].salary / 1000), 2)})

        teamdict[j] = {'team': teamlist, 'salary': GetTeamSalary(choice_), 'points': GetTeamPointTotal(choice_)}

    return teamdict