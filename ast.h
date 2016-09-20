/*Abstract Syntax Tree definition*/
#pragma once

#include <iostream>
#include <vector>

extern void yyerror(const char *s, ...);

namespace AST {

//Binary operations
enum Operation { plus, minus, times, div, assign, uminus };

class Node;

typedef std::vector<Node*> NodeList; //List of ASTs

class Node {
    public:
        virtual ~Node() {}
        virtual void printTree(){}
        //virtual int computeTree(){return 0;}
};

class Integer : public Node {
    public:
        int value;
        Integer(int value) : value(value) {  }
        void printTree();
        //int computeTree();
};

class BinOp : public Node {
    public:
        Operation op;
        Node *left;
        Node *right;
        BinOp(Node *left, Operation op, Node *right) :
            left(left), right(right), op(op) { }
        void printTree();
        //int computeTree();
};

class UniOp : public Node {
	public:
		Operation op;
		Node *node;
		UniOp(Node* node, Operation op) : node(node), op(op) {}
		void printTree();
	};

class Block : public Node {
    public:
        NodeList lines;
        Block() { }
        void printTree();
        //int computeTree();
};

class Variable : public Node {
     public:
         std::string id;
         Node *next;
         Variable(std::string id, Node *next) : id(id), next(next) { }
         void printTree();
         //int computeTree();
};

}
