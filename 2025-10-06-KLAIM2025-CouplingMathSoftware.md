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
over a million lines of code, and offers hundreds of mathematical
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
- WOSSS 21: /opt/shared-sage-notebooks/2021-10-07-WoSSS.md
- Miko 25: /home/nthiery/www/Talks/2025-05-17-MichaelKohlhaseFest/index.md

+++ {"slideshow": {"slide_type": "slide"}}

## Menu

1. Context: the computational mathematics software ecosystem
    1. Mechanizing mathematics: the Tetrapod
	2. What do we want to compute with?
	3. Need to couple / compose from a large ecosystem of components
2. Composing mathematical software
    1. Goals: transfers and procedure calls
    2. Barriers
3. Case studies

+++ {"slideshow": {"slide_type": "slide"}}

## The computational mathematics software ecosystem

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "0%", "position": "fixed", "top": "0%", "width": "50%"}}}}, "slideshow": {"slide_type": "slide"}}

### Mechanizing mathematics: the Tetrapod

How can computers help mathematicians?

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "35.574073791503906%", "position": "fixed", "top": "40%", "width": "25%"}}}}, "editable": true, "slideshow": {"slide_type": ""}}

:::{image} media/tetrapod.jpg
:width: 100%
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "top": "15%", "width": "45%", "left": "0%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 📚 Narration
- Use cases: help express, organize, interconnect, navigate,
  synthesize, visualize mathematical knowledge
- latex, jupyter, wikipedia, publishing services, generative AI, ...
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "0%", "top": "65%", "width": "45%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 🤔 Deduction
- Use cases: help formalize and certify mathematical knowledge
- Proof checkers, proof assistants, automated provers, ...
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "15%", "width": "50%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 🖩 **Computation** 
- Use cases: help observe and explore; infer and test conjectures\
  even sometimes prove them
- 🔭The mathematician's **telescope**
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "65%", "width": "50%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 💾 Concretization
- Harvest, record, and classify examples
- Use cases: help observe and explore; infer and test conjectures; record knowledge
- The atlas of finite groups, the Online Encyclopedy of Integer Sequences, ...
- 💡Mostly a cache of hard to compute or deduce knowledge
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "2%", "width": "50%", "zoom": "50%"}}}}, "slideshow": {"slide_type": null}}

:::{admonition} Big Math and the One-Brain Barrier – The Tetrapod Model of Mathematical Knowledge
:class: seealso
Jacques Carette et al. In: Mathematical Intelligencer 43.1 (2021), pp. 78–87. DOI: 10.1007/s00283-020
:::

+++ {"slideshow": {"slide_type": "slide"}}

## Concretely: what do we want to compute with?

```{code-cell} ipython3
---
slideshow:
  slide_type: skip
---
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
- **Serialization / deserialization**: e.g. conversion to/from a string of bytes
- **A format specification**; e.g. XML (syntax) + OpenMath content dictionary (semantic)
- **Format conversion**
  - **syntax**: e.g.: JSON vs XML
  - **adaptation**: `DihedralGroup(4)` vs `DihedralGroup(8)`
  - **change of representation (codec)**: dense vs sparse polynomials
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

E.g. hundreds in Sage, compared to "matrices of floats" in Matlab, Numpy, ...
:::

:::{admonition} Many data representations
:class: warning

with very different algorithmic complexity

E.g. for polynomials: sparse, dense, recursive, factored, straight line
program, evaluation, ...

%Objects at different levels of abstraction
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Semiformal is good enough (unlike in proof systems)
:class: hint
- No need to define the maths behind
- No need to share the same (logic) foundation
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Not that many core concepts ...
:class: hint
 
cardinality, addition, multiplication, commutativity, metric space, ...
:::

:::{admonition} but many interesting ways to combine them
:class: warning

Groups, Fields, graded commutative algebras, ...
:::

+++ {"slideshow": {"slide_type": "slide"}}

#### Social barriers

:::{admonition} Closed science
:class: warning
- Won't use code from / share code with XXX (Montaigu-Capulet syndrome)
- Closed licenses, ...
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

+++ {"slideshow": {"slide_type": "slide"}}

#### Technical barriers

:::{admonition} Systems written in different languages, idioms, frameworks, API
:class: warning
- Languages: C, C++, Python 2/3, Java, Javascript, Julia, GAP,
  Singular, Macaulay, Maple, Mathematica, MuPAD, Magma, Axiom/Aldor,
  Haskell, ML, Agda, ...
- Packaging: debian, conda, pip, npm, ...
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

### Case study: reusable high performance libraries for tiny mathematical objects

:::{admonition} Example: computing with tiny combinatorial objects
Floating point arithmetic scale:
- object size: a few bytes; computations: down to a few CPU cycles
- object types; a few; API: a few operations
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} HPCombi (F. Hivert) 2015-
- tiny lists of integers, permutations, functions, relations, ...
- SIMD-Everywhere optimized C++ library
- Exploits CPU instructions (SSE, AVX, ...) originally designed for
  cryptography and string matching (genomics)
- Typical gain: 1 order of magnitude compared to plain CPU
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Example application: map-reduce at 1 Tb/s through billions of objects
:class: hint

Can contribute to 4-5 orders of magnitude when coupled with:
- dedicated data structures for memory management
- shared-memory parallelism
- multi-processor parallelism
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Caveats to composition
- with HPCombi, cpu-bound problems often become memory-bound
- any interface overhead kills the benefits
- requires tight low-level integration (hard work)
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: reusable high performance CPU {strike}`applications` libraries

:::{admonition} Example: computing the structure of semigroups
Sparse linear algebra scale:
- objects: 1kb - 1Gb; computations: ms - hours; API: a few operations
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} 2000-2015: 3+ implementations of semigroup algorithms
- the C-application Semigroupe (Pin et al.): super fast core algorithms
- the Semigroups library in GAP (Mitchell et al.): feature rich 
- the Semigroups library in Sage (T et al.): basic core algorithms needed for representation theory
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Goal
- a unique super fast implementation of core algorithms (CPU)
- reusable from many systems
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Approach (James B. Mitchel et al. 2015-2020)
-   Standalone templated C++ library: libSemigroups\
    With carefuly crafted natural API (minimize memory management); took many iterations!
-   access to data structures and procedure calls at library level
    - 👍 from C++ programms
    - 👍 interactively in Jupyter with the cling C++ interpreter
    - 👍 from GAP through handcrafted bindings
    - 👍 from Python and Sage through handcrafted bindings (PyBind11; also tried Cython, cppyy, ...)
    - 👍 from Sage and OSCAR through GAP
-   Adaptation: a thin layer for now; could use more alignments
:::

% One of ODK case study for extracting independent low-level libraries C++
% - libsemigroups API design:<br>
%  J. Mitchell with F. Hivert and  N. Thiéry: Cernay 2017, 2018
% - libsemigroups Python bindings<br>
%  J. Mitchell and  N. Thiéry <i class="logo"></i>: Edinburgh, 2017, Cernay 2017, 2018
% - libsemibroups usable directly in Jupyter thanks to xeus-cling<br>
%  S. Corlay, J. Mabile, L. Gouarin <i class="logo"></i>
% - libsemigroups packaging<br>
%  J. Mitchell and  N. Thiéry <i class="logo"></i>: Jupyter for Mathematics Workshop, Edinburgh, 2017
%/home/nthiery/OpenDreamKit/demo-semigroup-representation-theory/2020-05-28-SageDay109-opendreamkit-debriefing.md

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: reusable large {strike}`applications` libraries

:::{admonition} Example: integrating the Computer Algebra System GAP (A) in SageMath (B)
Large application scale:
- hundreds of objects types, thousands of functions
- dozens of developers over 40 years + hundreds of developers of GAP packages
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} 🥉 Original approach (2004-): B calls the application A as a subprocess (pexpect)
- Communication channel: pipes
- (de)Serialization to/from text in A's language format
- Bespoke conversions for basic objects
- Other objects returned as ***references***:
    - 👍 few conversions
    - 👍 reduced overhead
    - 👍 manipulate from B objects of A with no native representation in B
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} 🥈 Improvement (2013-2019): B calls the *C-library* A through bindings
Thanks to hard work by the GAP+friends community:
- Refactoring of GAP from an application to a C library (libgap)\
  ⇒ other use cases
- Refactoring of GAP's build system
:::
%- libgap used to be a fragile hard to maintain fork of GAP<br>
%  Volker Braun
  
%- libgap is now a standard feature of GAP<br>
%  M. Horn, A. Konovalov <i class="logo"></i>, M. Pfeiffer <i class="logo"></i>, J. Demeyer <i class="logo"></i>, E. M. Bray <i class="logo"></i>, N. Thiéry <i class="logo"></i>, D. Pasechnik<i class=logo></i><br>
%  GAP-Sage Days 2016, 2017, 2018

%- Made possible by GAP's build system refactoring<br>
%  M. Horn, A. Konovalov <i class="logo"></i>, ...
%- A major step for sustainable packaging of GAP and Sage

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Caveat: minimal adaptation
:class: warning
- Only for a few types\
  e.g. you can use a GAP group as a Sage group
:::
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: The High Road, Episode 1: Open Math 1993-

:::{admonition} Goal
$N$ systems, $T$ types of objects\
🤔 can we avoid $N \times N \times T$ manual interfacing work ?
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Approach: standards and ontologies
:class: hint
Standardize serialization format to exchange mathematical data across systems
- **Syntax**: structured data, represented as XML, json, binary
- **Semantic** (the **meaning of data**): defined by content dictionaries

Required work: $T + N \times T$
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Socio technical barrier: agreeing on the meaning of data is hard
:class: warning
- Even just for polynomials!
- Many (decades old) computational and database systems (N)
- Many complex objects, many representations (T)
- Used by many communities
- 😢After twenty years, little adoption
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: The High Road, Episode 2: Math-in-the-Middle 2015-

+++ {"slideshow": {"slide_type": "fragment"}}

:::{figure} media/MitM.png
:width: 90%
:::

+++ {"slideshow": {"slide_type": "slide"}}

::::{admonition} Math-in-the-Middle: Math knowledge at the service of interoperability
:class: hint

1. Formalize/extract bespoke ontologies for each system independently
2. Align these ontologies to the mathematical concepts

:::{figure} media/mistargraph.svg
:alt: Math-in-the-Middle: a collection of systems, with their bespoke ontologies aligned to Math knowledge in the middle
:width: 20%
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{figure} media/sage-category-graph.png
:width: 80%
:align: left
(A piece of) Sage's ontology
:::
::::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "65%", "top": "10%", "width": "40%", "z-index": "10"}}}}}

:::{figure} media/gap-graph.png
:width: 100%

A piece of GAP's ontology
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Status: prototypes, [CICM'16](https://doi.org/10.1007/978-3-319-42547-4_9), [MACIS'17](https://doi.org/10.1007/978-3-319-72453-9_14)
- 👍 Easy socially and technically (local)
- 👍 Can be incremental
- 😓 Still takes work and motivation
- 😢Little adoption
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: lightweight Math-in-the-Middle interface through deep ontologies

:::{admonition} Example: Adaptation in the GAP ⇒ Sage interface
Scale:
- T: hundreds of types of objects
- dozens of core concepts / operations: addition, multiplication, commutative, metric spaces, ...
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} 👍 A GAP group G can be used as a native Sage group

Examples of hard coded alignments:
- `G.cardinality()` in Sage: aligned to `Size(G)` in GAP
- `G.group_generators()` in Sage: aligned to `GroupGenerators(G)` in GAP.
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} 😢 A GAP semigroup G can't be used as a native Sage semigroup!
:class: error
Even with less structure!
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Approach: modularize the adapters by aligning on concepts
- Objects returned as reference + semantic
- For any set: `G.cardinality()` in Sage: aligned to `Size(G)` in GAP
- For any group: `G.group_generators()` in Sage: aligned to `GroupGenerators(G)` in GAP.

- Alignments provided as type annotations:
```python
    @semantic(gap="Group")
    class Groups:

        class ParentMethods:

            @semantic(gap="GeneratorsOfGroup", codomain=Family[Self])
            @abstract_method
            def group_generators(self):
                pass
```

Prototype: https://github.com/nthiery/sage-gap-semantic-interface
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Coupling it all together

:::{figure} media/okada-monoid-module.svg
:width: 90%
A module of the okada monoid [Hivert'25]
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Coupling it all together

:::{admonition} Graph visualization
Software: graphviz
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Representation theory
Software: Sage (in Python)

Interface: tikz export ...
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} High level semigroup algorithms

Software: GAP's Semigroup packages (in GAP)

Interface: C bindings + references + semantic adapters

:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} High performance core semigroup algorithms

Software: libsemigroups library (in C++)

Interface: C++ bindings

:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} High performance tiny data structures
Software: HPC Combi (in C++ + SIMD)
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Linear algebra
Software: Linbox, ... (in C++)

Interface: C++ bindings 
:::

:::{admonition} Arithmetic
Software: Givaro, GMP, FLINT, (in C++)
:::

+++ {"slideshow": {"slide_type": "slide"}}

### Case study: OSCAR

:::{admonition} Approach: tight language-level integration with Julia
:class: seealso

See next talk for other cool software coupling!
:::

+++ {"slideshow": {"slide_type": "slide"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "-5%", "top": "0%", "width": "55%"}}}}}

## Conclusion

:::{admonition} A large ecosystem of coupled<br> computational mathematics software
- 👍 For modularity and technical reasons
- For historical and social reasons
:::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "48%", "top": "6%", "width": "55%"}}}}}

:::{admonition} Sustainability aim: promote an ecosystem where
:class: hint
- Features **live and compete**;\
  and are **archived** when not relevant anymore
- People and systems **collaborate and strive**
:::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "-5%", "top": "37%", "width": "55%"}}}}}

:::{admonition} Critical need for interoperability A ⇒ B
:class: hint
- 🥉**Bronze:** cross-system procedure calls and references
- 🥈**Silver:** same with shared memory for performance
  1. A available as C/C++ library
  2. bindings: Cython, Pythran, Pybind11, cppyy, julia facilities, ...
- 🥇**Gold:** A-references as native B-objects through adaptors
- 🏆**Diamond:** align type systems through common ontologies
  1. N interfaces instead of N ⨉ N
  2. automatically generate adaptors and data conversions
:::

+++ {"slideshow": {"slide_type": "fragment"}, "@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "48%", "top": "37%", "width": "55%"}}}}}

:::{admonition} Partial success
:class: attention
- 🥈 Reuse through shared low level libraries
- 🥈 Reuse by turning applications into libraries
- 👍 Advanced computations involving deep integration
- 🥇 Large scale integration in e.g. SageMath\
  🚧 often bespoke interfaces
- 🏆 High road approaches: OpenMath, Math-in-the-Middle\
  😢 little adoption in production
- Need more interoperability between general purpose systems\
  E.g. SageMath ⇐⇒ Oscar
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "25%", "top": "90%", "width": "55%", "zoom": "200%"}}}}, "slideshow": {"slide_type": "fragment"}}

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
