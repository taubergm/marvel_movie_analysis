import networkx as nx
import matplotlib.pyplot as plt
import csv


input_data = "./marvel_character_data2.csv"

curr_movie = ""
prev_movie = ""

main_characters = ["Tony Stark", "Thor", "Steve Rogers", "Peter Parker", "Peter Quill", "Natasha Romanov",
            "Scott Lang", "Loki", "Nick Fury", "Rocket Raccoon", "Pepper Potts", "Bruce Banner", "Gamora",
            "Dr. Hank Pym", "Sam Wilson", "Drax", "Clint Barton"]


other_characters = ['Steven Strange', 'Carol Danvers', 'Odin', 'Valkyrie',  'T\'challa', 'Nakia', 'Shuri', 'Happy Hogan', 
                    'Phil Coulson', 'Maria Hill', 'Bucky Barnes', 'Nebula', 'Sif', 'Heimdall', 'Yondu', 'Rhodey', 'Vision', 
                    'Peggy Carter', 'Luis', 'Wanda Maximoff', 'Thaddeus Ross', 'Janet van Dyne', 'Howard Stark', 'Thanos', 
                    'Wong', 'Mantis', 'Ned']


all_characters = main_characters + other_characters



seen_characters = set()
MG = nx.MultiGraph()
DG = nx.DiGraph()

#for character in main_characters:
#    G.add_node(character)
#    MG.add_node(character)
#    DG.add_node(character)
    

# iterate through movies. if characters share a movie, add an edge
with open(input_data) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for row in csv_reader:
        character = row[0]
        movie = row[2]

        # we have a new movie
        if (movie != prev_movie):
            marked_characters = set()
            for character in seen_characters:
                marked_characters.add(character)
                for other_character in seen_characters:
                    if ((character != other_character) and (other_character not in marked_characters)):

                        #MG.add_edge(character, other_character, attribute=movie)
                        #G.add_edge(character, other_character)

                        print "%s - %s - %s" % (prev_movie, character, other_character)
                        if (DG.has_edge(character, other_character)):
                            # we added this one before, just increase the weight by one
                            DG[character][other_character]['weight'] += 1
                        else:
                            # new edge. add with weight=1
                            DG.add_edge(character, other_character, weight=1)

                        if (character,other_character) in MG.edges():
                            data = MG.get_edge_data(character, other_character, key='edge')
                            MG.add_edge(character, other_character, key='edge', weight=data['weight']+1)
                        else:
                            MG.add_edge(character, other_character, key='edge', weight=1)

            seen_characters = set()
            prev_movie = movie

        if character not in seen_characters:
            if character in main_characters:
                #print "%s - %s" % (movie, character)
                seen_characters.add(character)


#print MG.number_of_nodes()
#print MG.number_of_edges()

#values = [val_map.get(node, 0.25) for node in MG.nodes()]
#pos = nx.spring_layout(MG)
#nx.draw_networkx_nodes(MG, pos, cmap=plt.get_cmap('jet'), 
#                       node_color = 'white', node_size = 700)
#nx.draw_networkx_labels(MG, pos)
#nx.draw_networkx_edges(MG, pos, edge_color='yellow', arrows=False)
#plt.show()

#nx.draw(MG, with_labels=True, font_weight='bold')
#nx.draw_networkx(MG)
#plt.show()


# #########
# create graph based on shared scenes
# ######
G = nx.Graph()
line_num = 0
scene_characters = []
prev_movie = ""
with open(input_data) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for row in csv_reader:
        character = row[0]
        movie = row[2]
        scene_characters.append(character)

        if (movie != prev_movie):
            scene_characters = []
            prev_movie = movie

        if ((line_num % 20) == 0):
            new_scene = True
            for character in scene_characters:
                for other_character in scene_characters:
                    if ((character in all_characters) and (other_character in all_characters)):
                        G.add_edge(character, other_character)
                        print "%s - %s - %s" % (prev_movie, character, other_character)
            scene_characters = []

        line_num = line_num + 1


# kamada_kawai_layout is best
#pos = nx.kamada_kawai_layout(G)
#plt.figure(1)
#nx.draw_networkx_nodes(G, pos, cmap=plt.get_cmap('jet'), 
#                       node_color = 'white', node_size = 700, font_size=4.5)
#nx.draw_networkx_labels(G, pos)
#nx.draw_networkx_edges(G, pos, edge_color='red', arrows=False, style='dotted', width=0.3)
#plt.figure(1,figsize=(20,25)) 
#plt.show()


# #########
# create graph based on character interactions
# ######
G = nx.Graph()
line_num = 0
prev_character = ""
with open(input_data) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for row in csv_reader:
        character = row[0]
        movie = row[2]

        if ((prev_character in all_characters) and (character in all_characters)):
            G.add_edge(character, prev_character)
            print "%s - %s - %s" % (movie, character, prev_character)
         
        prev_character = character    
        line_num = line_num + 1



pos = nx.kamada_kawai_layout(G)
plt.figure(1)
nx.draw_networkx_nodes(G, pos, cmap=plt.get_cmap('jet'), 
                       node_color = 'white', node_size = 700, font_size=4.5)
nx.draw_networkx_labels(G, pos)
nx.draw_networkx_edges(G, pos, edge_color='red', arrows=False, style='dotted', width=0.3)
plt.figure(1,figsize=(20,25)) 
plt.show()



character_degrees =  dict(G.degree)
fieldnames = ['character', 'degrees']
print character_degrees

with open('mycsvfile.csv', 'wb') as f:  
    w = csv.DictWriter(f, character_degrees.keys())
    w.writeheader()
    w.writerow(character_degrees)


deg_cen = nx.degree_centrality(G)
print deg_cen

betweeness_centrality = nx.betweenness_centrality(G)
fieldnames = ['character', 'betweeness_centrality']
with open('betweeness_centrality.csv', 'wb') as f:  
    w = csv.DictWriter(f, betweeness_centrality.keys())
    w.writeheader()
    w.writerow(betweeness_centrality)


eigenvector_centrality = nx.eigenvector_centrality(G)
fieldnames = ['character', 'eigenvector_centrality']
with open('eigenvector_centrality.csv', 'wb') as f:  
    w = csv.DictWriter(f, eigenvector_centrality.keys())
    w.writeheader()
    w.writerow(eigenvector_centrality)

closeness_centrality = nx.closeness_centrality(G)
fieldnames = ['character', 'closeness_centrality']
with open('closeness_centrality.csv', 'wb') as f:  
    w = csv.DictWriter(f, closeness_centrality.keys())
    w.writeheader()
    w.writerow(closeness_centrality)

