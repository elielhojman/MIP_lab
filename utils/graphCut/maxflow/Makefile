all: graph.a test

graph.a: 
	ar rcu libgraph.a graph.o maxflow.o
	ranlib libgraph.a

graph.o: 
	g++ -Wall -c graph.cpp -o graph.o


maxflow.o:
	g++ -Wall -c maxflow.cpp -o maxflow.o

test: 
	g++ -L . -lgraph test.o -o test



graph.o: graph.cpp graph.h block.h instances.inc
maxflow.o: maxflow.cpp graph.h block.h instances.inc
test.o: test.cpp graph.h block.h instances.inc
