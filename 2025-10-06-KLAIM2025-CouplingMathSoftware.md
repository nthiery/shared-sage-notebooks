---
jupytext:
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
kernelspec:
  display_name: SageMath 10.4
  language: sage
  name: sagemath
rise:
  auto_select: first
  autolaunch: false
  centered: false
  controls: false
  enable_chalkboard: false
  height: 100%
  margin: 0
  maxScale: 1
  minScale: 1
  scroll: true
  slideNumber: true
  start_slideshow_at: selected
  transition: none
  width: 90%
---

+++ {"slideshow": {"slide_type": "slide"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "4%", "top": "2%", "width": "90%"}}}}}

# Coupling computational mathematics software:
# a brief review of practices in SageMath and friends

+++ {"slideshow": {"slide_type": null}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "30%", "top": "25%"}}}}}

:::{image} media/banner.png
:width: 100%
:::

+++ {"slideshow": {"slide_type": null}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "4%", "top": "85%", "width": "90%"}}}}}

[Nicolas M. Thiéry](https://Nicolas.Thiery.name/),
Professor,
Laboratoire Interdisciplinaire des Sciences du Numérique ([LISN](https://lisn.upsaclay.fr/)), 
Université Paris-Saclay

October 6th of 2025, [KLAIM 2025](https://www.itwm.fraunhofer.de/en/fairs_events/2025/2025_10_06_klaim_en.html)

+++ {"slideshow": {"slide_type": "skip"}}

## Abstract

In many areas of mathematics, the exploration of new theories and the
discovery, evaluation, or refutation of new conjectures is nowadays
heavily supported by the power of machine computing; the latter indeed
enables manipulating complex examples and processing large datasets in
the search for regularities and counter examples. In certain cases,
theorems have even been proved by reductions to brute force testing on
a finite amount of data.

More often than not, computations require to couple new bespoke code
specific to the theory at hand together with many other preexisting
tools. For instance, a computation in algebraic combinatorics, the
field of the author, typically involves a combination of
combinatorics, exact arithmetic, linear algebra, (semi)group theory
and (multivariate) polynomials if not formal power series.

To fulfill this need, the mathematical community has developed over
the last two decades general purpose open source computational
mathematics systems like SageMath and now OSCAR. These build on many
specialized systems, the development of some of which like Antic, GAP,
Maxima, Polymake, PARI/GP, or Singular required the dedicated work of
dozens of researchers for up to four decades. SageMath, for example,
combines together more than a hundred systems and databases, adding
over a million lines of code, and offers thousands of mathematical
objects to compute with. A major challenge in the design and
implementation of such a system is therefore composability.

To setup the stage, the talk will begin with a brief introduction to
the SageMath system, its features, and components. We will then delve
into concrete examples, to review some of the challenges that arise at
different scales -- e.g. from SIMD parallelism to remote procedure
calls -- and strategies that have been used or explored for composing
computational mathematical software.

+++ {"slideshow": {"slide_type": "skip"}}

Material to be taken from:

- 2011-12-13-ScienceWorkshop.tex
  list of interface types in SageMath
- Six decades of Libre Scientific Software
  https://codimd.math.cnrs.fr/p/c59UNs2mN#/5/2
- /home/nthiery/Sage-Combinat/articles/2024-05-22-CategoriesHIM.tex
  Most recent description of SageMath variety of objects
- Interfacing Mathematical Computation Systems with Low-Level
  Libraries: a Survey of General Methods and Concrete Systems
  https://www.overleaf.com/15996604kpskgdsgjhww
- FLOC Talk https://hackmd.io/IZESWGzKSOCKJiC_tIP3pw
- INI (Newton Institute): /home/nthiery/OpenDreamKit/demo-semigroup-representation-theory/2020-01-18-INI-implementing-semigroup-representation-theory.md
- Sage Days 109 /home/nthiery/OpenDreamKit/demo-semigroup-representation-theory/2020-05-28-SageDay109-opendreamkit-debriefing.md
- WOSSS: /opt/shared-sage-notebooks/2021-10-07-WoSSS.md

+++ {"slideshow": {"slide_type": "slide"}}

## Menu

1. Context: the computational mathematics software ecosystem
    1. Mechanizing mathematics: the Tetrapod
	2. What do we want to compute with?
	3. Need to compose from a large ecosystem of components
2. Composing mathematical software
    1. Goals: transfers and procedure calls
    2. Barriers
3. Case studies

+++ {"slideshow": {"slide_type": "slide"}}

## Musing on the computational mathematics software ecosystem

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"height": "8.71428474547371%", "left": "-1.5654768262590681%", "position": "fixed", "top": "1.9312177385602678%", "width": "49.122025626046316%"}}}}, "slideshow": {"slide_type": "slide"}}

### Mechanizing mathematics: the Tetrapod

How can computers help mathematicians?

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "35.574073791503906%", "position": "fixed", "top": "40%", "width": "25%"}}}}, "editable": true, "slideshow": {"slide_type": ""}}

:::{image} media/tetrapod.jpg
:width: 100%
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "top": "15%", "width": "45%", "left": "0%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 📚Narration
- Use cases: help express, organize, interconnect, navigate,
  synthesize, visualize mathematical knowledge
- latex, jupyter, wikipedia, publishing services, ...
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "0%", "top": "65%", "width": "45%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 🤔 Deduction
- Use cases: help formalize and certify knowledge
- Proof checkers, proof assistants, automated provers, ...
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "15%", "width": "50%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 🖩**Computation** 
- Use cases: help observe and explore; infer and test conjectures\
  even sometimes prove them
- 🔭The mathematician's **telescope**
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "65%", "width": "50%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 💾Tabulation
- Use cases: help collect examples to explore; infer and test conjectures; record knowledge
- Databases of mathematical objects
- 💡Mostly a cache of hard to compute or deduce knowledge
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"height": "8.72222173781622%", "left": "48.18601335797991%", "position": "fixed", "top": "2.388889373294891%", "width": "45.267857142857146%", "zoom": "50%"}}}}, "slideshow": {"slide_type": null}}

:::{admonition} Big Math and the One-Brain Barrier – The Tetrapod Model of Mathematical Knowledge
:class: seealso
Jacques Carette et al. In: Mathematical Intelligencer 43.1 (2021), pp. 78–87. DOI: 10.1007/s00283-020
:::

+++ {"slideshow": {"slide_type": "slide"}}

## Concretely: what do we want to compute with?

```{code-cell} ipython3
%display latex
```

### Arithmetic and Algebra

+++ {"slideshow": {"slide_type": null}}

Numbers:
$42$, $\frac79$, $\frac{I+sqrt(3)}2$, $\pi$, $2.71828182845904523536028747?$

+++ {"slideshow": {"slide_type": "fragment"}}

Matrices:
  $\left(\begin{array}{rrrr}
      4 & -1 & 1 & -1 \\
      -1 & 2 & -1 & -1 \\
      0 & 5 & 1 & 3
    \end{array}\right)$,
  $\left(\begin{array}{rrr}
      1.000 & 0.500 & 0.333 \\
      0.500 & 0.333 & 0.250 \\
      0.333 & 0.250 & 0.200
    \end{array}\right)$

+++ {"slideshow": {"slide_type": "fragment"}}

Polynomials: {eval}`ZZ[x].random_element(degree=8)`

Series: {eval}`exp(x).series(x,6)`

+++ {"slideshow": {"slide_type": "fragment"}}

Finite fields, algebraic extensions, elliptic curves, ...

+++ {"slideshow": {"slide_type": "fragment"}}

And combinations!
{eval}`MatrixSpace(MatrixSpace(GF(3)['x'],2,2), 2, 2).random_element()`

+++ {"slideshow": {"slide_type": "slide"}}

### Calculus

```{code-cell} ipython3
f = (cos(pi/4-x)-tan(x)) / (1-sin(pi/4 + x)); f
```

```{code-cell} ipython3
---
slideshow:
  slide_type: fragment
---
limit(f, x = pi/4, dir='minus')
```

+++ {"slideshow": {"slide_type": "fragment"}}

### Solving equations

```{code-cell} ipython3
---
slideshow:
  slide_type: null
---
x,y = var('x,y')
solve([x^2+y^2 == 1, y^2 == x^3 + x + 1], x, y)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: skip
---
import io
io.open("media/dyck-word.svg", "w").write(DyckWords(50).random_element()._repr_svg_());
```

+++ {"slideshow": {"slide_type": "slide"}}

### Combinatorial objects
:::{image} media/labelled-binary-tree.svg
:width: 35%
:::
:::{image} media/alcoves-result.jpg
:width: 15%
:::
:::{image} media/dyck-word.svg
:width: 50%
:::

+++ {"slideshow": {"slide_type": "fragment"}}

And combinations thereof:
:::{image} media/calcul-operade.png
:::

+++ {"slideshow": {"slide_type": "subslide"}}

### Graph theory
:::{image} media/crystal-A3-32.svg
:width: 10% 
:::

+++ {"slideshow": {"slide_type": "slide"}}

#### Geometry
:::{image} media/polytope.png
:width: 50%
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{image} media/G2-alcove-path.svg
:width: 25%
:::
:::{image} media/manifold.png
:width: 30%
:::

+++ {"slideshow": {"slide_type": "slide"}}

### My world: computing semigroup representation theory

:::{admonition} Available building blocks

- Group computations: GAP, Magma
- Semigroup computations: GAP, Semigroups (GAP), KBMag (C), Semigroupe (C), libsemigroups (C++), Sage
- (Modular) representation theory of groups: GAP (but also GAP3+Specht)
- Algebraic Combinatorics: Sage, Symmetrica (C), lrcalc (C), Maple, Mathematica, ...
- Linear algebra: MeatAxe, Linbox, Sage, ...
- Polyhedral Geometry: LattE, polymake, ...
- Coxeter groups: GAP3+Chevie, GAP, Sage, Coxeter3 (C++), ...
- Markov chains: Mathematica, ...
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Why is that so?
:class: attention
:::

+++ {"slideshow": {"slide_type": "subslide"}}

### The Unicorn way: “There can be only one”

+++ {"slideshow": {"slide_type": "fragment"}}

That's what happens in the tech industry: a single player takes it all (Amazon, AirBnB, Uber, Chat-GPT, ...)

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Why not just one mathematical software?

Let's reimplement everything in {strike}`C++`, {strike}`Magma`, {strike}`GAP`, {strike}`Sage`, {strike}`Julia`, {strike}`Mathematica` {strike}`your favorite system`!
:::

+++ {"slideshow": {"slide_type": "skip"}}

- Ok for a quick focused result<br>
  Maybe that's what I should have done, actually, to get my paper out

+++ {"slideshow": {"slide_type": "fragment"}}

:::{error} Does not scale
Our software are the result of decades of hard work by hundreeds of experts
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{error} Promotes competition
Between systems, at the wrong scale
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{error} Honestly, we don't know what will a good system in 10-20 years
We need to explore many approaches
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Example SageMath: building on the car, not reinventing the wheel

% Building on the shoulders of giants

:::{figure} media/sage-car-medium.jpg
:alt: an allegory of SageMath as a car made of many components
:::




From the ecosystem of Mathematical software, and beyond

% :::{admonition} A good citizen in the ecosystem
% :class: hint
% - Reuse off-the-shelf components whenever possible
%   - Programming languages (e.g. C++, Python, Julia, ...)
%   - Preexisting libraries
%   - Computing environments and user interfaces (e.g Jupyter)
%   - Development models and tools
% - Is reusable
%   - Accessibility, ...
%   - Write generic code
% :::
%  
% <p style="text-align:center; font-weight:bold">Base decisions on technical <em>and</em> social matters<p>

+++ {"slideshow": {"slide_type": "slide"}}

### Sage's components (back in 2011!)

+++ {"slideshow": {"slide_type": "fragment"}}

| Software        | Role                                                         |
| ---             | ---                                                          |
| ATLAS           | Automatically Tuned Linear Algebra Software                  |
| **BLAS**        | Basic Fortan 77 linear algebra routines                      |
| Bzip2           | High-quality data compressor                                 |
| Cddlib          | Double Description Method of Motzkin                         |
| Common Lisp     | Multi-paradigm and general-purpose programming lang.         |
| CVXOPT          | Convex optimization, linear programming, least squares       |
| **Cython**      | C-Extensions for Python                                      |
| F2c             | Converts Fortran 77 to C code                                |
| Flint           | Fast Library for Number Theory                               |
| FpLLL           | Euclidian lattice reduction                                  |
| FreeType        | A Free, High-Quality, and Portable Font Engine               |
| G95             | Open source Fortran 95 compiler                              |
| GAP             | Groups, Algorithms, Programming                              |
| GD              | Dynamic graphics generation tool                             |
| Genus2reduction | Curve data computation                                       |
| Gfan            | Gröbner fans and tropical varieties                          |
| Givaro          | C++ library for arithmetic and algebra                       |
| GMP             | GNU Multiple Precision Arithmetic Library                    |
| GMP-ECM         | Elliptic Curve Method for Integer Factorization              |
| GNU TLS         | Secure networking                                            |
| GSL             | Gnu Scientific Library                                       |
| JsMath          | JavaScript implementation of LaTeX                           |
| IML             | Integer Matrix Library                                       |
| **IPython**     | Interactive Python shell                                     |
| **Jupyter**     | Interactive computing environment                            |
| LAPACK          | Fortan 77 linear algebra library                             |
| Lcalc           | L-functions calculator                                       |
| Libgcrypt       | General purpose cryptographic library                        |
| Libgpg-error    | Common error values for GnuPG components                     |
| Linbox          | C++ linear algebra library                                   |
| Mathjax         | LaTeX rendering on the web                                   |
| **Matplotlib**  | Python plotting library                                      |
| Maxima          | computer algebra system                                      |
| Mercurial       | Revision control system                                      |
| MoinMoin        | Wiki                                                         |
| MPFI            | Multiple Precision Floating-point Interval library           |
| MPFR            | C library for multiple-precision floating-point computations |
| ECLib           | Cremona's Programs for Elliptic curves                       |
| NetworkX        | Graph theory                                                 |
| NTL             | Number theory C++ library                                    |
| **Numpy**       | Numerical linear algebra                                     |
| OpenCDK         | Open Crypto Development Kit                                  |
| PALP            | A Package for Analyzing Lattice Polytopes                    |
| PARI/GP         | Number theory calculator                                     |
| Pexpect         | Pseudo-tty control for Python                                |
| PNG             | Bitmap image support                                         |
| PolyBoRi        | Polynomials Over Boolean Rings                               |
| PyCrypto        | Python Cryptography Toolkit                                  |
| Python          | Interpreted language                                         |
| Qd              | Quad-double/Double-double Computation Package                |
| R               | Statistical Computing                                        |
| Readline        | Line-editing                                                 |
| Rpy             | Python interface to R                                        |
| Scipy           | Python library for scientific computation                    |
| Singular        | fast commutative and noncommutative algebra                  |
| Scons           | Software construction tool                                   |
| SQLite          | Relation database                                            |
| Sympow          | L-function calculator                                        |
| Symmetrica      | Representation theory                                        |
| **Sympy**       | Python library for symbolic computation                      |
| Tachyon         | lightweight 3d ray tracer                                    |
| Termcap         | for writing portable text mode applications                  |
| Twisted         | Python networking library                                    |
| Weave           | Tools for including C/C++ code within Python                 |
| Zlib            | Data compression library                                     |
| ZODB            | Object-oriented database                                     |

+++ {"slideshow": {"slide_type": "slide"}}

## Composing (mathematical) software

Let's focus on two problems

1. Data transfers between two systems
2. Procedure calls across two systems

+++ {"slideshow": {"slide_type": "slide"}}

### Data transfers between two systems

:::{admonition} Goal
Transfer an object `o` from system `A` to system `B`

Ideally: applying a theory morphism to guarantee semantic preservation
:::

:::{admonition} Requirements
- **A communication channel**: shared memory, disk, pipe, (web)socket, ...
- **A communication protocol**: e.g. https, scscp, ...
- **Serialization / Deserialization**: e.g. conversion to/from a string of bytes
- **A format specification**; e.g. XML (syntax) + OpenMath content dictionary (semantic)
- **Format conversion**
  - **syntax**: e.g.: JSON vs XML
  - **adaptation**: `DihedralGroup(4)` vs `DihedralGroup(8)`
  - **change of representation (codec)**: recursive vs dense vs sparse polynomials
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Procedure calls

:::{admonition} Goal
From `B` request the computation of `f(a,b,c)` in `A`

Ideally: applying a theory morphism to guarantee semantic preservation
:::
:::{admonition} Requirements
- **Data transfers**: transfer `a`,`b`,`c` to `A`, transfer back the result\
  ⚠️What if `f(a,b,c)` cannot be modeled in `B`?
- **Procedure call protocol**: bindings, remote procedure calls, ...
- **API specification**: syntax and semantic of `f` in `A`?
- **Adapting the API in B to the API in A**: `Size(A)` vs `A.cardinality()`
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Barriers to composition

+++ {"slideshow": {"slide_type": "fragment"}}

#### Semantic barriers

:::{admonition} Many kinds of objects
:class: warning

E.g. thousands in Sage, compared to "matrices of floats" in Matlab, Numpy, ...
:::

:::{admonition} Many data representations
:class: warning

with very different algorithmic complexity

E.g. for polynomials: sparse, dense, recursive, straight line
program, evaluation, ...

%Objects at different levels of abstraction
:::

:::{admonition} Semiformal is good enough (unlike in proof systems)
:class: hint
- No need to define the maths behind
- No need to share the same (logic) foundation
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Few core concepts ...
:class: hint
 
addition, multiplication, commutativity, metric space, ...
:::

:::{admonition} but many interesting ways to combine them
:class: warning

Groups, Fields, graded commutative algebras, ...
:::

+++ {"slideshow": {"slide_type": "fragment"}}

#### Social barriers

:::{admonition} Closed science and the Montaigu-Capulet syndrome
:class: warning
Won't use code from / share code with XXX
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Tight man power resources
:class: warning
100k+ users; 100+ developers; a handful officially paid full time for it.
:::

:::{admonition} High level of math & computer science specialization required when writing code
:class: warning
E.g. 1k+ users of Gröbner bases; a handful know how to implement them right
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} A fragmented community
:class: warning
By country, culture, domain, system, ...
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Diverse use cases and motivations
:class: warning
- speed maniacs, flexibility fans, composability devouts
- research system versus production system for research
:::

+++ {"slideshow": {"slide_type": "fragment"}}

#### Technical barriers

:::{admonition} Systems written in different languages, idioms, frameworks, API
:class: warning
- Packaging: debian, conda, pip, npm, ...
- Languages: C, C++, Python 2/3, Java, Javascript, Julia, GAP,
  Singular, Macaulay, Maple, Mathematica, MuPAD, Magma, Axiom/Aldor,
  Haskell, ML, Agda, ...
:::

:::{admonition} Large old systems: 20-40 years, $1M$ lines of code
- **large technical debt**, **slow evolution**
- **Lack of modularity**, **large dependencies**

E.g. having to install SageMath to use just a few of its lines

- We can't afford to reimplement them
- We can't afford to not reimplement them\
  to learn from one's mistakes and benefit from technology advances!
:::

+++ {"slideshow": {"slide_type": "slide"}}

## Case studies

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: Open Math 1993-

:::{admonition} Goal
$N$ systems; can we avoid $N \times N$ interfaces ?
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Approach
:class: hint
Standardize serialization format to exchange mathematical data across systems
- **Syntax**: XML, json, binary
- **Semantic**: defined by content dictionaries (CD)
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Socio technical barriers
:class: warning
- Fragmented communities, many objects, many representations
- Agreeing on content dictionaries for polynomials was already hard; scaling?
- After twenty years, little adoption
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: MitM

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: the Sage / GAP interface

- **Problem**

  Use funtionalities from a system `A` in a system `B` written in a different language

- **Data exchange**

  - Objects returned as references (handles):

    - Few conversions
    - Reduced overhead
    - Manipulate from B objects of A with no native representation in B

- **Binding**

  - Originally: a pexpect interface

  - Now: ABI (direct calls at the C level)

+++ {"slideshow": {"slide_type": "slide"}}

- **Adapting**

  - Currently:

    - monolithic adapters for some cases (groups, ...)

  - In progress:

    - modular adapters, exploiting the category hierarchy and semantic alignments

    - objects returned as reference + semantic

    - alignment `B.cardinality() -> Size(A)` attached to the category of sets

    - alignment `B.conjugacy_classes() -> ConjugacyClasses(A)` attached to the category of groups

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: Oscar

:::{admonition} Approach: tight language-level integration with Julia
:class: seealso

See next talk!
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: computing with semigroups

Author: James B. Mitchel et al.

- **Problems**

  - Speeding GAP's semigroup package while increasing its availability

- **Approach**

  - Rewrite as a standalone templated C++ library

  - API: many iterations until converging to a natural API (no memory management, ...)

  - Bindings: from Python: on-the-fly binding using cppyy (also tried Cython, Pybind11, ...)

  - Adaptation: a thin layer for now; could use alignments

libSemigroups: C++ library for computing with semigroups

- With handcrafted GAP bindings
- With handcrafted Python bindings (PyBind11)

  library level access to data structures and function calls
  no adaptation

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: HPCombi

F. Hivert

HPCombi: SIMD-Everywhere optimized C++ library for small dense
combinatorial objects (lists of integers, functions, relations, ...).

Exploits CPU instructions (SSE, AVX, ...) that were originally
designed for cryptography and string matching (genomics).

Typical gain: 1 order of magnitude

Caveat: with HPCombi, cpu-bound problems often become memory-bound

Can contribute to 4-5 order of magnitude optimizations in some
applications when combined with:
- dedicated data structure for memory management
- shared memory parallelism
- multi-processor parallelism

=> harder to compose


### Visualisation

Problematic of visualization; traduction de structures de données vers
des humains

+++ {"slideshow": {"slide_type": "slide"}}

### Combining it all together

:::{figure} media/okada-monoid-module.svg
:::

+++ {"slideshow": {"slide_type": "slide"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "-0.7174479961395264%", "top": "1.3865746392144096%", "width": "53.02343845367432%", "height": "27.606480916341148%"}}}}}

## Conclusion

:::{admonition} A large ecosystem of computational mathematics software
- For historical, technical and social reasons
- 👍 Modularity
:::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "56.279945373535156%", "top": "0.539351569281684%", "width": "41.690101623535156%", "height": "25.92129601372613%"}}}}}

:::{admonition} Sustainability aim: promote an ecosystem where
:class: hint
- Features **live and compete**;\
  and are **archived** when not relevant anymore
- People and systems **collaborate and strive**
:::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "2.0611977577209473%", "top": "40.61805725097656%", "width": "50.031251907348626%", "height": "35.787039862738716%"}}}}}

:::{admonition} Critical need for interoperability
:class: hint
- 🥉**Bronze:** enable cross-system procedure calls and references
- 🥈**Silver:** same, using bindings and shared memory for performance\
  Cython, Pythran, Pybind11, cppyy, julia facilities, ...
- 🥇**Gold:** enable usage as native objects of the host system through adaptors
- 🏆**Diamond:** align type systems through common ontologies\
  to automatically generate adaptors and data conversions
:::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "53.91406059265137%", "top": "36.506945292154946%", "width": "46.76041603088379%", "height": "44.19444613986545%"}}}}}

:::{admonition} Partial success
:class: attention
- 🥈 Reuse through shared low level libraries
- 👍 Advanced computations involving deep integration
- 🥇 Large scale integration in e.g. SageMath\
  🚧 but bespoke interfaces
- 🏆 General approaches: OpenMath, Math-in-the-Middle\
  😢 but little adoption in production
- Need more interoperability between general purpose systems\
  E.g. SageMath/Oscar
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "20.869789123535156%", "top": "85.10879516601562%", "width": "29.541666507720947%", "height": "13.51620356241862%", "zoom": "168%"}}}}, "slideshow": {"slide_type": "fragment"}}

🙏 Thank you! 🙏

+++ {"slideshow": {"slide_type": "skip"}}

### Sustainability

- Make your software a good citizen in an ecosystem
- Promote collaborative software development best practices  
  Documentation, tests, continuous integration and release, ...
- Fight technical debt
- Promote ecosystems where:


## Messages to policy makers

If needed 2021-10-07-WoSSS.md
