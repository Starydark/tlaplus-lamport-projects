---- MODULE MC ----
EXTENDS CJupiter, TLC

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
c1, c2
----

\* MV CONSTANT declarations@modelParameterConstants
CONSTANTS
a, b
----

\* MV CONSTANT definitions Client
const_154461762361815000 == 
{c1, c2}
----

\* MV CONSTANT definitions Char
const_154461762361816000 == 
{a, b}
----

\* SYMMETRY definition
symm_154461762361817000 == 
Permutations(const_154461762361816000)
----

\* CONSTANT definitions @modelParameterConstants:2InitState
const_154461762361918000 == 
<<>>
----

\* SPECIFICATION definition @modelBehaviorSpec:0
spec_154461762361920000 ==
Spec
----
\* INVARIANT definition @modelCorrectnessInvariants:0
inv_154461762361921000 ==
Compactness
----
=============================================================================
\* Modification History
\* Created Wed Dec 12 20:27:03 CST 2018 by hengxin