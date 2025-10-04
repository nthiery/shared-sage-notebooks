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

- 
- Interoper

+++ {"slideshow": {"slide_type": "slide"}}

## Setting up the Stage

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"height": "10.46913429542824%", "left": "2.638888888888889%", "position": "fixed", "top": "2.5432106300636574%", "width": "89.58333333333334%"}}}}, "slideshow": {"slide_type": "slide"}}

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
- latex, wikipedia, publishing services, ...
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"position": "fixed", "left": "0%", "top": "65%", "width": "45%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 🤔 Deduction
- Use cases: help formalize and certify knowledge
- Proof checkers, proof assistants, automated provers, ...
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "15%", "width": "50%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 🖩**Computation** 
- Use cases: help observe and explore; infer, test conjectures\
  even sometimes prove them
- 🔭The mathematician's **telescope**
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": "45%", "position": "fixed", "top": "65%", "width": "50%"}}}}, "slideshow": {"slide_type": "fragment"}}

:::{admonition} 💾Tabulation
- Use cases: help collect examples to explore, infer, test conjectures; record knowledge
- Databases of mathematical objects
- 💡Mostly a cache of hard to compute or deduce knowledge
:::

+++ {"@deathbeds/jupyterlab-fonts": {"styles": {"": {"body[data-jp-deck-mode='presenting'] &": {"left": null, "position": null, "top": null, "width": null, "height": null}}}}, "slideshow": {"slide_type": "slide"}}

## Musing on the computational mathematics landscape

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Available building blocks for semigroup representation theory

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

That's what happens in the tech industry: a single player takes it all (Amazon, AirBnB, Uber, ...) 

+++ {"slideshow": {"slide_type": "fragment"}}

:::{admonition} Why not for us?

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
between systems, at the wrong scale
:::

+++ {"slideshow": {"slide_type": "fragment"}}

:::{error} Honestly, we don't know what will a good system in 10-20 years
We need to explore many approaches
:::

+++ {"slideshow": {"slide_type": "slide"}}

## Some mathematical objects we want to compute with

```{code-cell} ipython3
%display latex
```

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

Symbolic expressions, equations: $cos(x)^2 + sin(x)^2 == 1$

+++ {"slideshow": {"slide_type": "fragment"}}

Finite fields, algebraic extensions, elliptic curves, ...

+++

And combinations!
{eval}`MatrixSpace(MatrixSpace(QQ['x'],2,2), 2, 2).random_element()`

+++ {"slideshow": {"slide_type": "slide"}}

Combinatorial objects:
:::{image} media/labelled-binary-tree.svg
:::

{eval}`SVG(DyckWord([1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0])._repr_svg_())`

+++

And combinations:
:::{image} media/calcul-operade.png
:::

+++ {"slideshow": {"slide_type": "subslide"}}

Graphs:
:::{image} media/crystal-A3-32.svg
:width: 10% 
:::

+++ {"slideshow": {"slide_type": "fragment"}}

Geometric objects:
:::{image} media/polytope.png
:width: 50%
:::
:::{image} media/G2-alcove-path.svg
:width: 20%
:::
:::{image} media/manifold.png
:width: 25%
:::


Some examples in 2021-02-15-SageOscarDays.md

+++ {"slideshow": {"slide_type": "slide"}}

## The ecosystem of Mathematical software

Build on the shoulders of Giants
- dozens of libraries
- 

List of software included in Sage: Science Workshop


How to compose?

+++ {"slideshow": {"slide_type": "subslide"}}

### Reusability
- Reuse off-the-shelf components whenever you can
  - Programming languages (e.g. C++, Python, Julia, ...)
  - Preexisting libraries
  - Computing environments and user interfaces (e.g Jupyter)
  - Development models and tools
- Make your software reusable
  - Accessibility, ...
  - Write generic code

<p style="text-align:center; font-weight:bold">Base decisions on technical <em>and</em> social matters<p>

+++ {"slideshow": {"slide_type": "subslide"}}

### Sustainability

- Make your software a good citizen in an ecosystem
- Promote collaborative software development best practices  
  Documentation, tests, continuous integration and release, ...
- Fight technical debt
- Promote ecosystems where:
  - Features **live and compete**;\
    and are **archived** when not relevant anymore
  - People and systems **collaborate and strive**

+++ {"slideshow": {"slide_type": "subslide"}}

## Interoperability

- **Bronze:** enable cross-system procedure calls and handles
- **Silver:** same, using bindings and shared memory for performance  
  Cython, pythran, cppyy, julia facilities, ...
- **Gold:** Enable usage as native objects of the host component through adaptors
- **Diamond:** align type systems through common ontologies to automatically
  generate adaptors and data conversions

<p style="text-align:center; font-weight:bold;">Fight silo effects in systems based on hundreds of components!</p>

Details from FLOC


# Case studies

## Modular representations of semigroups

## Messages to policy makers

If needed 2021-10-07-WoSSS.md
