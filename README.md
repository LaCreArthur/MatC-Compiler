# MatC-Compiler
Compilation Class Project for The ILC Master Degree at University of Strasbourg.
Goal: A small but fully working compiler on a (fake) sub-language of C. Lexical analysis with Lex and Syntaxical analysis with Yacc, producing a middle MIPS assembler code before the compilation.

## SUJET (FR):
## branche Analyse_lex :
  But : faire une analyse lex complete du language : transformer tout le code en tokens exploitables
  l'option -debug doit afficher un identifiant de token devant chacun d'eux (ex: main -> kw_main pour keyword)

## branche Analyse_synt :
  verifier la grammaire du code :
  ### en version 1 :
  le code commence par
  `int main() {` suivit du block main.  

  ### en version 2 :
   le code accepte d'autres fonctions que main ...

## Suite :
  * gerer la table de symbole pour pouvoir exploiter les variables du code
  * faire une branche MIPS qui transforme les QUADs en code mips,
  * modifier les fonctions de matrices pour qu'elles retournent des QUADs
