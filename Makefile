# Make sure ocamlbuild can find opam-managed packages: first run
#
# eval `opam config env`

# Easiest way to build: using ocamlbuild, which in turn uses ocamlfind

.PHONY : all
all : shoo.native builtins.o

.PHONY : shoo.native
shoo.native :
	rm -f *.o
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis,llvm.bitreader -cflags -w,+a-4 \
		shoo.native

builtins.o :
	cc -c -o builtins.o src/builtins.c

.PHONY : printer
printer:
	ocamlbuild -use-ocamlfind src/printer.native

.PHONY : infer
infer:
	ocamlbuild -use-ocamlfind src/infer.native

.PHONY : test
test:
	ocamlbuild -use-ocamlfind test/test.native
	# "make clean" removes all generated files

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf shoo.native scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o *.s *.ll *.out *.exe

# More detailed: build using ocamlc/ocamlopt + ocamlfind to locate LLVM

OBJS = ast.cmx sast.cmx codegen.cmx parser.cmx scanner.cmx semant.cmx shoo.cmx

shoo : $(OBJS)
	ocamlfind ocamlopt -linkpkg -package llvm -package llvm.analysis $(OBJS) -o grapl

scanner.ml : scanner.mll
	ocamllex scanner.mll

parser.ml parser.mli : parser.mly
	ocamlyacc parser.mly

%.cmo : %.ml
	ocamlc -c $<

%.cmi : %.mli
	ocamlc -c $<

%.cmx : %.ml
	ocamlfind ocamlopt -c -package llvm $<

### Generated by "ocamldep *.ml *.mli" after building scanner.ml and parser.ml
ast.cmo :
ast.cmx :
codegen.cmo : ast.cmo
codegen.cmx : ast.cmx
shoo.cmo : semant.cmo scanner.cmo parser.cmi codegen.cmo ast.cmo
shoo.cmx : semant.cmx scanner.cmx parser.cmx codegen.cmx ast.cmx
parser.cmo : ast.cmo parser.cmi
parser.cmx : ast.cmx parser.cmi
scanner.cmo : parser.cmi
scanner.cmx : parser.cmx
semant.cmo : ast.cmo
semant.cmx : ast.cmx

