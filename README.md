# Porter stemmer in Flex

Porter's stemming algorithm is one of the most famous and popular 
state-of-the-art methods for stemming for the English language.
It has been implemented in many languages, including C, Python, Perl,
etc., and all these implementations can be found on Martin Porter's home page: [http://tartarus.org/martin/PorterStemmer/](http://tartarus.org/martin/PorterStemmer/). 
It's a rule-based suffix stripping algorithm, where each rule, or better said rule set, transforms the term towards the final artificial word stem.

[Flex](https://github.com/westes/flex) is probably not the best choice to implement such a *suffix stripping* algorithm.
Therefore, do not expect that this implementation to be better, i.e. more efficient
than any other implementation available. That is, it is highly recommended *not to use it*,
unless you create your own programming language with built-in stemming support &ndash; or something like that.

# Implementation

The exact algorithm can be found in [http://tartarus.org/martin/PorterStemmer/def.txt](http://tartarus.org/martin/PorterStemmer/def.txt), 
therefore it won't be repeated here. I will only discuss some of the rules, to understand the underlying idea and the implementation.

A word can be represented by sequences of consonants and vowels, and can be written
in the following compact form:
```
C?(VC){m}V?
```
where `C` and `V` represents a nonempty sequence of consonants and vowels, respectively.

Because Flex processes the input from left to right, we will reverse the term to be stripped, and
every regular expression we use will be inverted, i.e. a word will have the form:
```
V?(CV){m}C?
```

## Consonants

A consonant is defined as a letter other than "a", "e", "i", "o", "u", and 
other than "y" preceded by a consonant. That is, a consonant is either `[a-z]{-}[aeiou]` 
when preceded by a vowel, or it is the first letter of a word, or `[a-z]{-}[aeiouy]`
otherwise. Therefore, we can write the inverted regex macro `C` as
```
C ([a-z]{-}[aeiouy])*([a-z]{-}[aeiou])
```
denoting a nonempty sequence of consonants.

## Vowels

A letter if not a consonant is a vowel. We have two cases here:

- (a) if a word starts with a vowel, we can define it as `[aeiou]` (it cannot be "y", because
by definition that is a consonant);
- (b) a vowel after a consonant is `[aeiouy]` and so is if preceded by a vowel.

Therefore, we will have the following two macros:

```
Ve [aeiou]+
VbC [aeiouy]+
```
Here, because processing the words backwards, `Ve` denotes a vowel sequence at the
end, while `VbC` represent a sequence of vowels appearing after a sequence of consonants.

## Other useful macros

An arbitrary letter (consonant or vowel) can be simply written as:
```
W [a-z]
```
In the rules defined by the stemmer will appear conditions or the form
`(m=1)`, `(m>0)` and `(m>1)`. It is useful to define
macros for these, in order to simplify our regular expressions.

For `(m=1)` we have two cases: the word either starts with a vowel or a consonant.
If the first letter is a vowel then, because `m=1`, we can write `{VbC}?{C}{Ve}`.
Otherwise, the word has the form `{VbC}{C}{VbC}{C}`. Putting it all together, we can define the
macro `M_ONE` as:
```
M_ONE {VbC}?{C}({VbC}{C}|{Ve})
```

For `(m>0)` the same two cases should be considered. If the word starts with a vowel
then we have `{VbC}?({C}{VbC})*{C}{Ve}`, because the `{C}{Ve}` at the beginning
means one `VC` component. Otherwise we arrive to `{VbC}?({C}{VbC})+{C}`. Combining
these two, we obtain the following regex:
```
M_GT_ZERO {VbC}?(({C}{VbC})+{C}|({C}{VbC})*{C}{Ve})
```

For `(m>1)` &ndash; using the same decomposition &ndash; we get:
```
M_GT_ONE {VbC}?(({C}{VbC})+{C}{Ve}|({C}{VbC}){2,}{C})
```

## The Flex rules

The stemming rule sets has to be used in the following way.
The rules are clustered such that at most one rule from such a cluster/set
can be active at a time. The active rule will be one with the longest 
matching suffix. For example, for the word "agreed" in step 1b of the method,
either the `(m>0) EED -> EE` or the `(*v*) ED ->`
rule can be applied; in this case, because the first rule has the
longer matching suffix "eed", that will be used. First, we search for the matching
rule based only on the suffix; if there is such a rule, we check for its condition
if that is satisfied: if fulfilled, we apply the transformation, otherwise we skip to next
rule set, that is no other rules from the current set will be checked further.

To implement the rule sets, we use start conditions (there will be a lot of these in
the source file if you take a look). There are two special start conditions: `STEP0` and
`STEP6`. `STEP0` reverses the word in order to be able to handle the suffixes,
and `STEP6` prints the reversed reversed string (and empties the input buffer).

The words have to be supplied in a file where each word lies on a separate line.

How the rule sets and their correct activation are realized? In order to accomplish the 
*longest suffix matching rule*, we list the Flex rules in decreasing order of the
suffixes. That is, for example in step 1a the rule corresponding to `SS -> SS` 
will be listed earlier than `S -> `. Every rule set is assigned to a start condition 
using the same notation as in the original paper, therefore it is quite easy to follow the code.
For example in `STEP0`, after reversing the string, depending on its length we 
switch to start condition `STEP1a` if the length is greater than 2, otherwise the word
has to be left as it is, i.e. we switch to start condition `STEP6`. 
In `STEP1a` we then implement the corresponding rule set.

In order to facilitate the step to the next rule set in case none of the rules matches, 
every start condition defined will have its last regex rule as 
```
<start_condition>{W}* { yyless(0); BEGIN(next_start_condition); }
```

If a suffix has a condition (e.g. `(m>0) EED -> EE`) more than 
one start conditions has to be used to implement the method. This is because, according to Porter's
algorithm, first one has to check the suffix matching without the condition. 
For example, our first rule in step 1b is
```
<STEP1b>dee{W}* { yyless(0); BEGIN(STEP1b1); }
```
switching to `STEP1b1`, where the condition is checked:
```
<STEP1b1>dee{M_GT_ZERO} { yyless(1); BEGIN(STEP1c); }
```

To check the rule `(m=1 and not *o) E -> ` in step 5a 
resulted in a way too long/complicated regular expression, therefore it is
implemented in a simpler way using more than one rules.
