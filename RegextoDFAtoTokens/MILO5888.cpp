#include<iostream>
#include<stack>
#include<set>
#include<queue>
#include<algorithm>
#include<fstream>
#include<vector>
#include<string>

using namespace std;

string output;
vector<string> regex;
string inputString;

class Tree
{
    public:
    Tree *right;
    char data;
    Tree *left;

    Tree()
    {
        this->right=NULL;
        this->data='.';
        this->left=NULL;
    }

    Tree(char a)
    {
        this->right=NULL;
        this->data=a;
        this->left=NULL;
    }
};

Tree *regexToSyntaxTree(string regex)
{
    stack<int> a;
    if(regex.size()==3)
    {
        Tree *node=new Tree(regex[1]);
        return node;
    }
    stack<int> b;
    Tree *node=new Tree();
    int size=regex.size();
    int r=0;
    int end=0;
    int l=0;
    int i=0;
    while(i<size)
    {
        if(regex[i]=='(') a.push(1);
        else if(regex[i]==')')
        {
            a.pop();
            r++;
        }
        if(a.size()==1 && r>0)
        {
            node->left=regexToSyntaxTree(regex.substr(1,i));
            end=i;
            break;
        }
        i++;
    }
    if(regex[end+1]=='?')
    {
        node->data='?';
        return node;
    }

    else if(regex[end+1]=='+')
    {
        node->data='+';
        return node;
    }
    else if(regex[end+1]=='|')
    {
        node->data='|';
        end++;
    }
    else if(regex[end+1]=='*')
    {
        node->data='*';
        return node;
    }
    i=end+1;
    while(i<size)
    {
        if(regex[i]=='(') b.push(1);
        else if(regex[i]==')')
        {
            b.pop();
            l++;
        }
        if(b.size()==0 && l>0)
        {
            node->right=regexToSyntaxTree(regex.substr(end+1,i-end));
            break;
        }
        i++;
    }
    return node;
}

class NFAWES
{
    public:
    vector<NFAWES *>E;
    vector<NFAWES *> B;
    vector<NFAWES *> A;
};

class NFAWE
{
    public:
    vector<NFAWES *> finalStates;
    NFAWES *startState;
    vector<NFAWES *> States;
};

NFAWE *NFAcharacter(char);
NFAWE *NFAconcatination(NFAWE *,NFAWE *);
NFAWE *NFAoneormore(NFAWE *);
NFAWE *NFAzeroormore(NFAWE *);
NFAWE *NFAoneorzero(NFAWE *);
NFAWE *NFAunion(NFAWE *,NFAWE *);

NFAWE *treeToNFAWE(Tree *node)
{
    if(node->data=='a' || node->data=='b') return NFAcharacter(node->data);
    if(node->data=='.') return NFAconcatination(treeToNFAWE(node->left),treeToNFAWE(node->right));
    else if(node->data=='+') return NFAoneormore(treeToNFAWE(node->left));
    else if(node->data=='*') return NFAzeroormore(treeToNFAWE(node->left));
    else if(node->data=='?') return NFAoneorzero(treeToNFAWE(node->left));
    else if(node->data=='|') return NFAunion(treeToNFAWE(node->left),treeToNFAWE(node->right));
    return NULL;
}

NFAWE *NFAconcatination(NFAWE *node1,NFAWE *node2)
{
    NFAWE *f=new NFAWE();
    f->startState=node1->startState;
    int i=0;
    while(i<node1->States.size())
    {
        f->States.push_back(node1->States[i]);
        int j=0;
        while(j<node1->finalStates.size())
        {
            if(f->States[i]==node1->finalStates[j]) f->States[i]->E.push_back(node2->startState);
            j++;
        }
        i++;
    }
    i=0;
    while(i<node2->States.size())
    {
        f->States.push_back(node2->States[i]);
        i++;
    }
    i=0;
    while(i<node2->finalStates.size())
    {
        f->finalStates.push_back(node2->finalStates[i]);
        i++;
    }
    return f;
}

NFAWE *NFAcharacter(char s)
{
    NFAWES *g=new NFAWES();
    NFAWES *d=new NFAWES();
    NFAWE *f=new NFAWE();
    (s=='a')?d->A.push_back(g):d->B.push_back(g);
    f->States.push_back(d);
    f->startState=d;
    f->States.push_back(g);
    f->finalStates.push_back(g);
    return f;
}

NFAWE *NFAoneormore(NFAWE *node)
{   
    NFAWES *g=new NFAWES();
    NFAWES *d= new NFAWES();
    d->E.push_back(node->startState);
    NFAWE *f=new NFAWE();
    int i=0;
    while(i<node->States.size())
    {
        f->States.push_back(node->States[i]);
        for(int j=0;j<node->finalStates.size();j++)
            if(f->States[i]==node->finalStates[j])
            {
                f->States[i]->E.push_back(node->startState);
                f->States[i]->E.push_back(g);
            }
        i++;
    }
    f->startState=d;
    f->finalStates.push_back(g);
    f->States.push_back(d);
    f->States.push_back(g);
    return f;
}

NFAWE *NFAzeroormore(NFAWE *node)
{
    NFAWES *g=new NFAWES();
    NFAWE *f=new NFAWE();
    NFAWES *d=new NFAWES();
    d->E.push_back(node->startState);
    d->E.push_back(g);
    int i=0;
    while(i<node->States.size())
    {
        f->States.push_back(node->States[i]);
        for(int j=0;j<node->finalStates.size();j++)
            if(f->States[i]==node->finalStates[j])
            {
                f->States[i]->E.push_back(node->startState);
                f->States[i]->E.push_back(g);
            }
        i++;
    }
    f->startState=d;
    f->finalStates.push_back(g);
    f->States.push_back(d);
    f->States.push_back(g);
    return f;
}

NFAWE *NFAoneorzero(NFAWE *node)
{
    NFAWES *d=new NFAWES();
    d->E.push_back(node->startState);
    NFAWES *g=new NFAWES();
    d->E.push_back(g);
    NFAWE *f=new NFAWE();
    for(int i=0;i<node->States.size();i++)
    {
        f->States.push_back(node->States[i]);
        int j=0;
        while(j<node->finalStates.size())
        {
            if(f->States[i]==node->finalStates[j]) f->States[i]->E.push_back(g);   
            j++;
        }
    }
    f->States.push_back(d);
    f->startState=d;
    f->States.push_back(g);
    f->finalStates.push_back(g);
    return f;
}

NFAWE *NFAunion(NFAWE *node1,NFAWE *node2)
{
    int index=0;
    NFAWES *d=new NFAWES();
    d->E.push_back(node1->startState);
    d->E.push_back(node2->startState);
    NFAWES *g=new NFAWES();
    NFAWE *f=new NFAWE();
    for(int i=0;i<node1->States.size();i++)
    {
        f->States.push_back(node1->States[i]);
        int j=0;
        index++;
        while(j<node1->finalStates.size())
        {
            if(f->States[i]==node1->finalStates[j]) f->States[i]->E.push_back(g);
            j++;
        }
    }
    int l=f->States.size();
    int i=0;
    while(i<node2->States.size())
    {
        f->States.push_back(node2->States[i]);
        index++;
        int j=0;
        while(j<node2->finalStates.size())
        {
            if(f->States[index-1]==node2->finalStates[j]) f->States[index-1]->E.push_back(g);
            j++;
        }
        i++;
    }
    f->startState=d;
    f->finalStates.push_back(g);
    f->States.push_back(d);
    f->States.push_back(g);
    return f;
}


class NFAS
{
    public:
    vector<int> B;
    vector<int> A;
};

class NFA
{
    public:
    
    vector<int> finalStates;
    int startState;
    vector<NFAS *> States;
};

NFA *NFAWEToNFA(NFAWE *nfawe)
{
    NFA *f=new NFA();
    int i=0;
    while(i<nfawe->States.size())
    {
        nfawe->States[i]->E.push_back(nfawe->States[i]);
        f->States.push_back(new NFAS());
        if(nfawe->startState==nfawe->States[i]) f->startState=i;
        i++;
    }
    i=0;
    while(i<nfawe->States.size())
    {
        vector<NFAWES *> d;
        vector<NFAWES *> g;
        int ja=0;
        while(ja<nfawe->States[i]->E.size())
        {
            d.push_back(nfawe->States[i]->E[ja]);
            g.push_back(nfawe->States[i]->E[ja]);
            ja++;
        }
        int p=0;
        while(p<d.size())
        {
            for(int j=0;j<d[p]->E.size();j++)
                if(find(d.begin(),d.end(),d[p]->E[j])==d.end()) d.push_back(d[p]->E[j]);
            p++;
        }
        for(int j=0;j<d.size();j++)
        {
            vector<NFAWES *> z;
            for(int l=0;l<d[j]->A.size();l++) z.push_back(d[j]->A[l]);
            int x=0;
            while(x<z.size())
            {
                for(int o=0;o<z[x]->E.size();o++)
                    if(find(z.begin(),z.end(),z[x]->E[o])==z.end()) z.push_back(z[x]->E[o]);
                x++;
            }
            for(int l=0;l<z.size();l++)
            {
                int c=find(nfawe->States.begin(),nfawe->States.end(),z[l])-nfawe->States.begin();
                if(find(f->States[i]->A.begin(),f->States[i]->A.end(),c)==f->States[i]->A.end())
                {
                    f->States[i]->A.push_back(c);
                    if(find(nfawe->finalStates.begin(),nfawe->finalStates.end(),z[l])!=nfawe->finalStates.end())
                        if(find(f->finalStates.begin(),f->finalStates.end(),c)==f->finalStates.end())
                            f->finalStates.push_back(c);
                    
                }
            }
        }
        for(int v=0;v<g.size();v++)
        {
            int j=0;
            while(j<g[v]->E.size())
            {
                if(find(g.begin(),g.end(),g[v]->E[j])==g.end()) g.push_back(g[v]->E[j]);
                j++;
            }
        }
        for(int j=0;j<g.size();j++)
        {
            vector<NFAWES *> n;
            for(int l=0;l<g[j]->B.size();l++) n.push_back(g[j]->B[l]);
            int m=0;
            while(m<n.size())
            {
                for(int k=0;k<n[m]->E.size();k++)
                    if(find(n.begin(),n.end(),n[m]->E[k])==n.end()) n.push_back(n[m]->E[k]);
                m++;
            }
            for(int k=0;k<n.size();k++)
            {
                int q=find(nfawe->States.begin(),nfawe->States.end(),n[k])-nfawe->States.begin();
                if(find(f->States[i]->B.begin(),f->States[i]->B.end(),q)==f->States[i]->B.end())
                {
                    f->States[i]->B.push_back(q);
                    if(find(nfawe->finalStates.begin(),nfawe->finalStates.end(),n[k])!=nfawe->finalStates.end())
                        if(find(f->finalStates.begin(),f->finalStates.end(),q)==f->finalStates.end()) f->finalStates.push_back(q);
                }
            }
        }
        i++;
    }
    return f;
}

class DFAS
{
    public:
    int B;
    int A;
};

class DFA
{
    public:
    vector<DFAS *> States;
    vector<int> finalStates;
    int startState;
};

DFA *NFAToDFA(NFA *nfa)
{
    DFA *n=new DFA();
    int w=0;
    int i=0;
    vector<set<int>> z;
    n->startState=0;
    z.push_back(set<int>{nfa->startState});
    w++;
    while(w>i)
    {
        set<int> SA;
        set<int> SB;
        n->States.push_back(new DFAS());
        set<int>::iterator pa=z[i].begin();
        while(pa!=z[i].end())
        {
            for(auto o:nfa->States[*pa]->A) SA.insert(o);
            for(auto o:nfa->States[*pa]->B) SB.insert(o);
            pa++;
        }
        int p=0;
        int o=0;
        bool FA=false;
        bool FB=false;
        vector<set<int>>::iterator k=z.begin();
        while(k!=z.end())
        {
            if(*k==SA)
            {
                n->States[i]->A=p;
                FA=true;
                break;
            }
            p++;
            k++;
        }
        if(!FA)
        {
            z.push_back(set<int>{});
            set<int>::iterator k=SA.begin();
            while(k!=SA.end())
            {
                z[w].insert(*k);
                k++;
            }
            n->States[i]->A=w;
            w++;
        }
        int h=0;
        while(h<z.size())
        {
            if(z[h]==SB)
            {
                n->States[i]->B=o;
                FB=true;
                break;
            }
            o++;
            h++;
        }
        if(!FB)
        {
            z.push_back(set<int>{});
            set<int>::iterator it=SB.begin();
            while(it!=SB.end()) 
            {
                z[w].insert(*it);
                it++;
            }
            n->States[i]->B=w;
            w++;
        }
        if(i==0 && FA && FB)
        {
            z.push_back(set<int>{});
            w++;
        }
        set<int>::iterator it=z[i].begin();
        while(it!=z[i].end())
        {
            if(find(nfa->finalStates.begin(),nfa->finalStates.end(),*it)!=nfa->finalStates.end()) n->finalStates.push_back(i);
            it++;
        }
        i++;
    }
    return n;
}

void tokenoutput(vector<DFA *>& dfas, string inputString){
    int inputsize = inputString.size();
    if(inputsize==0) return;
    int dfasize = dfas.size();
    int f=-1;
    int r=-1;
    int i=0;
    while(i<dfasize)
    {                    
        int State = dfas[i]->startState;
        int g = -1;
        int j=0;
        while(j<inputsize)
        {
            State=(inputString[j]=='a')?(dfas[i]->States[State]->A):(dfas[i]->States[State]->B);                 
            if(find(dfas[i]->finalStates.begin(), dfas[i]->finalStates.end(), State) != dfas[i]->finalStates.end()) g = j;
            j++;
        }
        if(g>f)
        {
            r = i+1;
            f = g;
        }
        i++;
    }
    if(f == -1)
    {
        output+="<";
        output+=inputString[0];
        output+=("," +to_string(0)+">");
        tokenoutput(dfas, inputString.substr(1));
    }
    else
    {
        output+=("<"+inputString.substr(0, f+1)+ "," +to_string(r)+">");
        tokenoutput(dfas, inputString.substr(f+1));
    }
    return;
}

int main()
{
    fstream f;
    f.open("input.txt",ios::in);
    string rules;
    vector<Tree*> syntaxTree;
    if(f.is_open())
    {
        getline(f,inputString);
        while(getline(f,rules)) regex.push_back(rules);
        f.close();
    }
    for(int i=0;i<regex.size();i++) syntaxTree.push_back(regexToSyntaxTree(regex[i]));
    vector<NFAWE *> NFAWEs;
    for(int i=0;i<regex.size();i++) NFAWEs.push_back(treeToNFAWE(syntaxTree[i]));    
    vector<NFA *> NFAs;
    for(int i=0;i<regex.size();i++) NFAs.push_back(NFAWEToNFA(NFAWEs[i]));
    vector<DFA *> DFAs;
    f.open("output.txt",ios::out);
    int i=0;
    while(i<regex.size())
    {
        DFAs.push_back(NFAToDFA(NFAs[i]));
        i++;
    }
    tokenoutput(DFAs,inputString);
    f<<output;
    f.close();
    return 0;
}